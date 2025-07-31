//
//  EbayListingManager.swift
//  ResellAI
//
//  Created by Alec on 7/31/25.
//


import SwiftUI
import Foundation

// MARK: - Complete eBay Listing Manager
class EbayListingManager: ObservableObject {
    @Published var isListing = false
    @Published var listingProgress = "Ready to list"
    @Published var listingResults: [EbayListingResult] = []
    @Published var autoListingQueue: [InventoryItem] = []
    
    private let ebayAPIService = EbayAPIService()
    private let googleSheetsService = GoogleSheetsService()
    
    init() {
        print("🏪 eBay Listing Manager initialized")
    }
    
    // MARK: - Single Item Listing
    func listItemToEbay(
        item: InventoryItem,
        analysis: AnalysisResult,
        completion: @escaping (EbayListingResult) -> Void
    ) {
        
        print("🏪 Creating eBay listing for: \(item.name)")
        
        isListing = true
        listingProgress = "Creating eBay listing..."
        
        // Ensure eBay is authenticated
        if !ebayAPIService.isAuthenticated {
            ebayAPIService.authenticate { [weak self] success in
                if success {
                    self?.createListing(item: item, analysis: analysis, completion: completion)
                } else {
                    let result = EbayListingResult(
                        success: false,
                        listingId: nil,
                        listingURL: nil,
                        error: "eBay authentication failed"
                    )
                    completion(result)
                    self?.isListing = false
                }
            }
        } else {
            createListing(item: item, analysis: analysis, completion: completion)
        }
    }
    
    private func createListing(
        item: InventoryItem,
        analysis: AnalysisResult,
        completion: @escaping (EbayListingResult) -> Void
    ) {
        
        listingProgress = "Uploading images..."
        
        ebayAPIService.createListing(item: item, analysis: analysis) { [weak self] result in
            DispatchQueue.main.async {
                self?.isListing = false
                self?.listingProgress = result.success ? "✅ Listed successfully!" : "❌ Listing failed"
                
                // Store result
                self?.listingResults.append(result)
                
                // Update item with eBay listing info if successful
                if result.success {
                    self?.updateItemWithEbayInfo(item: item, result: result)
                }
                
                completion(result)
            }
        }
    }
    
    private func updateItemWithEbayInfo(item: InventoryItem, result: EbayListingResult) {
        var updatedItem = item
        updatedItem.ebayURL = result.listingURL
        updatedItem.status = .listed
        updatedItem.dateListed = Date()
        
        // Update in inventory and sync to Google Sheets
        // Note: This would need to be called from the InventoryManager
        googleSheetsService.updateItem(updatedItem)
        
        print("✅ Item updated with eBay listing: \(result.listingURL ?? "No URL")")
    }
    
    // MARK: - Batch Listing
    func listMultipleItems(
        items: [(item: InventoryItem, analysis: AnalysisResult)],
        completion: @escaping ([EbayListingResult]) -> Void
    ) {
        
        print("🏪 Batch listing \(items.count) items to eBay")
        
        isListing = true
        var results: [EbayListingResult] = []
        var completedCount = 0
        
        for (index, itemData) in items.enumerated() {
            listingProgress = "Listing item \(index + 1) of \(items.count)..."
            
            listItemToEbay(item: itemData.item, analysis: itemData.analysis) { result in
                results.append(result)
                completedCount += 1
                
                if completedCount == items.count {
                    DispatchQueue.main.async {
                        self.isListing = false
                        self.listingProgress = "Batch listing complete"
                        completion(results)
                    }
                }
            }
            
            // Add delay between listings to avoid rate limiting
            Thread.sleep(forTimeInterval: 1.0)
        }
    }
    
    // MARK: - Auto-Listing Queue Management
    func addToAutoListingQueue(_ item: InventoryItem) {
        if !autoListingQueue.contains(where: { $0.id == item.id }) {
            autoListingQueue.append(item)
            print("➕ Added \(item.name) to auto-listing queue")
        }
    }
    
    func removeFromAutoListingQueue(_ item: InventoryItem) {
        autoListingQueue.removeAll { $0.id == item.id }
        print("➖ Removed \(item.name) from auto-listing queue")
    }
    
    func processAutoListingQueue(completion: @escaping ([EbayListingResult]) -> Void) {
        guard !autoListingQueue.isEmpty else {
            completion([])
            return
        }
        
        print("🤖 Processing auto-listing queue: \(autoListingQueue.count) items")
        
        // Note: This would need analysis results for each item
        // In a real implementation, you'd either store analysis results with items
        // or re-analyze them here
        
        // For now, this is a placeholder that would need the analysis results
        completion([])
    }
    
