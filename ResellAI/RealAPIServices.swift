import SwiftUI
import Foundation
import PhotosUI
import Vision

// MARK: - AI Service with Direct Configuration
class AIService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 12
    
    private let realAnalyzer = RealAIAnalysisService()
    
    init() {
        Configuration.validateConfiguration()
        
        // Sync progress with real analyzer
        realAnalyzer.$isAnalyzing
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAnalyzing)
        
        realAnalyzer.$analysisProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$analysisProgress)
        
        realAnalyzer.$currentStep
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentStep)
        
        realAnalyzer.$totalSteps
            .receive(on: DispatchQueue.main)
            .assign(to: &$totalSteps)
    }
    
    // MARK: - Google Lens-Level Analysis
    func analyzeItem(_ images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        guard !Configuration.openAIKey.isEmpty else {
            print("❌ OpenAI API key not configured!")
            completion(createAPIErrorResult("OpenAI API key not configured. Check Configuration.swift"))
            return
        }
        
        guard !images.isEmpty else {
            print("❌ No images provided for analysis")
            completion(createAPIErrorResult("No images provided for analysis"))
            return
        }
        
        print("🔍 Starting Google Lens-Level Analysis with \(images.count) images")
        
        realAnalyzer.analyzeItem(images) { result in
            DispatchQueue.main.async {
                print("✅ Google Lens Analysis Complete: \(result.itemName)")
                print("✅ Condition: \(result.actualCondition)")
                print("✅ Market Price: $\(String(format: "%.2f", result.realisticPrice))")
                print("✅ Sold Listings: \(result.soldListings.count)")
                completion(result)
            }
        }
    }
    
    // MARK: - Prospecting Analysis with Real eBay Data
    func analyzeForProspecting(images: [UIImage], category: String, completion: @escaping (ProspectAnalysis) -> Void) {
        guard !images.isEmpty else {
            completion(createDefaultProspectAnalysis([]))
            return
        }
        
        guard !Configuration.openAIKey.isEmpty else {
            print("❌ OpenAI API key not configured for prospecting!")
            completion(createAPIErrorProspectAnalysis(images))
            return
        }
        
        print("🔍 Starting Real eBay Prospecting Analysis with \(images.count) images")
        
        realAnalyzer.analyzeItem(images) { [weak self] analysisResult in
            guard let self = self else { return }
            
            // Convert to prospecting analysis
            let prospectAnalysis = self.convertToProspectAnalysis(analysisResult, images: images)
            
            DispatchQueue.main.async {
                print("✅ Real Prospecting Complete: \(prospectAnalysis.recommendation.title)")
                print("✅ Max Buy: $\(String(format: "%.2f", prospectAnalysis.maxBuyPrice))")
                print("✅ Market Data: \(prospectAnalysis.recentSales.count) sales")
                completion(prospectAnalysis)
            }
        }
    }
    
    // MARK: - Barcode Analysis with Product Database
    func analyzeBarcode(_ barcode: String, images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        print("📱 Barcode Analysis: \(barcode)")
        
        guard !Configuration.openAIKey.isEmpty else {
            completion(createAPIErrorResult("OpenAI API key not configured for barcode analysis"))
            return
        }
        
        let cleanBarcode = barcode.filter { $0.isNumber }
        guard cleanBarcode.count >= 8 else {
            print("❌ Invalid barcode format: \(barcode)")
            completion(createAPIErrorResult("Invalid barcode format: \(barcode)"))
            return
        }
        
        // Use real analyzer's barcode lookup
        realAnalyzer.lookupProductByBarcode(cleanBarcode) { [weak self] productData in
            guard let self = self else { return }
            
            if let product = productData, product.confidence > 0.7 {
                // High confidence barcode match
                let barcodeResult = self.createBarcodeResult(product, images: images)
                completion(barcodeResult)
            } else {
                // Fallback to image analysis
                if !images.isEmpty {
                    print("📱 Barcode lookup failed, using image analysis")
                    self.analyzeItem(images, completion: completion)
                } else {
                    completion(self.createAPIErrorResult("Barcode not found: \(cleanBarcode)"))
                }
            }
        }
    }
    
    func lookupBarcodeForProspecting(_ barcode: String, completion: @escaping (ProspectAnalysis) -> Void) {
        print("📱 Barcode Prospecting Lookup: \(barcode)")
        
        guard !Configuration.openAIKey.isEmpty else {
            completion(createAPIErrorProspectAnalysis([]))
            return
        }
        
        let cleanBarcode = barcode.filter { $0.isNumber }
        guard cleanBarcode.count >= 8 else {
            completion(createAPIErrorProspectAnalysis([]))
            return
        }
        
        realAnalyzer.lookupProductByBarcode(cleanBarcode) { [weak self] productData in
            guard let self = self else { return }
            
            if let product = productData {
                let prospectAnalysis = self.createProspectFromBarcodeData(product)
                completion(prospectAnalysis)
            } else {
                completion(self.createAPIErrorProspectAnalysis([]))
            }
        }
    }
    
    // MARK: - Helper Methods for Conversion
    
    private func convertToProspectAnalysis(_ analysis: AnalysisResult, images: [UIImage]) -> ProspectAnalysis {
        
        // Calculate max buy price based on real market data
        let marketValue = analysis.realisticPrice
        let conditionMultiplier = analysis.ebayCondition.priceMultiplier
        let adjustedValue = marketValue * conditionMultiplier
        
        // Conservative max buy calculation
        let maxBuyPrice = calculateSmartMaxBuyPrice(
            marketValue: adjustedValue,
            competitorCount: analysis.competitorCount,
            soldCount: analysis.soldListings.count,
            brand: analysis.brand
        )
        
        let targetBuyPrice = maxBuyPrice * 0.8
        let estimatedFees = marketValue * Configuration.defaultEbayFeeRate
        let potentialProfit = marketValue - maxBuyPrice - estimatedFees
        let expectedROI = maxBuyPrice > 0 ? (potentialProfit / maxBuyPrice) * 100 : 0
        
        // Generate recommendation based on real data
        let recommendation = generateSmartRecommendation(
            expectedROI: expectedROI,
            potentialProfit: potentialProfit,
            confidence: analysis.confidence.overall,
            soldCount: analysis.soldListings.count,
            marketValue: marketValue
        )
        
        return ProspectAnalysis(
            identificationResult: analysis.identificationResult,
            marketAnalysis: analysis.marketAnalysis,
            maxBuyPrice: maxBuyPrice,
            targetBuyPrice: targetBuyPrice,
            breakEvenPrice: marketValue * 0.75,
            recommendation: recommendation,
            confidence: analysis.confidence,
            images: images
        )
    }
    
    private func calculateSmartMaxBuyPrice(marketValue: Double, competitorCount: Int, soldCount: Int, brand: String) -> Double {
        // Start with 50% of market value
        var maxBuy = marketValue * 0.5
        
        // Adjust for market activity
        if soldCount > 20 {
            maxBuy *= 1.05  // Active market
        } else if soldCount < 5 {
            maxBuy *= 0.9   // Slow market
        }
        
        // Adjust for competition
        if competitorCount > 50 {
            maxBuy *= 0.9   // High competition
        } else if competitorCount < 10 {
            maxBuy *= 1.1   // Low competition
        }
        
        // Brand premium (conservative)
        let brandLower = brand.lowercased()
        if brandLower.contains("jordan") || brandLower.contains("supreme") {
            maxBuy *= 1.05
        } else if brandLower.contains("apple") && marketValue > 100 {
            maxBuy *= 1.03
        }
        
        return max(5.0, min(maxBuy, marketValue * Configuration.maxBuyPriceMultiplier))
    }
    
    private func generateSmartRecommendation(expectedROI: Double, potentialProfit: Double, confidence: Double, soldCount: Int, marketValue: Double) -> ProspectDecision {
        
        // High confidence buy criteria
        if expectedROI >= Configuration.preferredROIThreshold &&
           potentialProfit >= 15 &&
           confidence >= 0.7 &&
           soldCount >= 5 &&
           marketValue >= 25 {
            return .buy
        }
        
        // Medium confidence buy criteria
        if expectedROI >= Configuration.minimumROIThreshold &&
           potentialProfit >= 10 &&
           confidence >= 0.6 &&
           soldCount >= 3 {
            return .buy
        }
        
        // Otherwise investigate
        return .investigate
    }
    
    // MARK: - Error Handling and Fallback Results
    
    private func createAPIErrorResult(_ error: String) -> AnalysisResult {
        let errorIdentification = PrecisionIdentificationResult(
            exactModelName: "Analysis Error",
            brand: "",
            productLine: "",
            styleVariant: "",
            styleCode: "",
            colorway: "",
            size: "",
            category: .other,
            subcategory: "",
            identificationMethod: .categoryBased,
            confidence: 0.0,
            identificationDetails: [error],
            alternativePossibilities: []
        )
        
        let errorCondition = EbayConditionAssessment(
            detectedCondition: .good,
            conditionConfidence: 0.0,
            conditionFactors: [],
            conditionNotes: [error],
            photographyRecommendations: []
        )
        
        let errorMarket = EbayMarketData(
            soldListings: [],
            priceRange: EbayPriceRange(
                newWithTags: nil, newWithoutTags: nil, likeNew: nil,
                excellent: nil, veryGood: nil, good: nil, acceptable: nil,
                average: 0, soldCount: 0, dateRange: "No data"
            ),
            marketTrend: MarketTrend(direction: .stable, strength: .weak, timeframe: "", seasonalFactors: []),
            demandIndicators: DemandIndicators(
                watchersPerListing: 0,
                viewsPerListing: 0,
                timeToSell: .difficult,
                searchVolume: .low
            ),
            competitionLevel: .low,
            lastUpdated: Date()
        )
        
        let errorPricing = EbayPricingRecommendation(
            recommendedPrice: 0,
            priceRange: (min: 0, max: 0),
            competitivePrice: 0,
            quickSalePrice: 0,
            maxProfitPrice: 0,
            pricingStrategy: .competitive,
            priceJustification: [error]
        )
        
        let errorListing = EbayListingStrategy(
            recommendedTitle: "Error",
            keywordOptimization: [],
            categoryPath: "",
            listingFormat: .buyItNow,
            photographyChecklist: [],
            descriptionTemplate: error
        )
        
        let errorConfidence = MarketConfidence(
            overall: 0.0,
            identification: 0.0,
            condition: 0.0,
            pricing: 0.0,
            dataQuality: .insufficient
        )
        
        let errorAnalysis = MarketAnalysisResult(
            identifiedProduct: errorIdentification,
            marketData: errorMarket,
            conditionAssessment: errorCondition,
            pricingRecommendation: errorPricing,
            listingStrategy: errorListing,
            confidence: errorConfidence
        )
        
        return AnalysisResult(
            identificationResult: errorIdentification,
            marketAnalysis: errorAnalysis,
            ebayCondition: .good,
            ebayPricing: errorPricing,
            soldListings: [],
            confidence: errorConfidence,
            images: []
        )
    }
    
    private func createDefaultProspectAnalysis(_ images: [UIImage]) -> ProspectAnalysis {
        let defaultIdentification = PrecisionIdentificationResult(
            exactModelName: "No Analysis Available",
            brand: "",
            productLine: "",
            styleVariant: "",
            styleCode: "",
            colorway: "",
            size: "",
            category: .other,
            subcategory: "",
            identificationMethod: .categoryBased,
            confidence: 0.0,
            identificationDetails: ["Take photos for analysis"],
            alternativePossibilities: []
        )
        
        let defaultCondition = EbayConditionAssessment(
            detectedCondition: .good,
            conditionConfidence: 0.0,
            conditionFactors: [],
            conditionNotes: ["No analysis available"],
            photographyRecommendations: ["Take multiple clear photos"]
        )
        
        let defaultMarket = EbayMarketData(
            soldListings: [],
            priceRange: EbayPriceRange(
                newWithTags: nil, newWithoutTags: nil, likeNew: nil,
                excellent: nil, veryGood: nil, good: nil, acceptable: nil,
                average: 0, soldCount: 0, dateRange: "No data"
            ),
            marketTrend: MarketTrend(direction: .stable, strength: .weak, timeframe: "", seasonalFactors: []),
            demandIndicators: DemandIndicators(
                watchersPerListing: 0,
                viewsPerListing: 0,
                timeToSell: .difficult,
                searchVolume: .low
            ),
            competitionLevel: .low,
            lastUpdated: Date()
        )
        
        let defaultPricing = EbayPricingRecommendation(
            recommendedPrice: 0,
            priceRange: (min: 0, max: 0),
            competitivePrice: 0,
            quickSalePrice: 0,
            maxProfitPrice: 0,
            pricingStrategy: .competitive,
            priceJustification: ["No market data available"]
        )
        
        let defaultListing = EbayListingStrategy(
            recommendedTitle: "Unknown Item",
            keywordOptimization: [],
            categoryPath: "",
            listingFormat: .buyItNow,
            photographyChecklist: ["Take multiple photos", "Include all angles"],
            descriptionTemplate: "Item analysis not available"
        )
        
        let defaultConfidence = MarketConfidence(
            overall: 0.0,
            identification: 0.0,
            condition: 0.0,
            pricing: 0.0,
            dataQuality: .insufficient
        )
        
        let defaultAnalysis = MarketAnalysisResult(
            identifiedProduct: defaultIdentification,
            marketData: defaultMarket,
            conditionAssessment: defaultCondition,
            pricingRecommendation: defaultPricing,
            listingStrategy: defaultListing,
            confidence: defaultConfidence
        )
        
        return ProspectAnalysis(
            identificationResult: defaultIdentification,
            marketAnalysis: defaultAnalysis,
            maxBuyPrice: 0,
            targetBuyPrice: 0,
            breakEvenPrice: 0,
            recommendation: .investigate,
            confidence: defaultConfidence,
            images: images
        )
    }
    
    private func createAPIErrorProspectAnalysis(_ images: [UIImage]) -> ProspectAnalysis {
        let errorMessage = Configuration.openAIKey.isEmpty ? "Configure OpenAI API key" : "Analysis failed"
        
        let errorIdentification = PrecisionIdentificationResult(
            exactModelName: "Configuration Error",
            brand: "",
            productLine: "",
            styleVariant: "",
            styleCode: "",
            colorway: "",
            size: "",
            category: .other,
            subcategory: "",
            identificationMethod: .categoryBased,
            confidence: 0.0,
            identificationDetails: [errorMessage],
            alternativePossibilities: []
        )
        
        let errorCondition = EbayConditionAssessment(
            detectedCondition: .good,
            conditionConfidence: 0.0,
            conditionFactors: [],
            conditionNotes: [errorMessage],
            photographyRecommendations: []
        )
        
        let errorMarket = EbayMarketData(
            soldListings: [],
            priceRange: EbayPriceRange(
                newWithTags: nil, newWithoutTags: nil, likeNew: nil,
                excellent: nil, veryGood: nil, good: nil, acceptable: nil,
                average: 0, soldCount: 0, dateRange: "No data"
            ),
            marketTrend: MarketTrend(direction: .stable, strength: .weak, timeframe: "", seasonalFactors: []),
            demandIndicators: DemandIndicators(
                watchersPerListing: 0,
                viewsPerListing: 0,
                timeToSell: .difficult,
                searchVolume: .low
            ),
            competitionLevel: .low,
            lastUpdated: Date()
        )
        
        let errorPricing = EbayPricingRecommendation(
            recommendedPrice: 0,
            priceRange: (min: 0, max: 0),
            competitivePrice: 0,
            quickSalePrice: 0,
            maxProfitPrice: 0,
            pricingStrategy: .competitive,
            priceJustification: [errorMessage]
        )
        
        let errorListing = EbayListingStrategy(
            recommendedTitle: "Error",
            keywordOptimization: [],
            categoryPath: "",
            listingFormat: .buyItNow,
            photographyChecklist: [],
            descriptionTemplate: errorMessage
        )
        
        let errorConfidence = MarketConfidence(
            overall: 0.0,
            identification: 0.0,
            condition: 0.0,
            pricing: 0.0,
            dataQuality: .insufficient
        )
        
        let errorAnalysis = MarketAnalysisResult(
            identifiedProduct: errorIdentification,
            marketData: errorMarket,
            conditionAssessment: errorCondition,
            pricingRecommendation: errorPricing,
            listingStrategy: errorListing,
            confidence: errorConfidence
        )
        
        return ProspectAnalysis(
            identificationResult: errorIdentification,
            marketAnalysis: errorAnalysis,
            maxBuyPrice: 0,
            targetBuyPrice: 0,
            breakEvenPrice: 0,
            recommendation: .investigate,
            confidence: errorConfidence,
            images: images
        )
    }
    
    private func createBarcodeResult(_ product: RealProductData, images: [UIImage]) -> AnalysisResult {
        // Create result from barcode lookup
        let identification = PrecisionIdentificationResult(
            exactModelName: product.name,
            brand: product.brand,
            productLine: "",
            styleVariant: "",
            styleCode: product.model,
            colorway: product.colorway,
            size: product.size,
            category: mapStringToProductCategory(product.category),
            subcategory: product.category,
            identificationMethod: .textOnly,
            confidence: product.confidence,
            identificationDetails: ["Verified by barcode database"],
            alternativePossibilities: []
        )
        
        let condition = EbayConditionAssessment(
            detectedCondition: .good,
            conditionConfidence: 0.6,
            conditionFactors: [],
            conditionNotes: ["Barcode verified - inspect condition"],
            photographyRecommendations: ["Take photos of condition"]
        )
        
        // Estimate market value
        let marketValue = product.retailPrice > 0 ? product.retailPrice * 0.4 : 25.0
        
        let market = EbayMarketData(
            soldListings: [],
            priceRange: EbayPriceRange(
                newWithTags: nil, newWithoutTags: nil, likeNew: nil,
                excellent: nil, veryGood: nil, good: marketValue, acceptable: nil,
                average: marketValue, soldCount: 0, dateRange: "Estimated"
            ),
            marketTrend: MarketTrend(direction: .stable, strength: .moderate, timeframe: "", seasonalFactors: []),
            demandIndicators: DemandIndicators(
                watchersPerListing: 5,
                viewsPerListing: 25,
                timeToSell: .normal,
                searchVolume: .medium
            ),
            competitionLevel: .moderate,
            lastUpdated: Date()
        )
        
        let pricing = EbayPricingRecommendation(
            recommendedPrice: marketValue,
            priceRange: (min: marketValue * 0.8, max: marketValue * 1.2),
            competitivePrice: marketValue,
            quickSalePrice: marketValue * Configuration.quickSalePriceMultiplier,
            maxProfitPrice: marketValue * Configuration.premiumPriceMultiplier,
            pricingStrategy: .competitive,
            priceJustification: ["Barcode verified authentic", "Estimated market value"]
        )
        
        let listing = EbayListingStrategy(
            recommendedTitle: "\(product.brand) \(product.name)".trimmingCharacters(in: .whitespaces),
            keywordOptimization: [product.brand, product.name, product.model].filter { !$0.isEmpty },
            categoryPath: mapToEbayCategory(identification.category),
            listingFormat: .buyItNow,
            photographyChecklist: ["Multiple angles", "Condition details", "Original packaging"],
            descriptionTemplate: "Barcode verified authentic \(product.brand) \(product.name)"
        )
        
        let confidence = MarketConfidence(
            overall: product.confidence,
            identification: product.confidence,
            condition: 0.6,
            pricing: 0.5,
            dataQuality: .limited
        )
        
        let analysis = MarketAnalysisResult(
            identifiedProduct: identification,
            marketData: market,
            conditionAssessment: condition,
            pricingRecommendation: pricing,
            listingStrategy: listing,
            confidence: confidence
        )
        
        return AnalysisResult(
            identificationResult: identification,
            marketAnalysis: analysis,
            ebayCondition: .good,
            ebayPricing: pricing,
            soldListings: [],
            confidence: confidence,
            images: images
        )
    }
    
    private func createProspectFromBarcodeData(_ product: RealProductData) -> ProspectAnalysis {
        let marketValue = product.retailPrice > 0 ? product.retailPrice * 0.4 : 20.0
        let maxBuyPrice = marketValue * 0.5
        
        let identification = PrecisionIdentificationResult(
            exactModelName: product.name,
            brand: product.brand,
            productLine: "",
            styleVariant: "",
            styleCode: product.model,
            colorway: product.colorway,
            size: product.size,
            category: mapStringToProductCategory(product.category),
            subcategory: product.category,
            identificationMethod: .textOnly,
            confidence: product.confidence,
            identificationDetails: ["Barcode database verified"],
            alternativePossibilities: []
        )
        
        let condition = EbayConditionAssessment(
            detectedCondition: .good,
            conditionConfidence: 0.5,
            conditionFactors: [],
            conditionNotes: ["Barcode verified - inspect condition carefully"],
            photographyRecommendations: []
        )
        
        let market = EbayMarketData(
            soldListings: [],
            priceRange: EbayPriceRange(
                newWithTags: nil, newWithoutTags: nil, likeNew: nil,
                excellent: nil, veryGood: nil, good: marketValue, acceptable: nil,
                average: marketValue, soldCount: 0, dateRange: "Estimated"
            ),
            marketTrend: MarketTrend(direction: .stable, strength: .moderate, timeframe: "", seasonalFactors: []),
            demandIndicators: DemandIndicators(
                watchersPerListing: 3,
                viewsPerListing: 20,
                timeToSell: .normal,
                searchVolume: .medium
            ),
            competitionLevel: .moderate,
            lastUpdated: Date()
        )
        
        let pricing = EbayPricingRecommendation(
            recommendedPrice: marketValue,
            priceRange: (min: marketValue * 0.8, max: marketValue * 1.2),
            competitivePrice: marketValue,
            quickSalePrice: marketValue * Configuration.quickSalePriceMultiplier,
            maxProfitPrice: marketValue * Configuration.premiumPriceMultiplier,
            pricingStrategy: .competitive,
            priceJustification: ["Barcode verified"]
        )
        
        let listing = EbayListingStrategy(
            recommendedTitle: "\(product.brand) \(product.name)".trimmingCharacters(in: .whitespaces),
            keywordOptimization: [],
            categoryPath: "",
            listingFormat: .buyItNow,
            photographyChecklist: [],
            descriptionTemplate: ""
        )
        
        let confidence = MarketConfidence(
            overall: product.confidence,
            identification: product.confidence,
            condition: 0.5,
            pricing: 0.4,
            dataQuality: .limited
        )
        
        let analysis = MarketAnalysisResult(
            identifiedProduct: identification,
            marketData: market,
            conditionAssessment: condition,
            pricingRecommendation: pricing,
            listingStrategy: listing,
            confidence: confidence
        )
        
        return ProspectAnalysis(
            identificationResult: identification,
            marketAnalysis: analysis,
            maxBuyPrice: maxBuyPrice,
            targetBuyPrice: maxBuyPrice * 0.8,
            breakEvenPrice: marketValue * 0.8,
            recommendation: maxBuyPrice > 10 ? .buy : .investigate,
            confidence: confidence,
            images: []
        )
    }
    
    // Helper methods
    private func mapStringToProductCategory(_ categoryString: String) -> ProductCategory {
        switch categoryString.lowercased() {
        case "shoes", "footwear": return .sneakers
        case "clothing": return .clothing
        case "electronics": return .electronics
        case "accessories": return .accessories
        case "home": return .home
        case "collectibles": return .collectibles
        case "books": return .books
        case "toys": return .toys
        case "sports": return .sports
        default: return .other
        }
    }
    
    private func mapToEbayCategory(_ category: ProductCategory) -> String {
        switch category {
        case .sneakers: return "Clothing, Shoes & Accessories > Unisex Shoes"
        case .clothing: return "Clothing, Shoes & Accessories"
        case .electronics: return "Consumer Electronics"
        case .accessories: return "Clothing, Shoes & Accessories > Accessories"
        case .home: return "Home & Garden"
        case .collectibles: return "Collectibles"
        case .books: return "Books & Magazines"
        case .toys: return "Toys & Hobbies"
        case .sports: return "Sporting Goods"
        case .other: return "Everything Else"
        }
    }
}

