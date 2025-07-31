//
//  EbayAPIService.swift
//  ResellAI
//
//  Created by Alec on 7/31/25.
//


import SwiftUI
import Foundation

// MARK: - Complete eBay API Service
class EbayAPIService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authStatus = "Not authenticated"
    @Published var isSearching = false
    @Published var isListing = false
    
    private let authManager = EbayAuthManager()
    private let baseURL = "https://api.ebay.com"
    private let sandboxURL = "https://api.sandbox.ebay.com"
    
    // Rate limiting
    private var lastAPICall: Date = Date(timeIntervalSince1970: 0)
    private let minAPIInterval: TimeInterval = 0.2 // 5 calls per second max
    
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication
    func authenticate() {
        authManager.authenticate { [weak self] success in
            DispatchQueue.main.async {
                self?.isAuthenticated = success
                self?.authStatus = success ? "Authenticated" : "Authentication failed"
            }
        }
    }
    
    private func checkAuthenticationStatus() {
        isAuthenticated = authManager.hasValidToken()
        authStatus = isAuthenticated ? "Authenticated" : "Not authenticated"
    }
    
    // MARK: - Market Research - Get Real Sold Listings
    func getSoldListings(
        keywords: String,
        category: String? = nil,
        condition: EbayCondition? = nil,
        completion: @escaping ([EbaySoldListing]) -> Void
    ) {
        
        guard isAuthenticated else {
            print("❌ eBay not authenticated")
            completion([])
            return
        }
        
        isSearching = true
        
        let endpoint = "/buy/browse/v1/item_summary/search"
        let url = URL(string: baseURL + endpoint)!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "q", value: keywords),
            URLQueryItem(name: "filter", value: "buyingOptions:{AUCTION|FIXED_PRICE},deliveryOptions:{SHIPPING},conditionIds:{1000|1500|2000|2500|3000|4000|5000}"),
            URLQueryItem(name: "sort", value: "endTimeSoonest"),
            URLQueryItem(name: "limit", value: "100")
        ]
        
        // Add category filter if specified
        if let category = category {
            let categoryID = mapToCategoryID(category)
            queryItems.append(URLQueryItem(name: "category_ids", value: categoryID))
        }
        
        // Add condition filter if specified  
        if let condition = condition {
            let conditionID = mapConditionToEbayID(condition)
            queryItems.append(URLQueryItem(name: "filter", value: "conditionIds:{\(conditionID)}"))
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(authManager.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Configuration.ebayAPIKey, forHTTPHeaderField: "X-EBAY-C-MARKETPLACE-ID")
        
        rateLimitedRequest(request) { [weak self] data, response, error in
            self?.isSearching = false
            
            if let error = error {
                print("❌ eBay search error: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(EbaySearchResponse.self, from: data)
                let soldListings = self?.convertToSoldListings(searchResponse.itemSummaries ?? []) ?? []
                print("✅ Found \(soldListings.count) eBay sold listings")
                completion(soldListings)
            } catch {
                print("❌ eBay JSON parsing error: \(error)")
                completion([])
            }
        }
    }
    
    // MARK: - Get Completed/Sold Items (Finding API)
    func getCompletedItems(
        keywords: String,
        categoryId: String? = nil,
        completion: @escaping ([EbaySoldListing]) -> Void
    ) {
        
        let findingURL = "https://svcs.ebay.com/services/search/FindingService/v1"
        
        var urlComponents = URLComponents(string: findingURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "OPERATION-NAME", value: "findCompletedItems"),
            URLQueryItem(name: "SERVICE-VERSION", value: "1.0.0"),
            URLQueryItem(name: "SECURITY-APPNAME", value: Configuration.ebayAPIKey),
            URLQueryItem(name: "RESPONSE-DATA-FORMAT", value: "JSON"),
            URLQueryItem(name: "keywords", value: keywords),
            URLQueryItem(name: "itemFilter(0).name", value: "SoldItemsOnly"),
            URLQueryItem(name: "itemFilter(0).value", value: "true"),
            URLQueryItem(name: "itemFilter(1).name", value: "EndTimeTo"),
            URLQueryItem(name: "itemFilter(1).value", value: ISO8601DateFormatter().string(from: Date())),
            URLQueryItem(name: "itemFilter(2).name", value: "EndTimeFrom"),
            URLQueryItem(name: "itemFilter(2).value", value: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-30*24*60*60))),
            URLQueryItem(name: "paginationInput.entriesPerPage", value: "100"),
            URLQueryItem(name: "sortOrder", value: "EndTimeSoonest")
        ]
        
        if let categoryId = categoryId {
            urlComponents.queryItems?.append(URLQueryItem(name: "categoryId", value: categoryId))
        }
        
        let request = URLRequest(url: urlComponents.url!)
        
        rateLimitedRequest(request) { data, response, error in
            if let error = error {
                print("❌ eBay Finding API error: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let findingResponse = try JSONDecoder().decode(EbayFindingResponse.self, from: data)
                let soldListings = self.convertFindingResultsToSoldListings(findingResponse)
                print("✅ Found \(soldListings.count) completed eBay items")
                completion(soldListings)
            } catch {
                print("❌ eBay Finding JSON error: \(error)")
                completion([])
            }
        }
    }
    
    // MARK: - Create eBay Listing
    func createListing(
        item: InventoryItem,
        analysis: AnalysisResult,
        completion: @escaping (EbayListingResult) -> Void
    ) {
        
        guard isAuthenticated else {
            completion(EbayListingResult(success: false, listingId: nil, listingURL: nil, error: "Not authenticated"))
            return
        }
        
        isListing = true
        
        // First upload images
        uploadImages(item: item) { [weak self] imageURLs in
            self?.createListingWithImages(item: item, analysis: analysis, imageURLs: imageURLs, completion: completion)
        }
    }
    
    private func uploadImages(item: InventoryItem, completion: @escaping ([String]) -> Void) {
        var imageURLs: [String] = []
        let group = DispatchGroup()
        
        // Upload main image
        if let imageData = item.imageData {
            group.enter()
            uploadSingleImage(imageData: imageData) { url in
                if let url = url {
                    imageURLs.append(url)
                }
                group.leave()
            }
        }
        
        // Upload additional images
        if let additionalImages = item.additionalImageData {
            for imageData in additionalImages.prefix(7) { // eBay allows up to 8 images
                group.enter()
                uploadSingleImage(imageData: imageData) { url in
                    if let url = url {
                        imageURLs.append(url)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(imageURLs)
        }
    }
    
    private func uploadSingleImage(imageData: Data, completion: @escaping (String?) -> Void) {
        let endpoint = "/sell/inventory/v1/bulk_upload_image"  
        let url = URL(string: baseURL + endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authManager.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        rateLimitedRequest(request) { data, response, error in
            if let error = error {
                print("❌ Image upload error: \(error)")
                completion(nil)
                return
            }
            
            // Parse response for image URL
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let imageUrl = json["imageUrl"] as? String {
                completion(imageUrl)
            } else {
                completion(nil)
            }
        }
    }
    
    private func createListingWithImages(
        item: InventoryItem,
        analysis: AnalysisResult,
        imageURLs: [String],
        completion: @escaping (EbayListingResult) -> Void
    ) {
        
        let endpoint = "/sell/inventory/v1/inventory_item"
        let url = URL(string: baseURL + endpoint)!
        
        // Create eBay listing payload
        let listingData = createEbayListingPayload(item: item, analysis: analysis, imageURLs: imageURLs)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authManager.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Configuration.ebayAPIKey, forHTTPHeaderField: "X-EBAY-C-MARKETPLACE-ID")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: listingData)
        } catch {
            completion(EbayListingResult(success: false, listingId: nil, listingURL: nil, error: "Failed to serialize listing data"))
            return
        }
        
        rateLimitedRequest(request) { [weak self] data, response, error in
            self?.isListing = false
            
            if let error = error {
                print("❌ eBay listing creation error: \(error)")
                completion(EbayListingResult(success: false, listingId: nil, listingURL: nil, error: error.localizedDescription))
                return
            }
            
            guard let data = data else {
                completion(EbayListingResult(success: false, listingId: nil, listingURL: nil, error: "No response data"))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(EbayListingResponse.self, from: data)
                
                if let listingId = response.sku {
                    let listingURL = "https://www.ebay.com/itm/\(listingId)"
                    completion(EbayListingResult(success: true, listingId: listingId, listingURL: listingURL, error: nil))
                    print("✅ eBay listing created: \(listingURL)")
                } else {
                    completion(EbayListingResult(success: false, listingId: nil, listingURL: nil, error: "Invalid response"))
                }
            } catch {
                print("❌ eBay listing response parsing error: \(error)")
                completion(EbayListingResult(success: false, listingId: nil, listingURL: nil, error: "Response parsing failed"))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createEbayListingPayload(item: InventoryItem, analysis: AnalysisResult, imageURLs: [String]) -> [String: Any] {
        
        let categoryId = mapToCategoryID(item.category)
        let conditionId = mapConditionToEbayID(analysis.ebayCondition)
        
        let payload: [String: Any] = [
            "sku": "RESELLAI-\(item.inventoryCode)",
            "locale": "en_US",
            "product": [
                "title": analysis.ebayTitle.prefix(80),
                "description": formatEbayDescription(item: item, analysis: analysis),
                "imageUrls": imageURLs,
                "aspects": createItemSpecifics(item: item, analysis: analysis)
            ],
            "condition": conditionId,
            "conditionDescription": analysis.ebayCondition.description,
            "availability": [
                "shipToLocationAvailability": [
                    "quantity": 1
                ]
            ],
            "packageWeightAndSize": [
                "dimensions": [
                    "height": 6,
                    "length": 12,
                    "width": 9,
                    "unit": "INCH"
                ],
                "weight": [
                    "value": 1,
                    "unit": "POUND"
                ]
            ]
        ]
        
        return payload
    }
    
    private func formatEbayDescription(item: InventoryItem, analysis: AnalysisResult) -> String {
        return """
        <div style="font-family: Arial, sans-serif; max-width: 800px;">
        <h2>\(analysis.itemName)</h2>
        
        <h3>Condition: \(analysis.actualCondition)</h3>
        <p>\(analysis.ebayCondition.description)</p>
        
        <h3>Details:</h3>
        <ul>
        <li><strong>Brand:</strong> \(analysis.brand)</li>
        <li><strong>Model:</strong> \(analysis.itemName)</li>
        <li><strong>Size:</strong> \(item.size)</li>
        <li><strong>Style Code:</strong> \(analysis.identificationResult.styleCode)</li>
        <li><strong>Color:</strong> \(item.colorway)</li>
        </ul>
        
        <h3>Why Buy From Us:</h3>
        <ul>
        <li>✅ AI-verified authentic items</li>
        <li>✅ Professional condition assessment</li>
        <li>✅ Fast shipping with tracking</li>
        <li>✅ 30-day returns accepted</li>
        <li>✅ 100% satisfaction guarantee</li>
        </ul>
        
        <p><strong>Fast, secure shipping with tracking provided!</strong></p>
        </div>
        """
    }
    
    private func createItemSpecifics(item: InventoryItem, analysis: AnalysisResult) -> [String: String] {
        var specifics: [String: String] = [:]
        
        if !analysis.brand.isEmpty {
            specifics["Brand"] = analysis.brand
        }
        
        if !item.size.isEmpty {
            specifics["Size"] = item.size
        }
        
        if !item.colorway.isEmpty {
            specifics["Color"] = item.colorway
        }
        
        if !analysis.identificationResult.styleCode.isEmpty {
            specifics["Style Code"] = analysis.identificationResult.styleCode
        }
        
        specifics["Condition"] = analysis.actualCondition
        
        return specifics
    }
    
    private func convertToSoldListings(_ itemSummaries: [EbayItemSummary]) -> [EbaySoldListing] {
        return itemSummaries.compactMap { summary in
            guard let price = summary.price?.value else { return nil }
            
            return EbaySoldListing(
                title: summary.title ?? "",
                price: price,
                condition: summary.condition ?? "",
                soldDate: Date(), // Would parse from summary if available
                shippingCost: summary.shippingOptions?.first?.shippingCost?.value,
                bestOffer: summary.buyingOptions?.contains("BEST_OFFER") ?? false,
                auction: summary.buyingOptions?.contains("AUCTION") ?? false,
                watchers: summary.watchCount
            )
        }
    }
    
    private func convertFindingResultsToSoldListings(_ response: EbayFindingResponse) -> [EbaySoldListing] {
        guard let searchResult = response.findCompletedItemsResponse?.first?.searchResult?.first,
              let items = searchResult.item else {
            return []
        }
        
        return items.compactMap { item in
            guard let sellingStatus = item.sellingStatus?.first,
                  let currentPrice = sellingStatus.currentPrice?.first,
                  let priceValue = Double(currentPrice.value ?? "0") else {
                return nil
            }
            
            let endTime = item.listingInfo?.first?.endTime?.first
            let soldDate = parseEbayDate(endTime) ?? Date()
            
            return EbaySoldListing(
                title: item.title?.first ?? "",
                price: priceValue,
                condition: item.condition?.first?.conditionDisplayName?.first ?? "",
                soldDate: soldDate,
                shippingCost: item.shippingInfo?.first?.shippingServiceCost?.first.flatMap { Double($0.value ?? "0") },
                bestOffer: false,
                auction: item.listingInfo?.first?.listingType?.first?.lowercased() == "auction",
                watchers: nil
            )
        }
    }
    
    private func parseEbayDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        let altFormatter = DateFormatter()
        altFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return altFormatter.date(from: dateString)
    }
    
    private func mapToCategoryID(_ category: String) -> String {
        // Map our categories to eBay category IDs
        switch category.lowercased() {
        case let cat where cat.contains("shoe") || cat.contains("sneaker"):
            return "15709" // Athletic Shoes
        case let cat where cat.contains("clothing"):
            return "11450" // Clothing
        case let cat where cat.contains("electronic"):
            return "58058" // Cell Phones & Smartphones
        case let cat where cat.contains("accessory"):
            return "169291" // Fashion Accessories
        default:
            return "267" // Everything Else
        }
    }
    
    private func mapConditionToEbayID(_ condition: EbayCondition) -> String {
        switch condition {
        case .newWithTags: return "1000"
        case .newWithoutTags: return "1500"
        case .newOther: return "1750"
        case .likeNew: return "2000"
        case .excellent: return "2500"
        case .veryGood: return "3000"
        case .good: return "4000"
        case .acceptable: return "5000"
        case .forPartsNotWorking: return "7000"
        }
    }
    
    // MARK: - Rate Limiting
    private func rateLimitedRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let now = Date()
        let timeSinceLastCall = now.timeIntervalSince(lastAPICall)
        
        if timeSinceLastCall < minAPIInterval {
            let delay = minAPIInterval - timeSinceLastCall
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                self.executeRequest(request, completion: completion)
            }
        } else {
            executeRequest(request, completion: completion)
        }
    }
    
    private func executeRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        lastAPICall = Date()
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        }.resume()
    }
}

