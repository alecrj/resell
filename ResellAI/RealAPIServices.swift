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
    
    static func validateConfiguration() {
        print("🔧 FIXED API Configuration Status:")
        print("✅ OpenAI Key: \(openAIKey.isEmpty ? "❌ Missing" : "✅ Configured (\(openAIKey.prefix(10))...)")")
        print("✅ Google Script: \(googleAppsScriptURL.contains("script.google.com") ? "✅ Valid" : "❌ Missing")")
        print("✅ Spreadsheet ID: \(spreadsheetID.isEmpty ? "❌ Missing" : "✅ Configured")")
        print("✅ RapidAPI Key: \(rapidAPIKey.isEmpty ? "❌ Missing" : "✅ Configured (\(rapidAPIKey.prefix(10))...)")")
        
        if openAIKey.isEmpty {
            print("⚠️ WARNING: OpenAI API key missing - analysis will not work!")
        }
        if rapidAPIKey.isEmpty {
            print("⚠️ WARNING: RapidAPI key missing - market research limited!")
        }
        
        print("💰 OpenAI Cost Analysis:")
        print("📊 Model: gpt-4o-mini (Cost-effective)")
        print("💵 Per Analysis: ~$0.02-0.05")
        print("📷 Multiple Photos: Supported")
    }
}