    // MARK: - eBay Listing Templates
    func generateOptimizedTitle(for analysis: AnalysisResult) -> String {
        let brand = analysis.brand.isEmpty ? "" : "\(analysis.brand) "
        let model = analysis.itemName
        let size = analysis.identificationResult.size.isEmpty ? "" : " Size \(analysis.identificationResult.size)"
        let condition = " - \(analysis.actualCondition)"
        
        let title = "\(brand)\(model)\(size)\(condition)"
        
        // eBay title limit is 80 characters
        return String(title.prefix(80))
    }
    
    func generateOptimizedDescription(for item: InventoryItem, analysis: AnalysisResult) -> String {
        return """
        <div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0;">
                <h1 style="margin: 0; font-size: 28px;">\(analysis.itemName)</h1>
                <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Authenticated & AI-Verified</p>
            </div>
            
            <div style="background: white; padding: 30px; border-radius: 0 0 10px 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px;">
                    <div>
                        <h3 style="color: #333; border-bottom: 2px solid #667eea; padding-bottom: 10px;">Product Details</h3>
                        <ul style="list-style: none; padding: 0;">
                            <li style="padding: 8px 0; border-bottom: 1px solid #eee;"><strong>Brand:</strong> \(analysis.brand)</li>
                            <li style="padding: 8px 0; border-bottom: 1px solid #eee;"><strong>Model:</strong> \(analysis.itemName)</li>
                            <li style="padding: 8px 0; border-bottom: 1px solid #eee;"><strong>Size:</strong> \(item.size)</li>
                            <li style="padding: 8px 0; border-bottom: 1px solid #eee;"><strong>Color:</strong> \(item.colorway)</li>
                            <li style="padding: 8px 0; border-bottom: 1px solid #eee;"><strong>Style Code:</strong> \(analysis.identificationResult.styleCode)</li>
                        </ul>
                    </div>
                    
                    <div>
                        <h3 style="color: #333; border-bottom: 2px solid #667eea; padding-bottom: 10px;">Condition & Authentication</h3>
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 15px;">
                            <h4 style="color: #28a745; margin: 0 0 10px 0;">Condition: \(analysis.actualCondition)</h4>
                            <p style="margin: 0; color: #666;">\(analysis.ebayCondition.description)</p>
                        </div>
                        <div style="background: #e3f2fd; padding: 15px; border-radius: 8px;">
                            <h4 style="color: #1976d2; margin: 0 0 10px 0;">AI Authentication</h4>
                            <p style="margin: 0; color: #666;">Verified authentic using advanced AI analysis with \(String(format: "%.0f", analysis.confidence.overall * 100))% confidence.</p>
                        </div>
                    </div>
                </div>
                
                <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                    <h3 style="color: #333; margin-top: 0;">Market Analysis</h3>
                    <p>Based on analysis of <strong>\(analysis.soldListings.count) recent sales</strong>, this item is priced competitively at the current market rate.</p>
                </div>
                
                <div style="border: 2px solid #28a745; border-radius: 8px; padding: 20px; background: #f8fff8;">
                    <h3 style="color: #28a745; margin-top: 0;">Why Buy From Us?</h3>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <div>
                            <p style="margin: 5px 0;"><strong>✅ AI-Verified Authentic</strong></p>
                            <p style="margin: 5px 0;"><strong>✅ Professional Photos</strong></p>
                            <p style="margin: 5px 0;"><strong>✅ Fast & Secure Shipping</strong></p>
                        </div>
                        <div>
                            <p style="margin: 5px 0;"><strong>✅ 30-Day Returns</strong></p>
                            <p style="margin: 5px 0;"><strong>✅ Excellent Customer Service</strong></p>
                            <p style="margin: 5px 0;"><strong>✅ 100% Satisfaction Guarantee</strong></p>
                        </div>
                    </div>
                </div>
                
                <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                    <p style="color: #666; margin: 0;">Questions? Message us anytime - we respond quickly!</p>
                </div>
            </div>
        </div>
        
        <div style="margin-top: 20px; padding: 15px; background: #263238; color: white; text-align: center; border-radius: 8px;">
            <p style="margin: 0;"><strong>Keywords:</strong> \(analysis.keywords.joined(separator: " • "))</p>
        </div>
        """
    }
    
    func generateItemSpecifics(for item: InventoryItem, analysis: AnalysisResult) -> [String: String] {
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
        
        if !analysis.identificationResult.productLine.isEmpty {
            specifics["Product Line"] = analysis.identificationResult.productLine
        }
        
        specifics["Condition"] = analysis.actualCondition
        specifics["Authentication"] = "AI Verified"
        
        return specifics
    }
    
    // MARK: - eBay Category Mapping
    func getEbayCategory(for analysis: AnalysisResult) -> String {
        switch analysis.identificationResult.category {
        case .sneakers:
            return "15709" // Athletic Shoes
        case .clothing:
            return "11450" // Men's Clothing (would need gender detection)
        case .electronics:
            if analysis.brand.lowercased().contains("apple") {
                return "9355" // Apple Products
            }
            return "58058" // Cell Phones & Smartphones
        case .accessories:
            return "169291" // Fashion Accessories
        case .home:
            return "11700" // Home & Garden
        case .collectibles:
            return "1" // Collectibles
        case .books:
            return "267" // Books & Magazines
        case .toys:
            return "220" // Toys & Hobbies
        case .sports:
            return "888" // Sporting Goods
        case .other:
            return "267" // Everything Else
        }
    }
    