// MARK: - eBay Data Models

struct EbaySearchResponse: Codable {
    let itemSummaries: [EbayItemSummary]?
    let total: Int?
    let limit: Int?
    let offset: Int?
}

struct EbayItemSummary: Codable {
    let itemId: String?
    let title: String?
    let price: EbayPrice?
    let condition: String?
    let categoryId: String?
    let buyingOptions: [String]?
    let shippingOptions: [EbayShippingOption]?
    let watchCount: Int?
    let image: EbayImage?
}

struct EbayPrice: Codable {
    let value: Double?
    let currency: String?
}

struct EbayShippingOption: Codable {
    let type: String?
    let shippingCost: EbayPrice?
}

struct EbayImage: Codable {
    let imageUrl: String?
}

struct EbayFindingResponse: Codable {
    let findCompletedItemsResponse: [EbayFindingResult]?
}

struct EbayFindingResult: Codable {
    let searchResult: [EbaySearchResult]?
}

struct EbaySearchResult: Codable {
    let item: [EbayFindingItem]?
}

struct EbayFindingItem: Codable {
    let title: [String]?
    let sellingStatus: [EbaySellingStatus]?
    let listingInfo: [EbayListingInfo]?
    let condition: [EbayConditionInfo]?
    let shippingInfo: [EbayShippingInfo]?
}

struct EbaySellingStatus: Codable {
    let currentPrice: [EbayCurrentPrice]?
}

struct EbayCurrentPrice: Codable {
    let value: String?
    let currencyId: String?
}

struct EbayListingInfo: Codable {
    let listingType: [String]?
    let endTime: [String]?
}

struct EbayConditionInfo: Codable {
    let conditionDisplayName: [String]?
}

struct EbayShippingInfo: Codable {
    let shippingServiceCost: [EbayCurrentPrice]?
}

struct EbayListingResponse: Codable {
    let sku: String?
    let statusCode: Int?
    let errors: [EbayError]?
}

struct EbayError: Codable {
    let errorId: String?
    let domain: String?
    let category: String?
    let message: String?
}

struct EbayListingResult {
    let success: Bool
    let listingId: String?
    let listingURL: String?
    let error: String?
}