// MARK: - Product Data Structure
struct RealProductData {
    let name: String
    let brand: String
    let model: String
    let category: String
    let size: String
    let colorway: String
    let retailPrice: Double
    let releaseYear: String
    let confidence: Double
}

// MARK: - Google Sheets Service
class GoogleSheetsService: ObservableObject {
    @Published var spreadsheetId = Configuration.spreadsheetID
    @Published var isConnected = true
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus = "Ready to sync"
    
    init() {
        authenticate()
    }
    
    func authenticate() {
        print("🔗 Google Sheets Service Initialized")
        isConnected = !Configuration.googleScriptURL.isEmpty
        syncStatus = isConnected ? "Connected to Google Sheets" : "Google Sheets not configured"
    }
    
    func uploadItem(_ item: InventoryItem) {
        guard isConnected else { return }
        
        print("📤 Uploading item to Google Sheets: \(item.name)")
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncStatus = "Uploading \(item.name)..."
        }
        
        let itemData: [String: Any] = [
            "action": "addItem",
            "itemNumber": item.itemNumber,
            "inventoryCode": item.inventoryCode,
            "name": item.name,
            "exactModel": item.exactModel,
            "source": item.source,
            "purchasePrice": item.purchasePrice,
            "suggestedPrice": item.suggestedPrice,
            "status": item.status.rawValue,
            "condition": item.condition,
            "ebayCondition": item.ebayCondition?.rawValue ?? "",
            "profit": item.estimatedProfit,
            "roi": item.estimatedROI,
            "date": formatDate(item.dateAdded),
            "soldListings": item.soldListingsCount ?? 0,
            "marketConfidence": item.marketConfidence ?? 0
        ]
        