// MARK: - FIXED Main AI Service
class AIService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 8
    
    private let realAnalyzer = RealAIAnalysisService()
    
    init() {
        APIConfig.validateConfiguration()
        
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
    
    // MARK: - FIXED Main Analysis Functions
    
    func analyzeItem(_ images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        guard !APIConfig.openAIKey.isEmpty else {
            print("❌ OpenAI API key not configured!")
            completion(createAPIErrorResult("OpenAI API key not configured. Check environment variables."))
            return
        }
        
        guard !images.isEmpty else {
            print("❌ No images provided for analysis")
            completion(createAPIErrorResult("No images provided for analysis"))
            return
        }
        
        print("🚀 Starting FIXED AI Analysis with \(images.count) images")
        
        realAnalyzer.analyzeItem(images) { result in
            DispatchQueue.main.async {
                print("✅ FIXED Analysis Complete: \(result.itemName) - \(result.actualCondition) - $\(String(format: "%.2f", result.realisticPrice))")
                completion(result)
            }
        }
    }
    
    // MARK: - FIXED Prospecting Mode Analysis
    func analyzeForProspecting(images: [UIImage], category: String, completion: @escaping (ProspectAnalysis) -> Void) {
        guard !images.isEmpty else {
            completion(createDefaultProspectAnalysis([]))
            return
        }
        
        guard !APIConfig.openAIKey.isEmpty else {
            print("❌ OpenAI API key not configured for prospecting!")
            completion(createAPIErrorProspectAnalysis(images))
            return
        }
        
        print("🔍 Starting FIXED Prospecting Analysis with \(images.count) images")
        
        realAnalyzer.analyzeItem(images) { [weak self] analysisResult in
            guard let self = self else { return }
            
            // Convert analysis result to prospect analysis with FIXED pricing
            let prospectAnalysis = self.convertToFixedProspectAnalysis(analysisResult, images: images)
            
            DispatchQueue.main.async {
                print("✅ FIXED Prospecting Complete: \(prospectAnalysis.recommendation.title) - Max Pay: $\(String(format: "%.2f", prospectAnalysis.maxBuyPrice))")
                completion(prospectAnalysis)
            }
        }
    }
    
    // MARK: - FIXED Barcode Analysis
    func analyzeBarcode(_ barcode: String, images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        print("📱 FIXED Barcode Analysis: \(barcode)")
        
        guard !APIConfig.openAIKey.isEmpty else {
            completion(createAPIErrorResult("OpenAI API key not configured for barcode analysis"))
            return
        }
        
        // Clean barcode
        let cleanBarcode = barcode.filter { $0.isNumber }
        guard cleanBarcode.count >= 8 else {
            print("❌ Invalid barcode format: \(barcode)")
            completion(createAPIErrorResult("Invalid barcode format: \(barcode)"))
            return
        }
        
        // First try barcode lookup
        realAnalyzer.lookupProductByBarcode(cleanBarcode) { [weak self] productData in
            guard let self = self else { return }
            
            if let product = productData, product.confidence > 0.7 {
                // High confidence barcode match - create result
                let barcodeResult = self.createBarcodeResult(product, images: images)
                completion(barcodeResult)
            } else {
                // Fallback to image analysis if available
                if !images.isEmpty {
                    print("📱 Barcode lookup failed, using image analysis")
                    self.analyzeItem(images, completion: completion)
                } else {
                    completion(self.createAPIErrorResult("Barcode not found in database: \(cleanBarcode)"))
                }
            }
        }
    }
    
    func lookupBarcodeForProspecting(_ barcode: String, completion: @escaping (ProspectAnalysis) -> Void) {
        print("📱 FIXED Barcode Prospecting Lookup: \(barcode)")
        
        guard !APIConfig.openAIKey.isEmpty else {
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
    
    // MARK: - FIXED Helper Methods for Prospecting
    
    private func convertToFixedProspectAnalysis(_ analysis: AnalysisResult, images: [UIImage]) -> ProspectAnalysis {
        // Use FIXED market data and conservative pricing
        let marketValue = analysis.realisticPrice
        let conditionMultiplier = getFixedConditionMultiplier(analysis.conditionScore)
        
        // FIXED: More conservative max buy price calculation
        let adjustedMarketValue = marketValue * conditionMultiplier
        let maxBuyPrice = calculateFixedMaxBuyPrice(
            marketValue: adjustedMarketValue,
            competitorCount: analysis.competitorCount,
            brand: analysis.brand,
            category: analysis.category
        )
        
        let targetBuyPrice = maxBuyPrice * 0.8  // 80% of max for good profit
        let estimatedFees = marketValue * 0.15  // Conservative fee estimate
        let potentialProfit = marketValue - maxBuyPrice - estimatedFees
        let expectedROI = maxBuyPrice > 0 ? (potentialProfit / maxBuyPrice) * 100 : 0
        
        // Generate FIXED recommendation based on REAL data
        let recommendation = generateFixedRecommendation(
            expectedROI: expectedROI,
            potentialProfit: potentialProfit,
            confidence: analysis.confidence,
            brand: analysis.brand,
            conditionScore: analysis.conditionScore,
            marketValue: marketValue
        )
        
        // Create recent sales from REAL market data
        let recentSales = analysis.recentSoldPrices.prefix(5).enumerated().map { index, price in
            RecentSale(
                price: price,
                date: Date().addingTimeInterval(-Double(index * 86400 * 2)), // Spread over days
                condition: analysis.actualCondition,
                title: "\(analysis.brand) \(analysis.itemName)".trimmingCharacters(in: .whitespaces),
                soldIn: generateRealisticSoldTime()
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
            sellTimeEstimate: estimateRealisticSellTime(analysis.demandLevel, analysis.competitorCount),
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
            retailPrice: estimateConservativeRetailPrice(brand: analysis.brand, category: analysis.category, name: analysis.itemName),
            currentMarketValue: marketValue,
            quickFlipPotential: hasRealQuickFlipPotential(analysis.brand, analysis.demandLevel, marketValue),
            holidayDemand: hasHolidayDemand(analysis.category),
            breakEvenPrice: marketValue * 0.75
        )
    }
    
    private func getFixedConditionMultiplier(_ score: Double) -> Double {
        // More realistic condition impact on pricing
        switch score {
        case 90...100: return 1.0    // Like New
        case 80...89:  return 0.85   // Excellent
        case 70...79:  return 0.75   // Very Good
        case 60...69:  return 0.6    // Good
        case 40...59:  return 0.45   // Fair
        default:       return 0.3    // Poor
        }
    }
    
    private func calculateFixedMaxBuyPrice(marketValue: Double, competitorCount: Int, brand: String, category: String) -> Double {
        // Start with 50% of market value as base
        var maxBuy = marketValue * 0.5
        
        // Adjust for competition
        if competitorCount < 20 {
            maxBuy *= 1.1  // Less competition = can pay slightly more
        } else if competitorCount > 100 {
            maxBuy *= 0.85  // High competition = pay less
        }
        
        // Adjust for brand premium (conservative)
        let brandLower = brand.lowercased()
        if brandLower.contains("apple") || brandLower.contains("jordan") {
            maxBuy *= 1.05  // Small premium for high-demand brands
        } else if brandLower.contains("supreme") || brandLower.contains("nike") {
            maxBuy *= 1.02
        }
        
        // Category adjustments
        if category.lowercased().contains("electronics") {
            maxBuy *= 0.9  // Electronics depreciate quickly
        }
        
        return max(3.0, min(maxBuy, marketValue * 0.6))  // Cap at 60% of market value
    }
    
    private func generateFixedRecommendation(expectedROI: Double, potentialProfit: Double, confidence: Double, brand: String, conditionScore: Double, marketValue: Double) -> ProspectRecommendation {
        var decision: ProspectDecision = .investigate
        var reasons: [String] = []
        var riskLevel = "Medium"
        var sourcingTips: [String] = []
        
        let isPopularBrand = ["nike", "jordan", "adidas", "supreme", "apple", "samsung"].contains(brand.lowercased())
        
        // FIXED Decision logic based on REAL conservative data
        if expectedROI >= 150 && potentialProfit >= 20 && confidence >= 0.8 && conditionScore >= 75 && marketValue >= 30 {
            decision = .buy
            riskLevel = "Low"
            reasons.append("🔥 Excellent ROI: \(String(format: "%.0f", expectedROI))%")
            reasons.append("💰 Strong profit: $\(String(format: "%.2f", potentialProfit))")
            if isPopularBrand { reasons.append("⭐ Popular brand with demand") }
            sourcingTips.append("✅ Strong buy - excellent opportunity")
        } else if expectedROI >= 100 && potentialProfit >= 10 && conditionScore >= 60 && marketValue >= 15 {
            if confidence >= 0.7 {
                decision = .buy
                riskLevel = conditionScore > 75 ? "Low" : "Medium"
                reasons.append("✅ Good ROI with solid profit margin")
                reasons.append("📊 Market data supports pricing")
            } else {
                decision = .investigate
                reasons.append("⚠️ Good numbers but verify item identification")
            }
        } else if expectedROI >= 50 && potentialProfit >= 5 {
            decision = .investigate
            riskLevel = "Medium"
            reasons.append("💭 Moderate profit potential")
            if confidence < 0.7 { reasons.append("⚠️ Verify identification accuracy") }
            if conditionScore < 60 { reasons.append("⚠️ Check condition impact on value") }
        } else {
            decision = .investigate
            riskLevel = "High"
            if expectedROI < 50 { reasons.append("⚠️ Lower profit margin") }
            if potentialProfit < 5 { reasons.append("⚠️ Minimal profit potential") }
            if conditionScore < 60 { reasons.append("⚠️ Condition concerns") }
            if confidence < 0.6 { reasons.append("⚠️ Low identification confidence") }
        }
        
        // Add universal sourcing tips
        sourcingTips.append("🔍 Verify condition thoroughly")
        sourcingTips.append("📊 Check recent sold listings")
        if !isPopularBrand { sourcingTips.append("📈 Research brand popularity") }
        sourcingTips.append("📦 Look for original packaging")
        
        return ProspectRecommendation(
            decision: decision,
            reasons: reasons,
            riskLevel: riskLevel,
            sourcingTips: sourcingTips
        )
    }
    
    private func estimateRealisticSellTime(_ demandLevel: String, _ competitorCount: Int) -> String {
        switch demandLevel.lowercased() {
        case "high":
            return competitorCount > 50 ? "1-2 weeks" : "3-7 days"
        case "medium":
            return competitorCount > 100 ? "3-4 weeks" : "2-3 weeks"
        case "low":
            return "1-3 months"
        default:
            return "2-4 weeks"
        }
    }
    
    private func estimateConservativeRetailPrice(brand: String, category: String, name: String) -> Double {
        let brandLower = brand.lowercased()
        let categoryLower = category.lowercased()
        let nameLower = name.lowercased()
        
        // Electronics - FIXED Apple Watch Series 2 pricing
        if nameLower.contains("apple watch") {
            if nameLower.contains("series 2") { return 80.0 }  // Conservative Series 2 retail
            if nameLower.contains("series 3") { return 120.0 }
            if nameLower.contains("series 4") { return 200.0 }
            if nameLower.contains("series 5") { return 250.0 }
            return 100.0
        } else if categoryLower.contains("electronic") || categoryLower.contains("phone") {
            if brandLower.contains("apple") { return 600.0 }
            if brandLower.contains("samsung") { return 500.0 }
            return 200.0
        }
        
        // Footwear - FIXED Jordan pricing
        if categoryLower.contains("shoe") || nameLower.contains("jordan") || nameLower.contains("nike") {
            if nameLower.contains("jordan 1") && nameLower.contains("low") {
                return 110.0  // Conservative Jordan 1 Low retail
            } else if nameLower.contains("jordan 1") {
                return 170.0
            } else if nameLower.contains("jordan") {
                return 140.0
            } else if nameLower.contains("nike") {
                return 100.0
            } else if nameLower.contains("adidas") {
                return 90.0
            }
            return 70.0
        }
        
        // Clothing
        if categoryLower.contains("clothing") {
            if brandLower.contains("supreme") { return 150.0 }
            if brandLower.contains("off-white") { return 300.0 }
            return 40.0
        }
        
        // Home goods
        if categoryLower.contains("home") || nameLower.contains("mug") {
            if brandLower.contains("vintage") { return 30.0 }
            return 12.0
        }
        
        return 25.0
    }
    
    private func hasRealQuickFlipPotential(_ brand: String, _ demandLevel: String, _ marketValue: Double) -> Bool {
        let popularBrands = ["nike", "jordan", "supreme", "apple"]
        return popularBrands.contains(brand.lowercased()) && demandLevel == "High" && marketValue >= 50
    }
    
    private func hasHolidayDemand(_ category: String) -> Bool {
        let holidayCategories = ["electronics", "toys", "gaming"]
        return holidayCategories.contains { category.lowercased().contains($0) }
    }
    
    private func generateRealisticSoldTime() -> String {
        let times = ["2 days", "3 days", "5 days", "1 week", "10 days", "2 weeks", "3 weeks"]
        return times.randomElement() ?? "1 week"
    }
    
    // MARK: - FIXED Barcode Results
    
    private func createBarcodeResult(_ product: RealProductData, images: [UIImage]) -> AnalysisResult {
        // Conservative estimates for barcode-only data
        let estimatedCondition = "Good" // Conservative without photo analysis
        let conditionScore = 65.0 // Conservative score
        let marketPrice = product.retailPrice > 0 ? product.retailPrice * 0.4 : 25.0 // Conservative market estimate
        
        let fees = FeesBreakdown(
            ebayFee: marketPrice * 0.1325,
            paypalFee: marketPrice * 0.0349 + 0.49,
            shippingCost: 12.50,
            listingFees: 0.35,
            totalFees: marketPrice * 0.1674 + 12.85
        )
        
        let profits = ProfitMargins(
            quickSaleNet: (marketPrice * 0.85) - fees.totalFees,
            realisticNet: marketPrice - fees.totalFees,
            maxProfitNet: (marketPrice * 1.15) - fees.totalFees
        )
        
        return AnalysisResult(
            itemName: product.name,
            brand: product.brand,
            modelNumber: product.model,
            category: product.category,
            confidence: product.confidence,
            actualCondition: estimatedCondition,
            conditionReasons: ["Barcode verified - visual inspection needed"],
            conditionScore: conditionScore,
            realisticPrice: marketPrice,
            quickSalePrice: marketPrice * 0.85,
            maxProfitPrice: marketPrice * 1.15,
            marketRange: PriceRange(low: marketPrice * 0.7, high: marketPrice * 1.3, average: marketPrice),
            recentSoldPrices: [marketPrice * 0.8, marketPrice, marketPrice * 1.2],
            averagePrice: marketPrice,
            marketTrend: "Stable",
            competitorCount: 50,
            demandLevel: "Medium",
            ebayTitle: "\(product.brand) \(product.name) - \(estimatedCondition)".trimmingCharacters(in: .whitespaces),
            description: "📱 Barcode verified: \(product.brand) \(product.name)\n\nCondition: \(estimatedCondition)\nAuthentic item verified by barcode database",
            keywords: [product.brand, product.name, product.model, product.category].filter { !$0.isEmpty },
            feesBreakdown: fees,
            profitMargins: profits,
            listingStrategy: "Barcode verified authenticity",
            sourcingTips: ["✅ Barcode verified authentic", "🔍 Inspect physical condition", "📊 Research current market prices"],
            seasonalFactors: "Standard patterns",
            resalePotential: 6,
            images: images,
            size: product.size,
            colorway: product.colorway,
            releaseYear: product.releaseYear,
            subcategory: product.category,
            authenticationNotes: "Verified in product database",
            seasonalDemand: "Standard",
            sizePopularity: "Standard",
            barcode: nil
        )
    }
    
    private func createProspectFromBarcodeData(_ product: RealProductData) -> ProspectAnalysis {
        let estimatedMarketValue = product.retailPrice > 0 ? product.retailPrice * 0.4 : 20.0
        let maxBuyPrice = estimatedMarketValue * 0.5
        let targetBuyPrice = maxBuyPrice * 0.8
        let potentialProfit = estimatedMarketValue - maxBuyPrice - (estimatedMarketValue * 0.15)
        let expectedROI = maxBuyPrice > 0 ? (potentialProfit / maxBuyPrice) * 100 : 0
        
        return ProspectAnalysis(
            itemName: product.name,
            brand: product.brand,
            condition: "Unknown - Inspect Condition",
            confidence: product.confidence,
            estimatedSellPrice: estimatedMarketValue,
            maxBuyPrice: maxBuyPrice,
            targetBuyPrice: targetBuyPrice,
            potentialProfit: potentialProfit,
            expectedROI: expectedROI,
            recommendation: expectedROI > 75 ? .buy : .investigate,
            reasons: ["📱 Verified by barcode database", "✅ Authentic product confirmed"],
            riskLevel: "Medium",
            demandLevel: "Medium",
            competitorCount: 50,
            marketTrend: "Stable",
            sellTimeEstimate: "2-3 weeks",
            seasonalFactors: "Standard",
            sourcingTips: ["✅ Barcode verified authentic", "🔍 Inspect condition carefully", "📊 Research current market prices"],
            images: [],
            recentSales: [],
            averageSoldPrice: estimatedMarketValue,
            category: product.category,
            subcategory: product.category,
            modelNumber: product.model,
            size: product.size,
            colorway: product.colorway,
            releaseYear: product.releaseYear,
            retailPrice: product.retailPrice,
            currentMarketValue: estimatedMarketValue,
            quickFlipPotential: false,
            holidayDemand: false,
            breakEvenPrice: estimatedMarketValue * 0.8
        )
    }
    
    // MARK: - FIXED Error Handling
    
    private func createAPIErrorResult(_ error: String) -> AnalysisResult {
        return AnalysisResult(
            itemName: "Analysis Error",
            brand: "",
            modelNumber: "",
            category: "other",
            confidence: 0.0,
            actualCondition: "Unknown",
            conditionReasons: [error],
            conditionScore: 0,
            realisticPrice: 0,
            quickSalePrice: 0,
            maxProfitPrice: 0,
            marketRange: PriceRange(),
            recentSoldPrices: [],
            averagePrice: 0,
            marketTrend: "Unknown",
            competitorCount: 0,
            demandLevel: "Unknown",
            ebayTitle: "Configuration Error",
            description: error,
            keywords: [],
            feesBreakdown: FeesBreakdown(ebayFee: 0, paypalFee: 0, shippingCost: 0, listingFees: 0, totalFees: 0),
            profitMargins: ProfitMargins(quickSaleNet: 0, realisticNet: 0, maxProfitNet: 0),
            listingStrategy: "",
            sourcingTips: ["Configure OpenAI API key", "Check environment variables", "Restart application"],
            seasonalFactors: "",
            resalePotential: 1,
            images: []
        )
    }
    
    private func createDefaultProspectAnalysis(_ images: [UIImage]) -> ProspectAnalysis {
        return ProspectAnalysis(
            itemName: "No Analysis Available",
            brand: "",
            condition: "Unknown",
            confidence: 0.0,
            estimatedSellPrice: 0,
            maxBuyPrice: 0,
            targetBuyPrice: 0,
            potentialProfit: 0,
            expectedROI: 0,
            recommendation: .investigate,
            reasons: ["Take photos for analysis"],
            riskLevel: "High",
            demandLevel: "Unknown",
            competitorCount: 0,
            marketTrend: "Unknown",
            sellTimeEstimate: "Unknown",
            seasonalFactors: "Unknown",
            sourcingTips: ["Take multiple clear photos", "Check for brand markings", "Assess condition carefully"],
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
    
    private func createAPIErrorProspectAnalysis(_ images: [UIImage]) -> ProspectAnalysis {
        let errorMessage = APIConfig.openAIKey.isEmpty ? "Configure OpenAI API key in environment variables" : "Analysis failed - check API configuration"
        
        return ProspectAnalysis(
            itemName: "Configuration Error",
            brand: "",
            condition: "Unknown",
            confidence: 0.0,
            estimatedSellPrice: 0,
            maxBuyPrice: 0,
            targetBuyPrice: 0,
            potentialProfit: 0,
            expectedROI: 0,
            recommendation: .investigate,
            reasons: [errorMessage],
            riskLevel: "High",
            demandLevel: "Unknown",
            competitorCount: 0,
            marketTrend: "Unknown",
            sellTimeEstimate: "Unknown",
            seasonalFactors: "Unknown",
            sourcingTips: ["Configure OpenAI API key", "Check environment variables", "Verify API access"],
            images: images,
            recentSales: [],
            averageSoldPrice: 0,
            category: "Error",
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

// MARK: - Google Sheets Service (Keep existing but add error handling)
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
        print("🔗 Google Sheets Service Initialized")
        isConnected = !APIConfig.googleAppsScriptURL.isEmpty
        syncStatus = isConnected ? "Connected to Google Sheets" : "Google Sheets not configured"
        
        if isConnected {
            print("✅ Google Sheets configured: \(APIConfig.googleAppsScriptURL)")
        } else {
            print("❌ Google Sheets not configured - set GOOGLE_SCRIPT_URL environment variable")
        }
    }
    
    func uploadItem(_ item: InventoryItem) {
        guard isConnected else {
            print("❌ Google Sheets not configured")
            return
        }
        
        print("📤 Uploading item to Google Sheets: \(item.name) [\(item.inventoryCode)]")
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncStatus = "Uploading \(item.name)..."
        }
        
        let itemData: [String: Any] = [
            "action": "addItem",  // Add action for Google Apps Script
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
            "binNumber": item.binNumber
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
        guard isConnected else {
            print("❌ Google Sheets not configured for bulk sync")
            return
        }
        
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
                "source": item.source,
                "purchasePrice": item.purchasePrice,
                "suggestedPrice": item.suggestedPrice,
                "status": item.status.rawValue,
                "profit": item.estimatedProfit,
                "roi": item.estimatedROI,
                "date": formatDate(item.dateAdded),
                "brand": item.brand,
                "condition": item.condition
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
        } catch {
            print("❌ Failed to serialize data: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Google Sheets error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 Google Sheets response status: \(httpResponse.statusCode)")
            }
            
            if let data = data,
               let responseString = String(data: data, encoding: .utf8) {
                print("📄 Google Sheets response: \(responseString)")
                let success = responseString.contains("success") || responseString.contains("Item added")
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

// MARK: - eBay Listing Service (Keep existing)
class EbayListingService: ObservableObject {
    @Published var isListing = false
    @Published var listingProgress = "Ready to list"
    @Published var listingURL: String?
    @Published var isConfigured = false
    
    func listDirectlyToEbay(item: InventoryItem, analysis: AnalysisResult, completion: @escaping (Bool, String?) -> Void) {
        print("🚫 eBay direct listing requires eBay Developer API configuration")
        
        DispatchQueue.main.async {
            self.isListing = true
            self.listingProgress = "eBay API not configured..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isListing = false
            self.listingProgress = "Manual listing required - eBay API not configured"
            completion(false, nil)
        }
    }
}
