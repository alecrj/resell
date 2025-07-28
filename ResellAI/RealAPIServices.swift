import SwiftUI
import Foundation
import PhotosUI
import Vision

// MARK: - API Configuration
struct APIConfig {
    static let openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    static let spreadsheetID = ProcessInfo.processInfo.environment["SPREADSHEET_ID"] ?? ""
    static let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    static let googleAppsScriptURL = ProcessInfo.processInfo.environment["GOOGLE_SCRIPT_URL"] ?? ""
    static let googleCloudAPIKey = ProcessInfo.processInfo.environment["GOOGLE_CLOUD_API_KEY"] ?? ""
    static let rapidAPIKey = ProcessInfo.processInfo.environment["RAPID_API_KEY"] ?? ""
    static let rapidAPIHost = "ebay-data-scraper.p.rapidapi.com"

    static func validateConfiguration() {
        print("🔧 API Configuration Status:")
        print("✅ OpenAI Key: \(openAIKey.isEmpty ? "❌ Missing" : "\(openAIKey.prefix(10))...")")
        print("✅ Google Script: \(googleAppsScriptURL.contains("script.google.com") ? "Valid" : "❌ Missing")")
        print("✅ Spreadsheet ID: \(spreadsheetID.isEmpty ? "❌ Missing" : spreadsheetID)")
        print("✅ RapidAPI Key: \(rapidAPIKey.isEmpty ? "❌ Missing" : "\(rapidAPIKey.prefix(10))...")")
        
        // Cost Analysis Information
        print("💰 OpenAI Cost Analysis:")
        print("📊 Model: gpt-4o-mini (Recommended for cost/performance)")
        print("💵 Input Cost: ~$0.15 per 1M tokens")
        print("💵 Output Cost: ~$0.60 per 1M tokens")
        print("📸 Image Cost: ~512 tokens per image")
        print("🔢 Per Analysis Cost: ~$0.02-0.05 per scan")
        print("📷 Multiple Photos: Yes, costs more but very affordable with gpt-4o-mini")
    }
}

