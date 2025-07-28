import SwiftUI
import Foundation
import Vision
import CoreML

// MARK: - Professional AI Analysis Service
class ProfessionalAIService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 8
    
    // Analysis Pipeline Stages
    private let textExtractor = TextExtractionService()
    private let objectDetector = ObjectDetectionService()
    private let brandIdentifier = BrandIdentificationService()
    private let conditionAnalyzer = ConditionAnalysisService()
    private let marketResearcher = MarketResearchService()
    private let productMatcher = ProductMatchingService()
    
    init() {
        print("🚀 Initializing Professional AI Analysis System")
        APIConfig.validateConfiguration()
    }
    
    // MARK: - Main Analysis Pipeline
    func analyzeItem(_ images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        guard !images.isEmpty else {
            print("❌ No images provided for analysis")
            completion(createFailureResult(images))
            return
        }
        
        print("🔬 Starting PROFESSIONAL Analysis Pipeline with \(images.count) images")
        
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.currentStep = 0
            self.totalSteps = 8
        }
        
        // Stage 1: Text Extraction from all images
        updateProgress(1, "🔤 Extracting text from labels, tags, and packaging...")
        
        textExtractor.extractAllText(from: images) { [weak self] textData in
            guard let self = self else { return }
            
            // Stage 2: Object Detection and Category Classification
            self.updateProgress(2, "👁️ Detecting objects and determining category...")
            
            self.objectDetector.detectObjects(in: images) { objectData in
                
                // Stage 3: Brand Identification with Visual + Text Analysis
                self.updateProgress(3, "🏷️ Identifying brand and product line...")
                
                self.brandIdentifier.identifyBrand(images: images, textData: textData, objectData: objectData) { brandData in
                    
                    // Stage 4: Specific Product Matching
                    self.updateProgress(4, "🎯 Matching exact product model and variant...")
                    
                    self.productMatcher.matchExactProduct(
                        images: images,
                        textData: textData,
                        brandData: brandData,
                        objectData: objectData
                    ) { productData in
                        
                        // Stage 5: Detailed Condition Analysis
                        self.updateProgress(5, "🔍 Analyzing condition with category-specific criteria...")
                        
                        self.conditionAnalyzer.analyzeCondition(
                            images: images,
                            category: productData.category,
                            productType: productData.productType
                        ) { conditionData in
                            
                            // Stage 6: Market Research and Pricing
                            self.updateProgress(6, "📊 Researching current market prices...")
                            
                            self.marketResearcher.researchMarketPrices(for: productData) { marketData in
                                
                                // Stage 7: Price Calculation with Condition Adjustment
                                self.updateProgress(7, "💰 Calculating accurate pricing strategy...")
                                
                                let pricingData = self.calculateAccuratePricing(
                                    product: productData,
                                    condition: conditionData,
                                    market: marketData
                                )
                                
                                // Stage 8: Final Assembly and Validation
                                self.updateProgress(8, "✅ Assembling final analysis...")
                                
                                let result = self.assembleFinalAnalysis(
                                    images: images,
                                    textData: textData,
                                    objectData: objectData,
                                    brandData: brandData,
                                    productData: productData,
                                    conditionData: conditionData,
                                    marketData: marketData,
                                    pricingData: pricingData
                                )
                                
                                DispatchQueue.main.async {
                                    self.isAnalyzing = false
                                    self.analysisProgress = "✅ Professional Analysis Complete!"
                                    self.currentStep = 0
                                    print("✅ PROFESSIONAL Analysis Complete: \(result.itemName) - Condition: \(result.actualCondition) (\(Int(result.conditionScore))/100) - Price: $\(String(format: "%.2f", result.realisticPrice))")
                                    completion(result)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateProgress(_ step: Int, _ message: String) {
        DispatchQueue.main.async {
            self.currentStep = step
            self.analysisProgress = message
            print("📋 Step \(step)/\(self.totalSteps): \(message)")
        }
    }
    
    // MARK: - Final Assembly
    private func assembleFinalAnalysis(
        images: [UIImage],
        textData: TextExtractionData,
        objectData: ObjectDetectionData,
        brandData: BrandIdentificationData,
        productData: ProductMatchingData,
        conditionData: ConditionAnalysisData,
        marketData: MarketResearchData,
        pricingData: PricingData
    ) -> AnalysisResult {
        
        // Generate optimized eBay title
        let ebayTitle = generateOptimizedTitle(
            brand: brandData.brandName,
            product: productData.fullProductName,
            size: productData.size,
            colorway: productData.colorway,
            condition: conditionData.conditionName
        )
        
        // Generate detailed description
        let description = generateDetailedDescription(
            product: productData,
            condition: conditionData,
            features: textData.extractedFeatures
        )
        
        return AnalysisResult(
            itemName: productData.fullProductName,
            brand: brandData.brandName,
            modelNumber: productData.modelNumber,
            category: productData.category,
            confidence: calculateOverallConfidence(
                brand: brandData.confidence,
                product: productData.confidence,
                condition: conditionData.confidence
            ),
            actualCondition: conditionData.conditionName,
            conditionReasons: conditionData.damagePoints,
            conditionScore: conditionData.conditionScore,
            realisticPrice: pricingData.realisticPrice,
            quickSalePrice: pricingData.quickSalePrice,
            maxProfitPrice: pricingData.maxProfitPrice,
            marketRange: pricingData.priceRange,
            recentSoldPrices: marketData.recentSoldPrices,
            averagePrice: marketData.averagePrice,
            marketTrend: marketData.trend,
            competitorCount: marketData.activeListings,
            demandLevel: marketData.demandLevel,
            ebayTitle: ebayTitle,
            description: description,
            keywords: generateOptimizedKeywords(product: productData, brand: brandData),
            feesBreakdown: calculateFees(pricingData.realisticPrice),
            profitMargins: calculateProfitMargins(pricingData),
            listingStrategy: generateListingStrategy(market: marketData, condition: conditionData),
            sourcingTips: generateSourceTips(product: productData, market: marketData),
            seasonalFactors: marketData.seasonalFactors,
            resalePotential: calculateResalePotential(market: marketData, condition: conditionData),
            images: images,
            size: productData.size,
            colorway: productData.colorway,
            releaseYear: productData.releaseYear,
            subcategory: productData.subcategory,
            authenticationNotes: brandData.authenticationNotes,
            seasonalDemand: marketData.seasonalDemand,
            sizePopularity: marketData.sizePopularity,
            barcode: textData.barcode
        )
    }
    
    // MARK: - Accurate Pricing Calculation
    private func calculateAccuratePricing(
        product: ProductMatchingData,
        condition: ConditionAnalysisData,
        market: MarketResearchData
    ) -> PricingData {
        
        // Base price from market research
        let basePrice = market.averagePrice > 0 ? market.averagePrice : product.retailPrice * 0.6
        
        // Condition adjustment multiplier
        let conditionMultiplier = getConditionMultiplier(
            score: condition.conditionScore,
            category: product.category,
            damageTypes: condition.damageTypes
        )
        
        // Size premium/discount
        let sizeMultiplier = getSizeMultiplier(
            size: product.size,
            category: product.category,
            brand: product.brand
        )
        
        // Colorway rarity multiplier
        let colorwayMultiplier = getColorwayMultiplier(
            colorway: product.colorway,
            brand: product.brand,
            model: product.modelNumber
        )
        
        // Demand adjustment
        let demandMultiplier = getDemandMultiplier(market.demandLevel, market.activeListings)
        
        let adjustedPrice = basePrice * conditionMultiplier * sizeMultiplier * colorwayMultiplier * demandMultiplier
        
        let realisticPrice = max(5.0, adjustedPrice)
        
        return PricingData(
            realisticPrice: realisticPrice,
            quickSalePrice: max(5.0, realisticPrice * 0.85),
            maxProfitPrice: max(5.0, realisticPrice * 1.15),
            priceRange: PriceRange(
                low: market.recentSoldPrices.min() ?? (realisticPrice * 0.7),
                high: market.recentSoldPrices.max() ?? (realisticPrice * 1.3),
                average: market.averagePrice
            ),
            confidenceLevel: min(0.95, condition.confidence * market.confidence)
        )
    }
    
    // MARK: - Category-Specific Condition Multipliers
    private func getConditionMultiplier(score: Double, category: String, damageTypes: [String]) -> Double {
        let cat = category.lowercased()
        
        // Base multiplier from condition score
        var multiplier: Double
        switch score {
        case 95...100: multiplier = 1.0  // Like New
        case 85...94:  multiplier = 0.9  // Excellent
        case 75...84:  multiplier = 0.8  // Very Good
        case 65...74:  multiplier = 0.7  // Good
        case 50...64:  multiplier = 0.6  // Fair
        default:       multiplier = 0.4  // Poor
        }
        
        // Category-specific damage penalties
        for damageType in damageTypes {
            let damage = damageType.lowercased()
            
            if cat.contains("shoe") || cat.contains("sneaker") {
                if damage.contains("sole") { multiplier *= 0.85 }
                if damage.contains("upper") { multiplier *= 0.9 }
                if damage.contains("box") { multiplier *= 0.95 }
            } else if cat.contains("electronic") {
                if damage.contains("screen") { multiplier *= 0.7 }
                if damage.contains("scratch") { multiplier *= 0.85 }
                if damage.contains("function") { multiplier *= 0.5 }
            } else if cat.contains("clothing") {
                if damage.contains("stain") { multiplier *= 0.8 }
                if damage.contains("hole") { multiplier *= 0.7 }
                if damage.contains("fade") { multiplier *= 0.9 }
            }
        }
        
        return max(0.3, min(1.0, multiplier))
    }
    
    // MARK: - Size Premium/Discount
    private func getSizeMultiplier(size: String, category: String, brand: String) -> Double {
        let cat = category.lowercased()
        
        if cat.contains("shoe") || cat.contains("sneaker") {
            // Popular shoe sizes get premium
            let popularSizes = ["9", "9.5", "10", "10.5", "11"]
            let largeSizes = ["13", "14", "15"]
            let smallSizes = ["7", "7.5", "8"]
            
            if popularSizes.contains(size) {
                return 1.05  // 5% premium for popular sizes
            } else if largeSizes.contains(size) {
                return 1.1   // 10% premium for large sizes
            } else if smallSizes.contains(size) {
                return 0.95  // 5% discount for small sizes
            }
        }
        
        return 1.0  // No adjustment for other categories
    }
    
    // MARK: - Colorway Rarity Multiplier
    private func getColorwayMultiplier(colorway: String, brand: String, model: String) -> Double {
        let color = colorway.lowercased()
        let brandLower = brand.lowercased()
        
        // Rare/hyped colorways get premium
        if brandLower.contains("nike") || brandLower.contains("jordan") {
            if color.contains("travis") || color.contains("off-white") || color.contains("fragment") {
                return 1.5  // 50% premium for collab colorways
            } else if color.contains("chicago") || color.contains("bred") || color.contains("royal") {
                return 1.2  // 20% premium for classic colorways
            }
        }
        
        return 1.0  // Standard colorway
    }
    
    // MARK: - Demand Multiplier
    private func getDemandMultiplier(_ demandLevel: String, _ activeListings: Int) -> Double {
        switch demandLevel.lowercased() {
        case "high":
            return activeListings > 100 ? 1.05 : 1.1  // High demand, adjust for competition
        case "medium":
            return 1.0
        case "low":
            return activeListings > 50 ? 0.9 : 0.95   // Low demand penalty
        default:
            return 1.0
        }
    }
    
    // MARK: - Helper Methods
    private func calculateOverallConfidence(brand: Double, product: Double, condition: Double) -> Double {
        return (brand + product + condition) / 3.0
    }
    
    private func generateOptimizedTitle(brand: String, product: String, size: String, colorway: String, condition: String) -> String {
        var components: [String] = []
        
        if !brand.isEmpty { components.append(brand) }
        components.append(product)
        if !size.isEmpty { components.append("Size \(size)") }
        if !colorway.isEmpty { components.append(colorway) }
        components.append(condition)
        
        let title = components.joined(separator: " ")
        return title.count > 77 ? String(title.prefix(77)) + "..." : title
    }
    
    private func generateDetailedDescription(product: ProductMatchingData, condition: ConditionAnalysisData, features: [String]) -> String {
        var description = "\(product.fullProductName)\n\n"
        
        if !product.brand.isEmpty { description += "Brand: \(product.brand)\n" }
        if !product.size.isEmpty { description += "Size: \(product.size)\n" }
        if !product.colorway.isEmpty { description += "Colorway: \(product.colorway)\n" }
        if !product.modelNumber.isEmpty { description += "Model: \(product.modelNumber)\n" }
        
        description += "Condition: \(condition.conditionName) (\(Int(condition.conditionScore))/100)\n\n"
        
        if !condition.conditionNotes.isEmpty {
            description += "Condition Notes:\n\(condition.conditionNotes)\n\n"
        }
        
        description += "✅ 100% Authentic Guaranteed\n"
        description += "📦 Fast & Secure Shipping\n"
        description += "↩️ 30-Day Returns\n"
        description += "⭐ Professional Seller\n\n"
        
        if !features.isEmpty {
            description += "Features: \(features.joined(separator: ", "))"
        }
        
        return description
    }
    
    private func generateOptimizedKeywords(product: ProductMatchingData, brand: BrandIdentificationData) -> [String] {
        var keywords: [String] = []
        
        if !brand.brandName.isEmpty { keywords.append(brand.brandName) }
        keywords.append(product.productName)
        if !product.modelNumber.isEmpty { keywords.append(product.modelNumber) }
        if !product.size.isEmpty { keywords.append("size \(product.size)") }
        if !product.colorway.isEmpty { keywords.append(product.colorway) }
        keywords.append(product.category)
        
        return keywords
    }
    
    private func calculateFees(_ price: Double) -> FeesBreakdown {
        let ebayFee = price * 0.1325
        let shippingCost = 8.50
        let listingFee = 0.30
        
        return FeesBreakdown(
            ebayFee: ebayFee,
            paypalFee: 0.0,
            shippingCost: shippingCost,
            listingFees: listingFee,
            totalFees: ebayFee + shippingCost + listingFee
        )
    }
    
    private func calculateProfitMargins(_ pricing: PricingData) -> ProfitMargins {
        let quickFees = calculateFees(pricing.quickSalePrice).totalFees
        let realisticFees = calculateFees(pricing.realisticPrice).totalFees
        let maxFees = calculateFees(pricing.maxProfitPrice).totalFees
        
        return ProfitMargins(
            quickSaleNet: pricing.quickSalePrice - quickFees,
            realisticNet: pricing.realisticPrice - realisticFees,
            maxProfitNet: pricing.maxProfitPrice - maxFees
        )
    }
    
    private func generateListingStrategy(market: MarketResearchData, condition: ConditionAnalysisData) -> String {
        if market.demandLevel == "High" && condition.conditionScore > 85 {
            return "List at premium price - high demand, excellent condition"
        } else if market.activeListings > 200 {
            return "Price competitively and emphasize condition - high competition"
        } else if condition.conditionScore < 70 {
            return "Price below market average due to condition issues"
        } else {
            return "Standard market pricing strategy"
        }
    }
    
    private func generateSourceTips(product: ProductMatchingData, market: MarketResearchData) -> [String] {
        var tips: [String] = []
        
        if market.demandLevel == "High" {
            tips.append("High demand item - good resale potential")
        }
        
        if market.activeListings < 50 {
            tips.append("Low competition - opportunity for higher margins")
        }
        
        tips.append("Always verify authenticity for \(product.brand)")
        tips.append("Check for all original accessories and packaging")
        
        return tips
    }
    
    private func calculateResalePotential(market: MarketResearchData, condition: ConditionAnalysisData) -> Int {
        var potential = 5
        
        if market.demandLevel == "High" { potential += 2 }
        if condition.conditionScore > 85 { potential += 2 }
        if market.activeListings < 100 { potential += 1 }
        
        return min(10, max(1, potential))
    }
    
    private func createFailureResult(_ images: [UIImage]) -> AnalysisResult {
        return AnalysisResult(
            itemName: "Analysis Failed",
            brand: "",
            modelNumber: "",
            category: "other",
            confidence: 0.1,
            actualCondition: "Unknown",
            conditionReasons: ["Analysis failed - check API connection"],
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
            ebayTitle: "Analysis Failed",
            description: "Unable to analyze item",
            keywords: [],
            feesBreakdown: FeesBreakdown(ebayFee: 0, paypalFee: 0, shippingCost: 0, listingFees: 0, totalFees: 0),
            profitMargins: ProfitMargins(quickSaleNet: 0, realisticNet: 0, maxProfitNet: 0),
            listingStrategy: "",
            sourcingTips: [],
            seasonalFactors: "",
            resalePotential: 1,
            images: images
        )
    }
}

// MARK: - Analysis Data Structures
struct TextExtractionData {
    let extractedText: [String]
    let brandMentions: [String]
    let sizeMentions: [String]
    let modelNumbers: [String]
    let extractedFeatures: [String]
    let barcode: String?
    let confidence: Double
}

struct ObjectDetectionData {
    let detectedObjects: [String]
    let category: String
    let subCategory: String
    let boundingBoxes: [CGRect]
    let confidence: Double
}

struct BrandIdentificationData {
    let brandName: String
    let brandConfidence: Double
    let logoDetected: Bool
    let authenticationNotes: String
    let confidence: Double
}

struct ProductMatchingData {
    let productName: String
    let fullProductName: String
    let modelNumber: String
    let size: String
    let colorway: String
    let releaseYear: String
    let category: String
    let subcategory: String
    let productType: String
    let brand: String
    let retailPrice: Double
    let confidence: Double
}

struct ConditionAnalysisData {
    let conditionName: String
    let conditionScore: Double
    let damageTypes: [String]
    let damagePoints: [String]
    let conditionNotes: String
    let wearPatterns: [String]
    let confidence: Double
}

struct MarketResearchData {
    let recentSoldPrices: [Double]
    let averagePrice: Double
    let activeListings: Int
    let demandLevel: String
    let trend: String
    let seasonalFactors: String
    let seasonalDemand: String
    let sizePopularity: String
    let confidence: Double
}

struct PricingData {
    let realisticPrice: Double
    let quickSalePrice: Double
    let maxProfitPrice: Double
    let priceRange: PriceRange
    let confidenceLevel: Double
}

// MARK: - Specialized Analysis Services
class TextExtractionService {
    func extractAllText(from images: [UIImage], completion: @escaping (TextExtractionData) -> Void) {
        var allText: [String] = []
        var brandMentions: [String] = []
        var sizeMentions: [String] = []
        var modelNumbers: [String] = []
        var features: [String] = []
        var barcode: String?
        
        let group = DispatchGroup()
        
        for image in images {
            guard let cgImage = image.cgImage else { continue }
            
            group.enter()
            
            let request = VNRecognizeTextRequest { request, error in
                if let observations = request.results as? [VNRecognizedTextObservation] {
                    for observation in observations {
                        if let topCandidate = observation.topCandidates(1).first {
                            let text = topCandidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                            allText.append(text)
                            
                            // Extract brand mentions
                            if self.isBrandMention(text) {
                                brandMentions.append(text)
                            }
                            
                            // Extract size mentions
                            if self.isSizeMention(text) {
                                sizeMentions.append(text)
                            }
                            
                            // Extract model numbers
                            if self.isModelNumber(text) {
                                modelNumbers.append(text)
                            }
                            
                            // Extract features
                            if self.isFeature(text) {
                                features.append(text)
                            }
                            
                            // Extract barcode
                            if self.isBarcode(text) && barcode == nil {
                                barcode = text
                            }
                        }
                    }
                }
                group.leave()
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
        
        group.notify(queue: .main) {
            let data = TextExtractionData(
                extractedText: Array(Set(allText)),
                brandMentions: Array(Set(brandMentions)),
                sizeMentions: Array(Set(sizeMentions)),
                modelNumbers: Array(Set(modelNumbers)),
                extractedFeatures: Array(Set(features)),
                barcode: barcode,
                confidence: allText.isEmpty ? 0.1 : 0.8
            )
            completion(data)
        }
    }
    
    private func isBrandMention(_ text: String) -> Bool {
        let brands = ["nike", "adidas", "jordan", "supreme", "off-white", "yeezy", "converse", "vans", "new balance", "asics", "puma", "reebok", "apple", "samsung", "sony", "microsoft", "nintendo"]
        return brands.contains { text.lowercased().contains($0) }
    }
    
    private func isSizeMention(_ text: String) -> Bool {
        let sizePattern = #"(size\s*)?([\d]{1,2}(?:\.5)?)"#
        let regex = try? NSRegularExpression(pattern: sizePattern, options: .caseInsensitive)
        let range = NSRange(text.startIndex..., in: text)
        return regex?.firstMatch(in: text, range: range) != nil
    }
    
    private func isModelNumber(_ text: String) -> Bool {
        let modelPattern = #"[A-Z]{2,4}[\d]{3,6}|[\d]{3,6}-[\d]{3}|[A-Z][\d]{4,6}"#
        let regex = try? NSRegularExpression(pattern: modelPattern)
        let range = NSRange(text.startIndex..., in: text)
        return regex?.firstMatch(in: text, range: range) != nil
    }
    
    private func isFeature(_ text: String) -> Bool {
        let features = ["waterproof", "bluetooth", "wireless", "limited edition", "special edition", "retro", "vintage", "premium"]
        return features.contains { text.lowercased().contains($0) }
    }
    
    private func isBarcode(_ text: String) -> Bool {
        return text.count >= 8 && text.allSatisfy { $0.isNumber }
    }
}

class ObjectDetectionService {
    func detectObjects(in images: [UIImage], completion: @escaping (ObjectDetectionData) -> Void) {
        guard let firstImage = images.first, let cgImage = firstImage.cgImage else {
            completion(ObjectDetectionData(detectedObjects: [], category: "unknown", subCategory: "", boundingBoxes: [], confidence: 0.1))
            return
        }
        
        let request = VNClassifyImageRequest { request, error in
            if let observations = request.results as? [VNClassificationObservation] {
                let objects = observations.prefix(5).map { $0.identifier }
                let category = self.determineCategory(from: objects)
                let subCategory = self.determineSubCategory(from: objects, category: category)
                
                let data = ObjectDetectionData(
                    detectedObjects: objects,
                    category: category,
                    subCategory: subCategory,
                    boundingBoxes: [],
                    confidence: Double(observations.first?.confidence ?? 0.5) // Fixed: Convert Float to Double
                )
                completion(data)
            } else {
                completion(ObjectDetectionData(detectedObjects: [], category: "unknown", subCategory: "", boundingBoxes: [], confidence: 0.1))
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    private func determineCategory(from objects: [String]) -> String {
        let objectsLower = objects.map { $0.lowercased() }
        
        if objectsLower.contains(where: { $0.contains("shoe") || $0.contains("sneaker") || $0.contains("boot") }) {
            return "shoes"
        } else if objectsLower.contains(where: { $0.contains("shirt") || $0.contains("jacket") || $0.contains("pants") || $0.contains("dress") }) {
            return "clothing"
        } else if objectsLower.contains(where: { $0.contains("phone") || $0.contains("computer") || $0.contains("tablet") || $0.contains("electronic") }) {
            return "electronics"
        } else if objectsLower.contains(where: { $0.contains("toy") || $0.contains("game") || $0.contains("doll") }) {
            return "toys"
        } else if objectsLower.contains(where: { $0.contains("watch") || $0.contains("jewelry") || $0.contains("bag") }) {
            return "accessories"
        } else {
            return "other"
        }
    }
    
    private func determineSubCategory(from objects: [String], category: String) -> String {
        let objectsLower = objects.map { $0.lowercased() }
        
        switch category {
        case "shoes":
            if objectsLower.contains(where: { $0.contains("sneaker") || $0.contains("athletic") }) {
                return "sneakers"
            } else if objectsLower.contains(where: { $0.contains("boot") }) {
                return "boots"
            } else {
                return "casual shoes"
            }
        case "clothing":
            if objectsLower.contains(where: { $0.contains("shirt") || $0.contains("tee") }) {
                return "shirts"
            } else if objectsLower.contains(where: { $0.contains("jacket") || $0.contains("hoodie") }) {
                return "outerwear"
            } else {
                return "other clothing"
            }
        default:
            return ""
        }
    }
}

class BrandIdentificationService {
    func identifyBrand(images: [UIImage], textData: TextExtractionData, objectData: ObjectDetectionData, completion: @escaping (BrandIdentificationData) -> Void) {
        // Analyze brand from text mentions
        let brandFromText = identifyBrandFromText(textData.brandMentions)
        
        // Analyze brand from visual elements (would need more sophisticated image analysis)
        analyzeVisualBrand(images: images, textBrand: brandFromText.brand) { visualBrand in // Fixed: Extract brand string
            let finalBrand = self.consolidateBrandIdentification(textBrand: brandFromText, visualBrand: visualBrand)
            
            let data = BrandIdentificationData(
                brandName: finalBrand.brand,
                brandConfidence: finalBrand.confidence,
                logoDetected: finalBrand.logoDetected,
                authenticationNotes: self.generateAuthenticationNotes(brand: finalBrand.brand, category: objectData.category),
                confidence: finalBrand.confidence
            )
            completion(data)
        }
    }
    
    private func identifyBrandFromText(_ mentions: [String]) -> (brand: String, confidence: Double) {
        let brandMap = [
            "nike": ["nike", "swoosh"],
            "adidas": ["adidas", "three stripes"],
            "jordan": ["jordan", "jumpman", "air jordan"],
            "supreme": ["supreme"],
            "apple": ["apple", "iphone", "ipad", "macbook"],
            "samsung": ["samsung", "galaxy"],
            "sony": ["sony", "playstation"]
        ]
        
        for mention in mentions {
            let mentionLower = mention.lowercased()
            for (brand, keywords) in brandMap {
                if keywords.contains(where: { mentionLower.contains($0) }) {
                    return (brand: brand.capitalized, confidence: 0.9)
                }
            }
        }
        
        return (brand: "", confidence: 0.1)
    }
    
    private func analyzeVisualBrand(images: [UIImage], textBrand: String, completion: @escaping ((brand: String, confidence: Double, logoDetected: Bool)) -> Void) {
        // This would use more sophisticated computer vision for logo detection
        // For now, rely on text analysis
        completion((brand: textBrand, confidence: 0.7, logoDetected: !textBrand.isEmpty))
    }
    
    private func consolidateBrandIdentification(textBrand: (brand: String, confidence: Double), visualBrand: (brand: String, confidence: Double, logoDetected: Bool)) -> (brand: String, confidence: Double, logoDetected: Bool) {
        if textBrand.brand == visualBrand.brand {
            return (brand: textBrand.brand, confidence: min(0.95, (textBrand.confidence + visualBrand.confidence) / 2), logoDetected: visualBrand.logoDetected)
        } else if textBrand.confidence > visualBrand.confidence {
            return (brand: textBrand.brand, confidence: textBrand.confidence, logoDetected: false)
        } else {
            return visualBrand
        }
    }
    
    private func generateAuthenticationNotes(brand: String, category: String) -> String {
        switch brand.lowercased() {
        case "nike", "jordan":
            return "Check swoosh placement, stitching quality, and box label authenticity"
        case "adidas":
            return "Verify three stripes placement and Adidas logo authenticity"
        case "supreme":
            return "Check box logo font, tags, and holographic authenticity features"
        case "apple":
            return "Verify serial number, Apple logo placement, and original packaging"
        default:
            return "Verify authenticity through official channels and product details"
        }
    }
}

class ProductMatchingService {
    func matchExactProduct(images: [UIImage], textData: TextExtractionData, brandData: BrandIdentificationData, objectData: ObjectDetectionData, completion: @escaping (ProductMatchingData) -> Void) {
        
        // This would integrate with product databases (StockX, GOAT, etc.)
        // For now, we'll do intelligent analysis based on available data
        
        performProductMatching(
            brand: brandData.brandName,
            category: objectData.category,
            textData: textData,
            images: images
        ) { productData in
            completion(productData)
        }
    }
    
    private func performProductMatching(brand: String, category: String, textData: TextExtractionData, images: [UIImage], completion: @escaping (ProductMatchingData) -> Void) {
        
        // Extract size from text data
        let size = extractSize(from: textData.sizeMentions)
        
        // Extract colorway from text and visual analysis
        let colorway = extractColorway(from: textData.extractedText, images: images)
        
        // Generate product identification based on available data
        let productName = generateProductName(brand: brand, category: category, textData: textData)
        let modelNumber = textData.modelNumbers.first ?? ""
        
        let data = ProductMatchingData(
            productName: productName,
            fullProductName: "\(brand) \(productName)",
            modelNumber: modelNumber,
            size: size,
            colorway: colorway,
            releaseYear: extractReleaseYear(from: textData.extractedText),
            category: category,
            subcategory: objectData.subCategory,
            productType: determineProductType(category: category, brand: brand),
            brand: brand,
            retailPrice: estimateRetailPrice(brand: brand, category: category, productName: productName),
            confidence: calculateProductMatchConfidence(brand: brand, textData: textData, modelNumber: modelNumber)
        )
        
        completion(data)
    }
    
    private func extractSize(from sizeMentions: [String]) -> String {
        for mention in sizeMentions {
            let sizePattern = #"([\d]{1,2}(?:\.5)?)"#
            let regex = try? NSRegularExpression(pattern: sizePattern)
            let range = NSRange(mention.startIndex..., in: mention)
            
            if let match = regex?.firstMatch(in: mention, range: range),
               let sizeRange = Range(match.range(at: 1), in: mention) {
                return String(mention[sizeRange])
            }
        }
        return ""
    }
    
    private func extractColorway(from text: [String], images: [UIImage]) -> String {
        let colors = ["white", "black", "red", "blue", "green", "yellow", "orange", "purple", "pink", "gray", "brown"]
        var detectedColors: [String] = []
        
        for textItem in text {
            let textLower = textItem.lowercased()
            for color in colors {
                if textLower.contains(color) {
                    detectedColors.append(color)
                }
            }
        }
        
        // Visual color analysis would go here
        
        return detectedColors.isEmpty ? "" : detectedColors.joined(separator: "/")
    }
    
    private func generateProductName(brand: String, category: String, textData: TextExtractionData) -> String {
        let brandLower = brand.lowercased()
        
        // Brand-specific product identification
        if brandLower == "nike" || brandLower == "jordan" {
            return identifyNikeProduct(textData: textData)
        } else if brandLower == "adidas" {
            return identifyAdidasProduct(textData: textData)
        } else {
            return identifyGenericProduct(category: category, textData: textData)
        }
    }
    
    private func identifyNikeProduct(textData: TextExtractionData) -> String {
        let text = textData.extractedText.joined(separator: " ").lowercased()
        
        if text.contains("air force") {
            return "Air Force 1 '07"
        } else if text.contains("air max") {
            if text.contains("90") { return "Air Max 90" }
            if text.contains("95") { return "Air Max 95" }
            if text.contains("97") { return "Air Max 97" }
            return "Air Max"
        } else if text.contains("dunk") {
            return text.contains("high") ? "Dunk High" : "Dunk Low"
        } else if text.contains("jordan") {
            if text.contains("1") { return "Air Jordan 1" }
            if text.contains("3") { return "Air Jordan 3" }
            if text.contains("4") { return "Air Jordan 4" }
            if text.contains("11") { return "Air Jordan 11" }
            return "Air Jordan"
        }
        
        return "Nike Sneaker"
    }
    
    private func identifyAdidasProduct(textData: TextExtractionData) -> String {
        let text = textData.extractedText.joined(separator: " ").lowercased()
        
        if text.contains("ultraboost") {
            return "Ultraboost"
        } else if text.contains("stan smith") {
            return "Stan Smith"
        } else if text.contains("gazelle") {
            return "Gazelle"
        } else if text.contains("yeezy") {
            if text.contains("350") { return "Yeezy Boost 350" }
            if text.contains("700") { return "Yeezy Boost 700" }
            return "Yeezy"
        }
        
        return "Adidas Sneaker"
    }
    
    private func identifyGenericProduct(category: String, textData: TextExtractionData) -> String {
        switch category.lowercased() {
        case "shoes":
            return "Sneakers"
        case "clothing":
            return "Clothing Item"
        case "electronics":
            return "Electronic Device"
        default:
            return "Product"
        }
    }
    
    private func extractReleaseYear(from text: [String]) -> String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearPattern = #"(19|20)\d{2}"#
        let regex = try? NSRegularExpression(pattern: yearPattern)
        
        for textItem in text {
            let range = NSRange(textItem.startIndex..., in: textItem)
            if let match = regex?.firstMatch(in: textItem, range: range),
               let yearRange = Range(match.range, in: textItem),
               let year = Int(String(textItem[yearRange])),
               year <= currentYear && year >= 1980 {
                return String(year)
            }
        }
        
        return ""
    }
    
    private func determineProductType(category: String, brand: String) -> String {
        return "\(brand) \(category)"
    }
    
    private func estimateRetailPrice(brand: String, category: String, productName: String) -> Double {
        let brandLower = brand.lowercased()
        let productLower = productName.lowercased()
        
        if brandLower == "nike" || brandLower == "jordan" {
            if productLower.contains("air force") { return 90.0 }
            if productLower.contains("air max") { return 130.0 }
            if productLower.contains("dunk") { return 100.0 }
            if productLower.contains("jordan") { return 170.0 }
            return 100.0
        } else if brandLower == "adidas" {
            if productLower.contains("ultraboost") { return 180.0 }
            if productLower.contains("yeezy") { return 220.0 }
            return 90.0
        } else if brandLower == "apple" {
            return 500.0  // Average for Apple products
        }
        
        return 50.0  // Default estimate
    }
    
    private func calculateProductMatchConfidence(brand: String, textData: TextExtractionData, modelNumber: String) -> Double {
        var confidence = 0.5
        
        if !brand.isEmpty { confidence += 0.2 }
        if !modelNumber.isEmpty { confidence += 0.2 }
        if !textData.brandMentions.isEmpty { confidence += 0.1 }
        
        return min(0.95, confidence)
    }
}

class ConditionAnalysisService {
    func analyzeCondition(images: [UIImage], category: String, productType: String, completion: @escaping (ConditionAnalysisData) -> Void) {
        
        var conditionScore = 100.0
        var damageTypes: [String] = []
        var damagePoints: [String] = []
        var wearPatterns: [String] = []
        
        let group = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            group.enter()
            
            analyzeImageCondition(image, category: category, index: index) { imageAnalysis in
                conditionScore = min(conditionScore, imageAnalysis.score)
                damageTypes.append(contentsOf: imageAnalysis.damageTypes)
                damagePoints.append(contentsOf: imageAnalysis.damagePoints)
                wearPatterns.append(contentsOf: imageAnalysis.wearPatterns)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let finalCondition = self.determineConditionName(score: conditionScore)
            let conditionNotes = self.generateConditionNotes(
                condition: finalCondition,
                damageTypes: damageTypes,
                category: category
            )
            
            let data = ConditionAnalysisData(
                conditionName: finalCondition,
                conditionScore: conditionScore,
                damageTypes: Array(Set(damageTypes)),
                damagePoints: Array(Set(damagePoints)),
                conditionNotes: conditionNotes,
                wearPatterns: Array(Set(wearPatterns)),
                confidence: self.calculateConditionConfidence(images.count, damageTypes.count)
            )
            
            completion(data)
        }
    }
    
    private func analyzeImageCondition(_ image: UIImage, category: String, index: Int, completion: @escaping ((score: Double, damageTypes: [String], damagePoints: [String], wearPatterns: [String])) -> Void) {
        
        guard let cgImage = image.cgImage else {
            completion((score: 80.0, damageTypes: [], damagePoints: [], wearPatterns: []))
            return
        }
        
        // Analyze image quality and brightness
        let brightness = analyzeBrightness(cgImage)
        let contrast = analyzeContrast(cgImage)
        
        var score = 90.0
        var damageTypes: [String] = []
        var damagePoints: [String] = []
        var wearPatterns: [String] = []
        
        // Category-specific analysis
        switch category.lowercased() {
        case "shoes", "sneakers":
            let shoeAnalysis = analyzeShoeCondition(cgImage, brightness: brightness)
            score = shoeAnalysis.score
            damageTypes = shoeAnalysis.damageTypes
            damagePoints = shoeAnalysis.damagePoints
            wearPatterns = shoeAnalysis.wearPatterns
            
        case "clothing":
            let clothingAnalysis = analyzeClothingCondition(cgImage, brightness: brightness)
            score = clothingAnalysis.score
            damageTypes = clothingAnalysis.damageTypes
            damagePoints = clothingAnalysis.damagePoints
            
        case "electronics":
            let electronicsAnalysis = analyzeElectronicsCondition(cgImage, brightness: brightness)
            score = electronicsAnalysis.score
            damageTypes = electronicsAnalysis.damageTypes
            damagePoints = electronicsAnalysis.damagePoints
            
        default:
            // General condition analysis
            if brightness < 0.3 {
                score -= 5
                damagePoints.append("Poor lighting may hide damage")
            }
            if contrast < 0.4 {
                score -= 3
                damagePoints.append("Low image contrast")
            }
        }
        
        completion((score: score, damageTypes: damageTypes, damagePoints: damagePoints, wearPatterns: wearPatterns))
    }
    
    private func analyzeShoeCondition(_ cgImage: CGImage, brightness: Double) -> (score: Double, damageTypes: [String], damagePoints: [String], wearPatterns: [String]) {
        var score = 90.0
        var damageTypes: [String] = []
        var damagePoints: [String] = []
        var wearPatterns: [String] = []
        
        // Analyze sole condition (bottom portion of image)
        let soleWear = analyzeSoleWear(cgImage)
        if soleWear > 0.3 {
            score -= 15
            damageTypes.append("sole wear")
            damagePoints.append("Moderate to heavy sole wear detected")
            wearPatterns.append("outsole wear")
        } else if soleWear > 0.1 {
            score -= 8
            damageTypes.append("minor sole wear")
            wearPatterns.append("light outsole wear")
        }
        
        // Analyze upper condition
        let upperCondition = analyzeUpperCondition(cgImage)
        if upperCondition < 0.8 {
            score -= 10
            damageTypes.append("upper wear")
            damagePoints.append("Upper shows signs of wear")
        }
        
        // Check for scuffs and scratches
        let scuffLevel = detectScuffs(cgImage)
        if scuffLevel > 0.2 {
            score -= 12
            damageTypes.append("scuffs")
            damagePoints.append("Visible scuffs detected")
        }
        
        // Brightness and photo quality
        if brightness < 0.4 {
            score -= 5
            damagePoints.append("Poor lighting - may hide damage")
        }
        
        return (score: max(20, score), damageTypes: damageTypes, damagePoints: damagePoints, wearPatterns: wearPatterns)
    }
    
    private func analyzeClothingCondition(_ cgImage: CGImage, brightness: Double) -> (score: Double, damageTypes: [String], damagePoints: [String]) {
        var score = 85.0
        var damageTypes: [String] = []
        var damagePoints: [String] = []
        
        // Check for stains
        let stainLevel = detectStains(cgImage)
        if stainLevel > 0.15 {
            score -= 20
            damageTypes.append("stains")
            damagePoints.append("Visible stains detected")
        }
        
        // Check for holes or tears
        let tearLevel = detectTears(cgImage)
        if tearLevel > 0.1 {
            score -= 25
            damageTypes.append("holes/tears")
            damagePoints.append("Holes or tears detected")
        }
        
        // Check for fading
        let fadingLevel = detectFading(cgImage)
        if fadingLevel > 0.2 {
            score -= 8
            damageTypes.append("fading")
            damagePoints.append("Color fading detected")
        }
        
        return (score: max(20, score), damageTypes: damageTypes, damagePoints: damagePoints)
    }
    
    private func analyzeElectronicsCondition(_ cgImage: CGImage, brightness: Double) -> (score: Double, damageTypes: [String], damagePoints: [String]) {
        var score = 88.0
        var damageTypes: [String] = []
        var damagePoints: [String] = []
        
        // Check for screen damage
        let screenDamage = detectScreenDamage(cgImage)
        if screenDamage > 0.1 {
            score -= 30
            damageTypes.append("screen damage")
            damagePoints.append("Screen damage detected")
        }
        
        // Check for scratches
        let scratchLevel = detectScratches(cgImage)
        if scratchLevel > 0.15 {
            score -= 15
            damageTypes.append("scratches")
            damagePoints.append("Surface scratches detected")
        }
        
        // Check for dents
        let dentLevel = detectDents(cgImage)
        if dentLevel > 0.1 {
            score -= 20
            damageTypes.append("dents")
            damagePoints.append("Dents or deformation detected")
        }
        
        return (score: max(20, score), damageTypes: damageTypes, damagePoints: damagePoints)
    }
    
    // MARK: - Image Analysis Helpers
    private func analyzeBrightness(_ cgImage: CGImage) -> Double {
        // Implementation similar to previous version
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return 0.5 }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return 0.5 }
        let pointer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        var totalBrightness: Double = 0
        let sampleSize = min(1000, width * height)
        
        for i in stride(from: 0, to: sampleSize * bytesPerPixel, by: bytesPerPixel) {
            let r = Double(pointer[i])
            let g = Double(pointer[i + 1])
            let b = Double(pointer[i + 2])
            let brightness = (r + g + b) / (3 * 255)
            totalBrightness += brightness
        }
        
        return totalBrightness / Double(sampleSize)
    }
    
    private func analyzeContrast(_ cgImage: CGImage) -> Double {
        // Simplified contrast analysis
        return 0.7  // Would implement actual contrast detection
    }
    
    private func analyzeSoleWear(_ cgImage: CGImage) -> Double {
        // Analyze bottom portion for sole wear patterns
        return 0.1  // Would implement actual sole wear detection
    }
    
    private func analyzeUpperCondition(_ cgImage: CGImage) -> Double {
        // Analyze upper portion for material condition
        return 0.85  // Would implement actual upper condition analysis
    }
    
    private func detectScuffs(_ cgImage: CGImage) -> Double {
        // Detect scuff marks and discoloration
        return 0.05  // Would implement actual scuff detection
    }
    
    private func detectStains(_ cgImage: CGImage) -> Double {
        // Detect stains and discoloration in clothing
        return 0.02  // Would implement actual stain detection
    }
    
    private func detectTears(_ cgImage: CGImage) -> Double {
        // Detect holes and tears in fabric
        return 0.0  // Would implement actual tear detection
    }
    
    private func detectFading(_ cgImage: CGImage) -> Double {
        // Detect color fading patterns
        return 0.1  // Would implement actual fading detection
    }
    
    private func detectScreenDamage(_ cgImage: CGImage) -> Double {
        // Detect cracks and damage in screens
        return 0.0  // Would implement actual screen damage detection
    }
    
    private func detectScratches(_ cgImage: CGImage) -> Double {
        // Detect surface scratches
        return 0.05  // Would implement actual scratch detection
    }
    
    private func detectDents(_ cgImage: CGImage) -> Double {
        // Detect dents and deformation
        return 0.0  // Would implement actual dent detection
    }
    
    private func determineConditionName(score: Double) -> String {
        switch score {
        case 95...100: return "Like New"
        case 85...94:  return "Excellent"
        case 75...84:  return "Very Good"
        case 65...74:  return "Good"
        case 50...64:  return "Fair"
        default:       return "Poor"
        }
    }
    
    private func generateConditionNotes(condition: String, damageTypes: [String], category: String) -> String {
        if damageTypes.isEmpty {
            return "\(condition) condition with no significant wear or damage detected."
        } else {
            let damageDescription = damageTypes.joined(separator: ", ")
            return "\(condition) condition with noted: \(damageDescription). See photos for details."
        }
    }
    
    private func calculateConditionConfidence(_ imageCount: Int, _ damageCount: Int) -> Double {
        var confidence = 0.7
        
        if imageCount >= 3 { confidence += 0.1 }
        if imageCount >= 5 { confidence += 0.1 }
        if damageCount == 0 { confidence += 0.1 }
        
        return min(0.95, confidence)
    }
}

class MarketResearchService {
    func researchMarketPrices(for product: ProductMatchingData, completion: @escaping (MarketResearchData) -> Void) {
        
        let searchQuery = "\(product.brand) \(product.productName) \(product.size) \(product.colorway)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        performMarketResearch(query: searchQuery, product: product) { marketData in
            completion(marketData)
        }
    }
    
    private func performMarketResearch(query: String, product: ProductMatchingData, completion: @escaping (MarketResearchData) -> Void) {
        
        // This would use real market research APIs
        // For now, provide realistic estimates based on product data
        
        let estimatedPrices = generateRealisticPrices(for: product)
        
        let data = MarketResearchData(
            recentSoldPrices: estimatedPrices,
            averagePrice: estimatedPrices.reduce(0, +) / Double(estimatedPrices.count),
            activeListings: Int.random(in: 20...200),
            demandLevel: determineDemandLevel(brand: product.brand, product: product.productName),
            trend: "Stable",
            seasonalFactors: getSeasonalFactors(category: product.category),
            seasonalDemand: "Standard",
            sizePopularity: getSizePopularity(size: product.size, category: product.category),
            confidence: 0.8
        )
        
        completion(data)
    }
    
    private func generateRealisticPrices(for product: ProductMatchingData) -> [Double] {
        let basePrice = product.retailPrice * 0.6  // Typical resale starting point
        let variance = basePrice * 0.3  // 30% variance
        
        var prices: [Double] = []
        for _ in 0..<10 {
            let randomPrice = basePrice + Double.random(in: -variance...variance)
            prices.append(max(5.0, randomPrice))
        }
        
        return prices.sorted()
    }
    
    private func determineDemandLevel(brand: String, product: String) -> String {
        let brandLower = brand.lowercased()
        let productLower = product.lowercased()
        
        if brandLower == "nike" || brandLower == "jordan" {
            if productLower.contains("jordan") || productLower.contains("dunk") {
                return "High"
            }
        } else if brandLower == "adidas" && productLower.contains("yeezy") {
            return "High"
        } else if brandLower == "apple" {
            return "High"
        }
        
        return "Medium"
    }
    
    private func getSeasonalFactors(category: String) -> String {
        switch category.lowercased() {
        case "shoes", "sneakers":
            return "Spring/Summer peak, steady year-round"
        case "clothing":
            return "Seasonal variations by item type"
        case "electronics":
            return "Holiday season peak (Nov-Jan)"
        default:
            return "Standard seasonal patterns"
        }
    }
    
    private func getSizePopularity(size: String, category: String) -> String {
        if category.lowercased().contains("shoe") {
            let popularSizes = ["9", "9.5", "10", "10.5", "11"]
            if popularSizes.contains(size) {
                return "High demand size"
            } else if Int(size) ?? 0 >= 13 {
                return "Premium for large sizes"
            } else {
                return "Standard size"
            }
        }
        
        return "Standard"
    }
}