    // MARK: - Listing Analytics
    func getListingPerformance() -> ListingPerformance {
        let totalListings = listingResults.count
        let successfulListings = listingResults.filter { $0.success }.count
        let failedListings = totalListings - successfulListings
        
        return ListingPerformance(
            totalListings: totalListings,
            successfulListings: successfulListings,
            failedListings: failedListings,
            successRate: totalListings > 0 ? Double(successfulListings) / Double(totalListings) * 100 : 0
        )
    }
    
    func getRecentListings() -> [EbayListingResult] {
        return Array(listingResults.suffix(10))
    }
    
    // MARK: - Error Handling
    func retryFailedListing(_ item: InventoryItem, analysis: AnalysisResult, completion: @escaping (EbayListingResult) -> Void) {
        print("🔄 Retrying failed eBay listing for: \(item.name)")
        
        // Remove previous failed result if exists
        listingResults.removeAll { result in
            result.listingId == item.inventoryCode && !result.success
        }
        
        // Retry the listing
        listItemToEbay(item: item, analysis: analysis, completion: completion)
    }
    
    // MARK: - Listing Management
    func updateListingStatus(_ listingId: String, newStatus: ItemStatus) {
        if let index = listingResults.firstIndex(where: { $0.listingId == listingId }) {
            // Update listing status
            print("📊 Updated listing \(listingId) status to \(newStatus.rawValue)")
        }
    }
    
    func getListingURL(for item: InventoryItem) -> String? {
        return listingResults.first { result in
            result.listingId == "RESELLAI-\(item.inventoryCode)" && result.success
        }?.listingURL
    }
}

// MARK: - Supporting Data Structures
struct ListingPerformance {
    let totalListings: Int
    let successfulListings: Int
    let failedListings: Int
    let successRate: Double
}

struct EbayListingTemplate {
    let title: String
    let description: String
    let itemSpecifics: [String: String]
    let categoryId: String
    let conditionId: String
    let startingPrice: Double
    let buyItNowPrice: Double
    let listingDuration: String
    let shippingPolicy: String
    let returnPolicy: String
}

// MARK: - eBay Listing Helper Functions
extension EbayListingManager {
    
    func createListingTemplate(for item: InventoryItem, analysis: AnalysisResult) -> EbayListingTemplate {
        return EbayListingTemplate(
            title: generateOptimizedTitle(for: analysis),
            description: generateOptimizedDescription(for: item, analysis: analysis),
            itemSpecifics: generateItemSpecifics(for: item, analysis: analysis),
            categoryId: getEbayCategory(for: analysis),
            conditionId: mapConditionToEbayID(analysis.ebayCondition),
            startingPrice: analysis.quickSalePrice,
            buyItNowPrice: analysis.realisticPrice,
            listingDuration: "Days_7",
            shippingPolicy: "Standard",
            returnPolicy: "30 days"
        )
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
    
    func validateListingData(for item: InventoryItem, analysis: AnalysisResult) -> [String] {
        var errors: [String] = []
        
        if analysis.itemName.isEmpty {
            errors.append("Item name is required")
        }
        
        if analysis.brand.isEmpty {
            errors.append("Brand is required for better listing performance")
        }
        
        if item.imageData == nil {
            errors.append("At least one photo is required")
        }
        
        if analysis.realisticPrice <= 0 {
            errors.append("Valid price is required")
        }
        
        return errors
    }
}

// MARK: - eBay Listing Queue Management
class EbayListingQueue: ObservableObject {
    @Published var queuedItems: [(item: InventoryItem, analysis: AnalysisResult)] = []
    @Published var isProcessing = false
    
    private let listingManager = EbayListingManager()
    
    func addToQueue(item: InventoryItem, analysis: AnalysisResult) {
        queuedItems.append((item: item, analysis: analysis))
        print("📋 Added \(item.name) to listing queue")
    }
    
    func removeFromQueue(item: InventoryItem) {
        queuedItems.removeAll { $0.item.id == item.id }
        print("📋 Removed \(item.name) from listing queue")
    }
    
    func processQueue(completion: @escaping ([EbayListingResult]) -> Void) {
        guard !queuedItems.isEmpty && !isProcessing else {
            completion([])
            return
        }
        
        isProcessing = true
        
        listingManager.listMultipleItems(items: queuedItems) { [weak self] results in
            DispatchQueue.main.async {
                self?.isProcessing = false
                self?.queuedItems.removeAll()
                completion(results)
            }
        }
    }
    
    var queueCount: Int { queuedItems.count }
}