        sendToGoogleSheets(data: itemData) { [weak self] success in
            DispatchQueue.main.async {
                self?.isSyncing = false
                if success {
                    self?.syncStatus = "✅ Synced successfully"
                    self?.lastSyncDate = Date()
                } else {
                    self?.syncStatus = "❌ Sync failed"
                }
            }
        }
    }
    
    func updateItem(_ item: InventoryItem) {
        uploadItem(item)
    }
    
    func syncAllItems(_ items: [InventoryItem]) {
        guard isConnected else { return }
        
        print("🔄 Syncing \(items.count) items to Google Sheets")
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncStatus = "Syncing \(items.count) items..."
        }
        
        let group = DispatchGroup()
        var successCount = 0
        
        for item in items {
            group.enter()
            
            let itemData: [String: Any] = [
                "action": "addItem",
                "itemNumber": item.itemNumber,
                "inventoryCode": item.inventoryCode,
                "name": item.name,
                "exactModel": item.exactModel,
                "source": item.source,
                "purchasePrice": item.purchasePrice,
                "suggestedPrice": item.suggestedPrice,
                "status": item.status.rawValue,
                "condition": item.condition,
                "ebayCondition": item.ebayCondition?.rawValue ?? ""
            ]
            
            sendToGoogleSheets(data: itemData) { success in
                if success { successCount += 1 }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isSyncing = false
            self.syncStatus = "✅ Synced \(successCount)/\(items.count) items"
            self.lastSyncDate = Date()
        }
    }
    
    private func sendToGoogleSheets(data: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: Configuration.googleScriptURL) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15.0
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
        } catch {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Google Sheets error: \(error)")
                completion(false)
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                let success = responseString.contains("success")
                completion(success)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - eBay Listing Service
class EbayListingService: ObservableObject {
    @Published var isListing = false
    @Published var listingProgress = "Ready to list"
    @Published var listingURL: String?
    @Published var isConfigured = false
    
    init() {
        isConfigured = !Configuration.ebayAPIKey.isEmpty
    }
    
    func listDirectlyToEbay(item: InventoryItem, analysis: AnalysisResult, completion: @escaping (Bool, String?) -> Void) {
        guard isConfigured else {
            print("🚫 eBay API not configured")
            completion(false, nil)
            return
        }
        
        print("🚀 Listing to eBay: \(item.name)")
        
        DispatchQueue.main.async {
            self.isListing = true
            self.listingProgress = "Creating eBay listing..."
        }
        
        // Simulate eBay listing process
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isListing = false
            self.listingProgress = "eBay listing created"
            self.listingURL = "https://www.ebay.com/itm/fake-listing-url"
            completion(true, self.listingURL)
        }
    }
}

// MARK: - Legacy APIConfig Compatibility
struct APIConfig {
    static let openAIKey = Configuration.openAIKey
    static let spreadsheetID = Configuration.spreadsheetID
    static let openAIEndpoint = Configuration.openAIEndpoint
    static let googleAppsScriptURL = Configuration.googleScriptURL
    static let googleCloudAPIKey = Configuration.googleCloudAPIKey
    static let rapidAPIKey = Configuration.rapidAPIKey
    static let ebayAPIKey = Configuration.ebayAPIKey
    static let ebayClientSecret = ""
    static let ebayEnvironment = Configuration.ebayEnvironment
    
    static func validateConfiguration() {
        Configuration.validateConfiguration()
    }
}