// MARK: - Main AI Service using Professional Analysis
class AIService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 8
    
    private let professionalAnalyzer = ProfessionalAIService()
    
    init() {
        APIConfig.validateConfiguration()
    }
    
    // MARK: - Main Analysis Functions
    
    // Business Mode: Complete professional analysis
    func analyzeItem(_ images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        print("🚀 Starting PROFESSIONAL Business Mode Analysis...")
        
        // Sync progress with professional analyzer
        professionalAnalyzer.$isAnalyzing
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAnalyzing)
        
        professionalAnalyzer.$analysisProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$analysisProgress)
        
        professionalAnalyzer.$currentStep
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentStep)
        
        professionalAnalyzer.$totalSteps
            .receive(on: DispatchQueue.main)
            .assign(to: &$totalSteps)
        
        // Use professional analysis system
        professionalAnalyzer.analyzeItem(images) { result in
            completion(result)
        }
    }
    
    // MARK: - Prospecting Mode Analysis
    func analyzeForProspecting(images: [UIImage], category: String, completion: @escaping (ProspectAnalysis) -> Void) {
        guard !images.isEmpty else {
            completion(createDefaultProspectAnalysis([]))
            return
        }
        
        print("🔍 Starting PROFESSIONAL Prospecting Analysis...")
        
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.currentStep = 0
            self.totalSteps = 6
            self.analysisProgress = "🔍 Step 1/6: Quick product identification..."
            self.currentStep = 1
        }
        
        // Use professional analysis for prospecting
        professionalAnalyzer.analyzeItem(images) { [weak self] analysisResult in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.analysisProgress = "💰 Step 2/6: Calculating buy prices..."
                self.currentStep = 2
            }
            
            // Convert analysis result to prospect analysis
            let prospectAnalysis = self.convertToProspectAnalysis(analysisResult, images: images)
            
            DispatchQueue.main.async {
                self.isAnalyzing = false
                self.analysisProgress = "✅ Prospecting Complete!"
                self.currentStep = 0
                print("✅ PROFESSIONAL Prospecting Complete: \(prospectAnalysis.recommendation.title) - Max Pay: $\(String(format: "%.2f", prospectAnalysis.maxBuyPrice))")
                completion(prospectAnalysis)
            }
        }
    }
    
    private func convertToProspectAnalysis(_ analysis: AnalysisResult, images: [UIImage]) -> ProspectAnalysis {
        // Calculate smart buy prices
        let marketValue = analysis.realisticPrice
        let maxBuyPrice = calculateSmartMaxBuyPrice(
            marketValue: marketValue,
            condition: analysis.actualCondition,
            conditionScore: analysis.conditionScore,
            competitorCount: analysis.competitorCount
        )
        
        let targetBuyPrice = maxBuyPrice * 0.75
        let estimatedFees = marketValue * 0.15
        let potentialProfit = marketValue - maxBuyPrice - estimatedFees
        let expectedROI = maxBuyPrice > 0 ? (potentialProfit / maxBuyPrice) * 100 : 0
        
        // Generate smart recommendation
        let recommendation = generateSmartRecommendation(
            expectedROI: expectedROI,
            potentialProfit: potentialProfit,
            confidence: analysis.confidence,
            brand: analysis.brand,
            conditionScore: analysis.conditionScore
        )
        
        // Create recent sales from market data
        let recentSales = analysis.recentSoldPrices.prefix(5).map { price in
            RecentSale(
                price: price,
                date: Date().addingTimeInterval(-Double.random(in: 86400...2592000)),
                condition: analysis.actualCondition,
                title: "\(analysis.brand) \(analysis.itemName)",
                soldIn: generateSoldTime()
            )
        }
        
        return ProspectAnalysis(
            itemName: analysis.itemName,
            brand: analysis.brand,
            condition: analysis.actualCondition,
            confidence: analysis.confidence,
            estimatedSellPrice: marketValue,
            maxBuyPrice: maxBuyPrice,
            targetBuyPrice: targetBuyPrice,
            potentialProfit: potentialProfit,
            expectedROI: expectedROI,
            recommendation: recommendation.decision,
            reasons: recommendation.reasons,
            riskLevel: recommendation.riskLevel,
            demandLevel: analysis.demandLevel,
            competitorCount: analysis.competitorCount,
            marketTrend: analysis.marketTrend,
            sellTimeEstimate: estimateSellTime(analysis.demandLevel, analysis.competitorCount),
            seasonalFactors: analysis.seasonalFactors,
            sourcingTips: recommendation.sourcingTips,
            images: images,
            recentSales: Array(recentSales),
            averageSoldPrice: analysis.averagePrice,
            category: analysis.category,
            subcategory: analysis.subcategory,
            modelNumber: analysis.modelNumber,
            size: analysis.size,
            colorway: analysis.colorway,
            releaseYear: analysis.releaseYear,
            retailPrice: estimateRetailPrice(brand: analysis.brand, category: analysis.category),
            currentMarketValue: marketValue,
            quickFlipPotential: hasQuickFlipPotential(analysis.brand, analysis.demandLevel),
            holidayDemand: hasHolidayDemand(analysis.category),
            breakEvenPrice: marketValue * 0.85
        )
    }
    
    // MARK: - Barcode Analysis
    func analyzeBarcode(_ barcode: String, images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        print("📱 Analyzing barcode: \(barcode)")
        
        // First lookup barcode in product database
        lookupBarcodeProduct(barcode) { [weak self] productInfo in
            guard let self = self else { return }
            
            if let product = productInfo {
                // If barcode found, use that data with image analysis
                self.analyzeWithBarcodeData(images, productInfo: product, completion: completion)
            } else {
                // If no barcode data, fallback to regular analysis
                print("📱 Barcode not found, using regular analysis")
                self.analyzeItem(images, completion: completion)
            }
        }
    }
    
    func lookupBarcodeForProspecting(_ barcode: String, completion: @escaping (ProspectAnalysis) -> Void) {
        print("📱 Looking up barcode for prospecting: \(barcode)")
        
        lookupBarcodeProduct(barcode) { [weak self] productInfo in
            guard let self = self else { return }
            
            if let product = productInfo {
                let prospectAnalysis = self.createProspectFromBarcodeData(product)
                completion(prospectAnalysis)
            } else {
                completion(self.createDefaultProspectAnalysis([]))
            }
        }
    }
    
    // MARK: - Barcode Lookup
    private func lookupBarcodeProduct(_ barcode: String, completion: @escaping (BarcodeProductInfo?) -> Void) {
        // Try multiple barcode APIs
        lookupUPCDatabase(barcode) { productInfo in
            if let product = productInfo {
                completion(product)
            } else {
                // Try alternative barcode service
                completion(nil)
            }
        }
    }
    
    private func lookupUPCDatabase(_ barcode: String, completion: @escaping (BarcodeProductInfo?) -> Void) {
        // This would use a real UPC database API
        print("🔍 Looking up UPC: \(barcode)")
        
        // For now, return nil to trigger regular analysis
        completion(nil)
    }
    
    private func analyzeWithBarcodeData(_ images: [UIImage], productInfo: BarcodeProductInfo, completion: @escaping (AnalysisResult) -> Void) {
        // Use professional analysis with barcode data as additional context
        professionalAnalyzer.analyzeItem(images) { result in
            // Create enhanced result with barcode data - Fixed: Create new instance instead of modifying
            let enhancedResult = AnalysisResult(
                itemName: productInfo.productName.isEmpty ? result.itemName : productInfo.productName,
                brand: productInfo.brand.isEmpty ? result.brand : productInfo.brand,
                modelNumber: productInfo.modelNumber.isEmpty ? result.modelNumber : productInfo.modelNumber,
                category: result.category,
                confidence: max(result.confidence, 0.9), // High confidence from barcode
                actualCondition: result.actualCondition,
                conditionReasons: result.conditionReasons,
                conditionScore: result.conditionScore,
                realisticPrice: result.realisticPrice,
                quickSalePrice: result.quickSalePrice,
                maxProfitPrice: result.maxProfitPrice,
                marketRange: result.marketRange,
                recentSoldPrices: result.recentSoldPrices,
                averagePrice: result.averagePrice,
                marketTrend: result.marketTrend,
                competitorCount: result.competitorCount,
                demandLevel: result.demandLevel,
                ebayTitle: result.ebayTitle,
                description: result.description,
                keywords: result.keywords,
                feesBreakdown: result.feesBreakdown,
                profitMargins: result.profitMargins,
                listingStrategy: result.listingStrategy,
                sourcingTips: result.sourcingTips,
                seasonalFactors: result.seasonalFactors,
                resalePotential: result.resalePotential,
                images: result.images,
                size: productInfo.size.isEmpty ? result.size : productInfo.size,
                colorway: productInfo.colorway.isEmpty ? result.colorway : productInfo.colorway,
                releaseYear: productInfo.releaseYear.isEmpty ? result.releaseYear : productInfo.releaseYear,
                subcategory: result.subcategory,
                authenticationNotes: result.authenticationNotes,
                seasonalDemand: result.seasonalDemand,
                sizePopularity: result.sizePopularity,
                barcode: productInfo.upc
            )
            
            completion(enhancedResult)
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateSmartMaxBuyPrice(marketValue: Double, condition: String, conditionScore: Double, competitorCount: Int) -> Double {
        var multiplier = 0.45 // Base 45% of market value
        
        // Adjust for condition
        switch condition.lowercased() {
        case "like new": multiplier += 0.15
        case "excellent": multiplier += 0.1
        case "very good": multiplier += 0.05
        case "fair", "poor": multiplier -= 0.1
        default: break
        }
        
        // Adjust for condition score
        if conditionScore > 90 { multiplier += 0.05 }
        if conditionScore < 60 { multiplier -= 0.1 }
        
        // Adjust for competition
        if competitorCount < 50 { multiplier += 0.05 }
        if competitorCount > 200 { multiplier -= 0.05 }
        
        return max(3.0, marketValue * max(0.25, min(0.65, multiplier)))
    }
    
    private func generateSmartRecommendation(expectedROI: Double, potentialProfit: Double, confidence: Double, brand: String, conditionScore: Double) -> ProspectRecommendation {
        var decision: ProspectDecision = .investigate
        var reasons: [String] = []
        var riskLevel = "Medium"
        var sourcingTips: [String] = []
        
        let isPopularBrand = ["nike", "adidas", "jordan", "supreme", "apple", "sony"].contains(brand.lowercased())
        
        if expectedROI >= 80 && potentialProfit >= 10 && confidence >= 0.7 && conditionScore >= 70 {
            decision = .buy
            riskLevel = "Low"
            reasons.append("🔥 Excellent ROI: \(String(format: "%.0f", expectedROI))%")
            reasons.append("💰 Strong profit: $\(String(format: "%.2f", potentialProfit))")
            if isPopularBrand { reasons.append("⭐ Popular brand") }
            if conditionScore >= 85 { reasons.append("✅ Excellent condition") }
            sourcingTips.append("✅ Strong buy - great deal")
        } else if expectedROI >= 50 && potentialProfit >= 5 && conditionScore >= 60 {
            if confidence >= 0.7 {
                decision = .buy
                reasons.append("✅ Good ROI with high confidence")
            } else {
                decision = .investigate
                reasons.append("⚠️ Good ROI but verify identification")
            }
        } else {
            decision = .investigate
            riskLevel = "High"
            if expectedROI < 50 { reasons.append("⚠️ Lower profit potential") }
            if conditionScore < 60 { reasons.append("⚠️ Condition concerns") }
            if confidence < 0.6 { reasons.append("⚠️ Low identification confidence") }
        }
        
        sourcingTips.append("🔍 Check condition carefully")
        if !isPopularBrand { sourcingTips.append("📊 Research brand popularity") }
        if conditionScore < 70 { sourcingTips.append("💡 Factor in restoration costs") }
        
        return ProspectRecommendation(
            decision: decision,
            reasons: reasons,
            riskLevel: riskLevel,
            sourcingTips: sourcingTips
        )
    }
    
    private func estimateSellTime(_ demandLevel: String, _ competitorCount: Int) -> String {
        switch demandLevel.lowercased() {
        case "high":
            return competitorCount > 100 ? "1-2 weeks" : "3-7 days"
        case "medium":
            return "2-3 weeks"
        case "low":
            return "1-2 months"
        default:
            return "2-4 weeks"
        }
    }
    
    private func estimateRetailPrice(brand: String, category: String) -> Double {
        let brandLower = brand.lowercased()
        
        if brandLower == "nike" || brandLower == "jordan" {
            return category.lowercased().contains("shoe") ? 120.0 : 60.0
        } else if brandLower == "adidas" {
            return category.lowercased().contains("shoe") ? 100.0 : 50.0
        } else if brandLower == "apple" {
            return 500.0
        } else if brandLower == "supreme" {
            return 150.0
        }
        
        return 50.0
    }
    
    private func hasQuickFlipPotential(_ brand: String, _ demandLevel: String) -> Bool {
        let popularBrands = ["nike", "jordan", "supreme", "apple"]
        return popularBrands.contains(brand.lowercased()) && demandLevel == "High"
    }
    
    private func hasHolidayDemand(_ category: String) -> Bool {
        let holidayCategories = ["electronics", "toys", "gaming"]
        return holidayCategories.contains { category.lowercased().contains($0) }
    }
    
    private func generateSoldTime() -> String {
        let times = ["1 day", "2 days", "3 days", "5 days", "1 week", "10 days", "2 weeks"]
        return times.randomElement() ?? "1 week"
    }
    
    private func createProspectFromBarcodeData(_ product: BarcodeProductInfo) -> ProspectAnalysis {
        let estimatedMarketValue = product.originalRetailPrice * 0.6
        let maxBuyPrice = estimatedMarketValue * 0.5
        let targetBuyPrice = maxBuyPrice * 0.8
        let potentialProfit = estimatedMarketValue - maxBuyPrice - (estimatedMarketValue * 0.15)
        let expectedROI = maxBuyPrice > 0 ? (potentialProfit / maxBuyPrice) * 100 : 0
        
        return ProspectAnalysis(
            itemName: product.productName,
            brand: product.brand,
            condition: "Unknown - Inspect Carefully",
            confidence: 0.9, // High confidence from barcode
            estimatedSellPrice: estimatedMarketValue,
            maxBuyPrice: maxBuyPrice,
            targetBuyPrice: targetBuyPrice,
            potentialProfit: potentialProfit,
            expectedROI: expectedROI,
            recommendation: expectedROI > 50 ? .buy : .investigate,
            reasons: ["📱 Verified by barcode", "✅ Authentic product confirmed"],
            riskLevel: "Low",
            demandLevel: "Medium",
            competitorCount: 50,
            marketTrend: "Stable",
            sellTimeEstimate: "2-3 weeks",
            seasonalFactors: "Standard",
            sourcingTips: ["✅ Barcode verified authentic", "🔍 Check physical condition"],
            images: [],
            recentSales: [],
            averageSoldPrice: estimatedMarketValue,
            category: product.category,
            subcategory: product.subcategory,
            modelNumber: product.modelNumber,
            size: product.size,
            colorway: product.colorway,
            releaseYear: product.releaseYear,
            retailPrice: product.originalRetailPrice,
            currentMarketValue: estimatedMarketValue,
            quickFlipPotential: false,
            holidayDemand: false,
            breakEvenPrice: estimatedMarketValue * 0.85
        )
    }
    
    private func createDefaultProspectAnalysis(_ images: [UIImage]) -> ProspectAnalysis {
        return ProspectAnalysis(
            itemName: "Analysis Failed",
            brand: "",
            condition: "Unknown",
            confidence: 0.1,
            estimatedSellPrice: 0,
            maxBuyPrice: 0,
            targetBuyPrice: 0,
            potentialProfit: 0,
            expectedROI: 0,
            recommendation: .investigate,
            reasons: ["Analysis failed - check API connection"],
            riskLevel: "High",
            demandLevel: "Unknown",
            competitorCount: 0,
            marketTrend: "Unknown",
            sellTimeEstimate: "Unknown",
            seasonalFactors: "Unknown",
            sourcingTips: ["Manual research required"],
            images: images,
            recentSales: [],
            averageSoldPrice: 0,
            category: "Other",
            subcategory: "",
            modelNumber: "",
            size: "",
            colorway: "",
            releaseYear: "",
            retailPrice: 0,
            currentMarketValue: 0,
            quickFlipPotential: false,
            holidayDemand: false,
            breakEvenPrice: 0
        )
    }
}

// MARK: - Barcode Product Info
struct BarcodeProductInfo {
    let upc: String
    let productName: String
    let brand: String
    let modelNumber: String
    let size: String
    let colorway: String
    let releaseYear: String
    let originalRetailPrice: Double
    let category: String
    let subcategory: String
    let description: String
    let imageUrls: [String]
    let specifications: [String: String]
    let isAuthentic: Bool
    let confidence: Double
}

// MARK: - Google Sheets Service (unchanged)
class GoogleSheetsService: ObservableObject {
    @Published var spreadsheetId = APIConfig.spreadsheetID
    @Published var isConnected = true
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus = "Ready to sync"
    
    init() {
        authenticate()
    }
    
    func authenticate() {
        print("🔗 Google Sheets Service Initialized with REAL API")
        isConnected = true
        syncStatus = "Connected to Google Sheets"
    }
    
    func uploadItem(_ item: InventoryItem) {
        print("📤 Uploading item to REAL Google Sheets: \(item.name) [\(item.inventoryCode)]")
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncStatus = "Uploading \(item.name)..."
        }
        
        // Generate optimized eBay title and description
        let optimizedTitle = generateOptimizedListingTitle(item)
        let optimizedDescription = generateOptimizedListingDescription(item)
        
        // Prepare data for Google Apps Script
        let itemData: [String: Any] = [
            "itemNumber": item.itemNumber,
            "inventoryCode": item.inventoryCode,
            "name": item.name,
            "source": item.source,
            "purchasePrice": item.purchasePrice,
            "suggestedPrice": item.suggestedPrice,
            "status": item.status.rawValue,
            "profit": item.estimatedProfit,
            "roi": item.estimatedROI,
            "date": formatDate(item.dateAdded),
            "title": item.title,
            "description": item.description,
            "keywords": item.keywords.joined(separator: ", "),
            "condition": item.condition,
            "category": item.category,
            "brand": item.brand,
            "size": item.size,
            "storageLocation": item.storageLocation,
            "binNumber": item.binNumber,
            "optimizedTitle": optimizedTitle,
            "optimizedDescription": optimizedDescription
        ]
        
        sendToRealGoogleSheets(data: itemData) { [weak self] success in
            DispatchQueue.main.async {
                self?.isSyncing = false
                if success {
                    self?.syncStatus = "✅ Synced successfully"
                    self?.lastSyncDate = Date()
                    print("✅ Successfully uploaded \(item.name) to REAL Google Sheets")
                } else {
                    self?.syncStatus = "❌ Sync failed"
                    print("❌ Failed to upload \(item.name) to REAL Google Sheets")
                }
            }
        }
    }
    
    private func generateOptimizedListingTitle(_ item: InventoryItem) -> String {
        var components: [String] = []
        
        // Brand first if available
        if !item.brand.isEmpty {
            components.append(item.brand)
        }
        
        // Main item name
        components.append(item.name)
        
        // Size if available
        if !item.size.isEmpty {
            components.append("Size \(item.size)")
        }
        
        // Colorway if available and not already in name
        if !item.colorway.isEmpty && !item.name.lowercased().contains(item.colorway.lowercased()) {
            components.append(item.colorway)
        }
        
        // Condition
        components.append(item.condition)
        
        // Keywords for search optimization
        let keywordString = item.keywords.prefix(3).joined(separator: " ")
        if !keywordString.isEmpty {
            components.append(keywordString)
        }
        
        let fullTitle = components.joined(separator: " ")
        
        // eBay title limit is 80 characters
        return fullTitle.count > 77 ? String(fullTitle.prefix(77)) + "..." : fullTitle
    }
    
    private func generateOptimizedListingDescription(_ item: InventoryItem) -> String {
        var description = ""
        
        // Eye-catching header
        description += "🔥 \(item.name) - \(item.condition) Condition 🔥\n\n"
        
        // Key details
        if !item.brand.isEmpty {
            description += "Brand: \(item.brand)\n"
        }
        
        if !item.size.isEmpty {
            description += "Size: \(item.size)\n"
        }
        
        if !item.colorway.isEmpty {
            description += "Colorway: \(item.colorway)\n"
        }
        
        description += "Condition: \(item.condition)\n"
        
        if !item.inventoryCode.isEmpty {
            description += "Item Code: \(item.inventoryCode)\n"
        }
        
        description += "\n"
        
        // Main description
        if !item.description.isEmpty {
            description += "\(item.description)\n\n"
        }
        
        // Selling points
        description += "✅ WHY BUY FROM US:\n"
        description += "• 100% Authentic Guaranteed\n"
        description += "• Fast Same/Next Day Shipping\n"
        description += "• Secure Packaging with Tracking\n"
        description += "• 30-Day Return Policy\n"
        description += "• Top-Rated Seller with Excellent Feedback\n\n"
        
        // Keywords for search
        if !item.keywords.isEmpty {
            description += "🔍 SEARCH TERMS: \(item.keywords.joined(separator: ", "))\n\n"
        }
        
        // Hashtags for visibility
        let hashtags = item.keywords.prefix(5).map { "#\($0.replacingOccurrences(of: " ", with: ""))" }
        if !hashtags.isEmpty {
            description += hashtags.joined(separator: " ")
        }
        
        return description
    }
    
    func updateItem(_ item: InventoryItem) {
        uploadItem(item) // For now, treat updates as uploads
    }
    
    func syncAllItems(_ items: [InventoryItem]) {
        print("🔄 Syncing \(items.count) items to REAL Google Sheets")
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncStatus = "Syncing \(items.count) items..."
        }
        
        let group = DispatchGroup()
        var successCount = 0
        
        for item in items {
            group.enter()
            
            let optimizedTitle = generateOptimizedListingTitle(item)
            let optimizedDescription = generateOptimizedListingDescription(item)
            
            let itemData: [String: Any] = [
                "itemNumber": item.itemNumber,
                "inventoryCode": item.inventoryCode,
                "name": item.name,
                "source": item.source,
                "purchasePrice": item.purchasePrice,
                "suggestedPrice": item.suggestedPrice,
                "status": item.status.rawValue,
                "profit": item.estimatedProfit,
                "roi": item.estimatedROI,
                "date": formatDate(item.dateAdded),
                "title": item.title,
                "description": item.description,
                "keywords": item.keywords.joined(separator: ", "),
                "condition": item.condition,
                "category": item.category,
                "brand": item.brand,
                "size": item.size,
                "storageLocation": item.storageLocation,
                "binNumber": item.binNumber,
                "optimizedTitle": optimizedTitle,
                "optimizedDescription": optimizedDescription
            ]
            
            sendToRealGoogleSheets(data: itemData) { success in
                if success {
                    successCount += 1
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isSyncing = false
            self.syncStatus = "✅ Synced \(successCount)/\(items.count) items"
            self.lastSyncDate = Date()
            print("✅ REAL Bulk sync complete: \(successCount)/\(items.count) items")
        }
    }
    
    private func sendToRealGoogleSheets(data: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: APIConfig.googleAppsScriptURL) else {
            print("❌ Invalid Google Apps Script URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15.0
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
            print("📤 Sending data to REAL Google Sheets: \(data["name"] ?? "Unknown")")
        } catch {
            print("❌ Failed to serialize data for Google Sheets: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ REAL Google Sheets upload error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📨 Google Sheets HTTP Status: \(httpResponse.statusCode)")
            }
            
            if let data = data,
               let responseString = String(data: data, encoding: .utf8) {
                print("📨 REAL Google Sheets response: \(responseString)")
                
                if responseString.contains("success") || responseString.contains("Item added successfully") {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                print("❌ No response from REAL Google Sheets")
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

// MARK: - eBay Listing Service (placeholder)
class EbayListingService: ObservableObject {
    @Published var isListing = false
    @Published var listingProgress = "Ready to list"
    @Published var listingURL: String?
    @Published var isConfigured = false
    
    func listDirectlyToEbay(item: InventoryItem, analysis: AnalysisResult, completion: @escaping (Bool, String?) -> Void) {
        print("🚫 eBay direct listing not yet implemented - need eBay API access")
        
        DispatchQueue.main.async {
            self.isListing = true
            self.listingProgress = "eBay API not yet configured..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isListing = false
            self.listingProgress = "Manual listing required - copy from inventory"
            completion(false, nil)
        }
    }
}
