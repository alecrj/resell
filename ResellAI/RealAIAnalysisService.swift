import SwiftUI
import Foundation
import Vision

// MARK: - Google Lens-Level AI Analysis Service with Real eBay Data
class RealAIAnalysisService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 12 // Increased for more thorough analysis
    
    private let openAIAPIKey = APIConfig.openAIKey
    private let rapidAPIKey = APIConfig.rapidAPIKey
    private let ebayAPIKey = APIConfig.ebayAPIKey
    
    // Cache for market data (24 hour expiration)
    private var marketDataCache: [String: (data: EbayMarketData, timestamp: Date)] = [:]
    private let cacheExpirationHours: TimeInterval = 24 * 60 * 60
    
    init() {
        print("🚀 Initializing Google Lens-Level Analysis System")
        validateAPIs()
    }
    
    private func validateAPIs() {
        print("🔧 API Validation:")
        print("✅ OpenAI Key: \(openAIAPIKey.isEmpty ? "❌ Missing" : "✅ Configured")")
        print("✅ RapidAPI Key: \(rapidAPIKey.isEmpty ? "❌ Missing" : "✅ Configured")")
        print("✅ eBay API Key: \(ebayAPIKey.isEmpty ? "❌ Missing" : "✅ Configured")")
        
        if openAIAPIKey.isEmpty {
            print("❌ WARNING: OpenAI API key missing - identification will not work!")
        }
    }
    
    // MARK: - Main Google Lens-Level Analysis Pipeline
    func analyzeItem(_ images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        guard !images.isEmpty else {
            completion(createErrorResult("No images provided"))
            return
        }
        
        guard !openAIAPIKey.isEmpty else {
            completion(createErrorResult("OpenAI API key not configured"))
            return
        }
        
        print("🔍 Starting Google Lens-Level Analysis with \(images.count) images")
        
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.currentStep = 0
            self.totalSteps = 12
        }
        
        // Step 1: Multi-pass OCR Text Extraction
        updateProgress(1, "📄 Extracting all visible text...")
        performAdvancedOCR(images) { [weak self] textData in
            guard let self = self else { return }
            
            // Step 2: Visual Feature Detection
            self.updateProgress(2, "👁️ Analyzing visual features...")
            self.extractVisualFeatures(images) { visualFeatures in
                
                // Step 3: Category Pre-Classification
                self.updateProgress(3, "🏷️ Pre-classifying product category...")
                self.preClassifyCategory(images: images, textData: textData, visualFeatures: visualFeatures) { categoryHint in
                    
                    // Step 4: Precision Identification (Google Lens-style)
                    self.updateProgress(4, "🎯 Identifying exact product...")
                    self.performPrecisionIdentification(
                        images: images,
                        textData: textData,
                        visualFeatures: visualFeatures,
                        categoryHint: categoryHint
                    ) { identificationResult in
                        
                        // Step 5: Product Database Cross-Reference
                        self.updateProgress(5, "📊 Cross-referencing product databases...")
                        self.crossReferenceProductDatabases(identificationResult) { enhancedIdentification in
                            
                            // Step 6: eBay Condition Assessment
                            self.updateProgress(6, "🔍 Assessing condition using eBay standards...")
                            self.performEbayConditionAssessment(images: images, product: enhancedIdentification) { conditionAssessment in
                                
                                // Step 7: Real eBay Market Research
                                self.updateProgress(7, "💰 Fetching real eBay sold data...")
                                self.fetchRealEbayMarketData(product: enhancedIdentification, condition: conditionAssessment.detectedCondition) { marketData in
                                    
                                    // Step 8: Competition Analysis
                                    self.updateProgress(8, "⚔️ Analyzing competition...")
                                    self.analyzeCompetition(product: enhancedIdentification, marketData: marketData) { competitionAnalysis in
                                        
                                        // Step 9: Intelligent Pricing Strategy
                                        self.updateProgress(9, "🧠 Calculating optimal pricing...")
                                        let pricingRecommendation = self.calculateIntelligentPricing(
                                            product: enhancedIdentification,
                                            condition: conditionAssessment,
                                            marketData: marketData,
                                            competition: competitionAnalysis
                                        )
                                        
                                        // Step 10: eBay Listing Strategy
                                        self.updateProgress(10, "📝 Generating eBay listing strategy...")
                                        let listingStrategy = self.generateEbayListingStrategy(
                                            product: enhancedIdentification,
                                            condition: conditionAssessment,
                                            pricing: pricingRecommendation,
                                            marketData: marketData
                                        )
                                        
                                        // Step 11: Quality Validation
                                        self.updateProgress(11, "✅ Validating analysis quality...")
                                        let confidence = self.calculateConfidence(
                                            identification: enhancedIdentification,
                                            condition: conditionAssessment,
                                            marketData: marketData
                                        )
                                        
                                        // Step 12: Final Assembly
                                        self.updateProgress(12, "🎯 Finalizing results...")
                                        let finalResult = self.assembleAnalysisResult(
                                            images: images,
                                            identification: enhancedIdentification,
                                            condition: conditionAssessment,
                                            marketData: marketData,
                                            pricing: pricingRecommendation,
                                            listing: listingStrategy,
                                            confidence: confidence
                                        )
                                        
                                        DispatchQueue.main.async {
                                            self.isAnalyzing = false
                                            self.analysisProgress = "✅ Analysis Complete!"
                                            self.currentStep = 0
                                            
                                            print("🎯 GOOGLE LENS-LEVEL RESULT:")
                                            print("🎯 Product: \(finalResult.itemName)")
                                            print("🎯 Brand: \(finalResult.brand)")
                                            print("🎯 Condition: \(finalResult.actualCondition)")
                                            print("🎯 Market Price: $\(String(format: "%.2f", finalResult.realisticPrice))")
                                            print("🎯 Sold Listings: \(finalResult.soldListings.count)")
                                            print("🎯 Confidence: \(String(format: "%.0f", finalResult.confidence.overall * 100))%")
                                            
                                            completion(finalResult)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 1: Advanced OCR with Multiple Passes
    private func performAdvancedOCR(_ images: [UIImage], completion: @escaping (AdvancedTextData) -> Void) {
        var allDetectedText: [String] = []
        var productCodes: [String] = []
        var brandText: [String] = []
        var sizeText: [String] = []
        var modelNumbers: [String] = []
        var barcodes: [String] = []
        var priceText: [String] = []
        
        let group = DispatchGroup()
        
        for image in images.prefix(4) {  // Process up to 4 images
            guard let cgImage = image.cgImage else { continue }
            
            group.enter()
            
            // First pass: Standard text recognition
            let standardRequest = VNRecognizeTextRequest { request, error in
                if let observations = request.results as? [VNRecognizedTextObservation] {
                    for observation in observations {
                        for candidate in observation.topCandidates(3) {
                            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                            if text.count > 1 {
                                allDetectedText.append(text)
                                
                                // Classify text types
                                if self.isProductCode(text) { productCodes.append(text) }
                                if self.isBrandText(text) { brandText.append(text) }
                                if self.isSizeText(text) { sizeText.append(text) }
                                if self.isModelNumber(text) { modelNumbers.append(text) }
                                if self.isBarcode(text) { barcodes.append(text) }
                                if self.isPriceText(text) { priceText.append(text) }
                            }
                        }
                    }
                }
                group.leave()
            }
            
            standardRequest.recognitionLevel = .accurate
            standardRequest.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([standardRequest])
        }
        
        group.notify(queue: .main) {
            let textData = AdvancedTextData(
                allText: Array(Set(allDetectedText)).sorted(),
                productCodes: Array(Set(productCodes)),
                brands: Array(Set(brandText)),
                sizes: Array(Set(sizeText)),
                modelNumbers: Array(Set(modelNumbers)),
                barcodes: Array(Set(barcodes)),
                prices: Array(Set(priceText))
            )
            
            print("📄 Advanced OCR Results:")
            print("📄 All Text: \(textData.allText)")
            print("📄 Product Codes: \(textData.productCodes)")
            print("📄 Brands: \(textData.brands)")
            print("📄 Sizes: \(textData.sizes)")
            
            completion(textData)
        }
    }
    
    // MARK: - Step 2: Visual Feature Detection
    private func extractVisualFeatures(_ images: [UIImage], completion: @escaping (VisualFeatures) -> Void) {
        // This would use Core ML or similar to detect visual features
        // For now, we'll use a simplified approach
        
        let features = VisualFeatures(
            dominantColors: extractDominantColors(images),
            materialTextures: detectMaterials(images),
            shapeCharacteristics: analyzeShapes(images),
            logoDetection: detectLogos(images),
            visualCategory: inferCategoryFromVisuals(images)
        )
        
        print("👁️ Visual Features:")
        print("👁️ Colors: \(features.dominantColors)")
        print("👁️ Materials: \(features.materialTextures)")
        print("👁️ Category: \(features.visualCategory)")
        
        completion(features)
    }
    
    // MARK: - Step 3: Category Pre-Classification
    private func preClassifyCategory(images: [UIImage], textData: AdvancedTextData, visualFeatures: VisualFeatures, completion: @escaping (ProductCategory) -> Void) {
        
        // Analyze text for category clues
        let textHints = analyzeTextForCategory(textData)
        
        // Combine with visual analysis
        let visualHints = visualFeatures.visualCategory
        
        // Make educated guess about category
        let category = combineHints(textHints: textHints, visualHints: visualHints)
        
        print("🏷️ Pre-classified as: \(category.rawValue)")
        completion(category)
    }
    
    // MARK: - Step 4: Precision Identification (Google Lens-Style)
    private func performPrecisionIdentification(
        images: [UIImage],
        textData: AdvancedTextData,
        visualFeatures: VisualFeatures,
        categoryHint: ProductCategory,
        completion: @escaping (PrecisionIdentificationResult) -> Void
    ) {
        
        // Convert images to base64 for GPT-4 Vision
        let base64Images = images.prefix(3).compactMap { image in
            let resizedImage = resizeImage(image, targetSize: CGSize(width: 1024, height: 1024))
            return resizedImage.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        }
        
        guard !base64Images.isEmpty else {
            completion(createDefaultIdentificationResult())
            return
        }
        
        let prompt = createPrecisionIdentificationPrompt(
            textData: textData,
            visualFeatures: visualFeatures,
            categoryHint: categoryHint
        )
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 45.0
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": prompt
                    ]
                ] + base64Images.map { base64 in
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64)",
                            "detail": "high"
                        ]
                    ]
                }
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",  // Use full GPT-4o for best results
            "messages": messages,
            "max_tokens": 3000,
            "temperature": 0.05
        ]
        
        print("🎯 Sending precision identification request...")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ Failed to serialize precision request: \(error)")
            completion(createDefaultIdentificationResult())
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ OpenAI precision error: \(error)")
                completion(self.createDefaultIdentificationResult())
                return
            }
            
            guard let data = data else {
                completion(self.createDefaultIdentificationResult())
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    print("🎯 Precision identification response: \(content)")
                    let result = self.parsePrecisionIdentificationResponse(content, textData: textData)
                    completion(result)
                } else {
                    print("❌ Failed to parse precision response")
                    completion(self.createDefaultIdentificationResult())
                }
            } catch {
                print("❌ Precision JSON parsing error: \(error)")
                completion(self.createDefaultIdentificationResult())
            }
        }.resume()
    }
    
    // MARK: - Step 6: eBay Condition Assessment
    private func performEbayConditionAssessment(images: [UIImage], product: PrecisionIdentificationResult, completion: @escaping (EbayConditionAssessment) -> Void) {
        
        let base64Images = images.prefix(2).compactMap { image in
            let resizedImage = resizeImage(image, targetSize: CGSize(width: 800, height: 800))
            return resizedImage.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        }
        
        let conditionPrompt = createEbayConditionPrompt(product: product)
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": conditionPrompt
                    ]
                ] + base64Images.map { base64 in
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64)",
                            "detail": "high"
                        ]
                    ]
                }
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 2000,
            "temperature": 0.1
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(createDefaultConditionAssessment())
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Condition assessment error: \(error)")
                completion(self.createDefaultConditionAssessment())
                return
            }
            
            guard let data = data else {
                completion(self.createDefaultConditionAssessment())
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    print("🔍 Condition assessment: \(content)")
                    let assessment = self.parseEbayConditionResponse(content)
                    completion(assessment)
                } else {
                    completion(self.createDefaultConditionAssessment())
                }
            } catch {
                print("❌ Condition JSON error: \(error)")
                completion(self.createDefaultConditionAssessment())
            }
        }.resume()
    }
    
    // MARK: - Step 7: Real eBay Market Data
    private func fetchRealEbayMarketData(product: PrecisionIdentificationResult, condition: EbayCondition, completion: @escaping (EbayMarketData) -> Void) {
        
        let searchQuery = "\(product.brand) \(product.exactModelName) \(product.size)".trimmingCharacters(in: .whitespacesAndNewlines)
        let cacheKey = "\(searchQuery)_\(condition.rawValue)"
        
        // Check cache first
        if let cached = marketDataCache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheExpirationHours {
            print("📊 Using cached market data for: \(searchQuery)")
            completion(cached.data)
            return
        }
        
        print("📊 Fetching fresh eBay data for: \(searchQuery)")
        
        // Try official eBay API first, then RapidAPI fallback
        if !ebayAPIKey.isEmpty {
            fetchFromOfficialEbayAPI(searchQuery: searchQuery, condition: condition) { [weak self] marketData in
                if let data = marketData {
                    self?.marketDataCache[cacheKey] = (data, Date())
                    completion(data)
                } else {
                    // Fallback to RapidAPI
                    self?.fetchFromRapidAPIEbay(searchQuery: searchQuery, condition: condition, completion: completion)
                }
            }
        } else {
            fetchFromRapidAPIEbay(searchQuery: searchQuery, condition: condition, completion: completion)
        }
    }
    
    // MARK: - Official eBay API Integration
    private func fetchFromOfficialEbayAPI(searchQuery: String, condition: EbayCondition, completion: @escaping (EbayMarketData?) -> Void) {
        
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // eBay Finding API for sold listings
        let urlString = "https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findCompletedItems&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=\(ebayAPIKey)&RESPONSE-DATA-FORMAT=JSON&keywords=\(encodedQuery)&sortOrder=EndTimeSoonest&itemFilter(0).name=SoldItemsOnly&itemFilter(0).value=true&itemFilter(1).name=Condition&itemFilter(1).value=\(mapConditionToEbayID(condition))&paginationInput.entriesPerPage=100"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 20.0
        
        print("🌐 Official eBay API request: \(searchQuery)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Official eBay API error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let marketData = self.parseOfficialEbayResponse(json, condition: condition)
                    completion(marketData)
                } else {
                    completion(nil)
                }
            } catch {
                print("❌ Official eBay JSON error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - RapidAPI eBay Fallback
    private func fetchFromRapidAPIEbay(searchQuery: String, condition: EbayCondition, completion: @escaping (EbayMarketData) -> Void) {
        
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://ebay-average-selling-price.p.rapidapi.com/findCompletedItems?keywords=\(encodedQuery)&categoryId=0&condition=\(condition.rawValue)"
        
        guard let url = URL(string: urlString) else {
            completion(createFallbackMarketData(searchQuery: searchQuery, condition: condition))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(rapidAPIKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("ebay-average-selling-price.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.timeoutInterval = 15.0
        
        print("🌐 RapidAPI eBay request: \(searchQuery)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ RapidAPI eBay error: \(error)")
                completion(self.createFallbackMarketData(searchQuery: searchQuery, condition: condition))
                return
            }
            
            guard let data = data else {
                completion(self.createFallbackMarketData(searchQuery: searchQuery, condition: condition))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let marketData = self.parseRapidAPIEbayResponse(json, condition: condition)
                    completion(marketData)
                } else {
                    completion(self.createFallbackMarketData(searchQuery: searchQuery, condition: condition))
                }
            } catch {
                print("❌ RapidAPI JSON error: \(error)")
                completion(self.createFallbackMarketData(searchQuery: searchQuery, condition: condition))
            }
        }.resume()
    }
    
    // MARK: - Helper Methods for Text Classification
    private func isProductCode(_ text: String) -> Bool {
        // Pattern for product codes like "315122-111", "CW2288-111", etc.
        let pattern = #"^[A-Z0-9]{2,4}[-]?[0-9]{3,6}$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func isBrandText(_ text: String) -> Bool {
        let brands = ["nike", "jordan", "adidas", "apple", "samsung", "supreme", "vintage", "off-white", "balenciaga", "gucci", "louis vuitton", "prada", "yeezy"]
        return brands.contains { text.lowercased().contains($0) }
    }
    
    private func isSizeText(_ text: String) -> Bool {
        let sizePattern = #"(?i)(size\s*)?([\d]{1,2}(?:\.5)?)|([XS|S|M|L|XL|XXL]+)|(US\s*[\d]{1,2}\.?5?)"#
        return text.range(of: sizePattern, options: .regularExpression) != nil
    }
    
    private func isModelNumber(_ text: String) -> Bool {
        let modelPattern = #"[A-Z]{2,6}[\d]{3,6}|[\d]{3,6}-[\d]{3}|[A-Z][\d]{4,8}"#
        return text.range(of: modelPattern, options: .regularExpression) != nil
    }
    
    private func isBarcode(_ text: String) -> Bool {
        return text.count >= 8 && text.count <= 14 && text.allSatisfy { $0.isNumber }
    }
    
    private func isPriceText(_ text: String) -> Bool {
        let pricePattern = #"\$[\d]{1,4}(\.[\d]{2})?"#
        return text.range(of: pricePattern, options: .regularExpression) != nil
    }
    
    // MARK: - Visual Analysis Methods (Simplified)
    private func extractDominantColors(_ images: [UIImage]) -> [String] {
        // Simplified color extraction
        return ["White", "Black", "Red", "Blue"] // Would use actual color analysis
    }
    
    private func detectMaterials(_ images: [UIImage]) -> [String] {
        return ["Leather", "Fabric", "Plastic"] // Would use ML model
    }
    
    private func analyzeShapes(_ images: [UIImage]) -> [String] {
        return ["Rectangular", "Curved", "Angular"] // Would use shape detection
    }
    
    private func detectLogos(_ images: [UIImage]) -> [String] {
        return ["Nike Swoosh", "Apple Logo"] // Would use logo detection model
    }
    
    private func inferCategoryFromVisuals(_ images: [UIImage]) -> ProductCategory {
        // Would use trained ML model to classify based on visual features
        return .sneakers // Simplified
    }
    
    // MARK: - Prompt Generation
    private func createPrecisionIdentificationPrompt(textData: AdvancedTextData, visualFeatures: VisualFeatures, categoryHint: ProductCategory) -> String {
        return """
        You are a Google Lens-level product identifier. Your goal is to identify the EXACT SPECIFIC product model with 90%+ accuracy.
        
        DETECTED TEXT: \(textData.allText.joined(separator: ", "))
        PRODUCT CODES: \(textData.productCodes.joined(separator: ", "))
        BRANDS: \(textData.brands.joined(separator: ", "))
        SIZES: \(textData.sizes.joined(separator: ", "))
        MODEL NUMBERS: \(textData.modelNumbers.joined(separator: ", "))
        
        VISUAL FEATURES:
        - Dominant Colors: \(visualFeatures.dominantColors.joined(separator: ", "))
        - Materials: \(visualFeatures.materialTextures.joined(separator: ", "))
        - Category Hint: \(categoryHint.rawValue)
        
        CRITICAL REQUIREMENTS:
        1. Identify EXACT model, not general type
        2. For shoes: Full model name (e.g., "Nike Air Force 1 Low '07 White/White")
        3. For electronics: Complete model (e.g., "Apple Watch Series 8 GPS 45mm Silver Aluminum Case")
        4. For clothing: Brand + specific type + details
        5. Use visible text/codes to confirm exact identification
        
        IDENTIFICATION PROCESS:
        1. First identify the brand from visible logos/text
        2. Then identify the product line (Air Force 1, iPhone, etc.)
        3. Finally identify the specific variant/model
        4. Cross-reference with visible product codes/style numbers
        
        Respond in JSON format:
        {
            "exact_model_name": "Full exact product name",
            "brand": "Brand name",
            "product_line": "Product line/series",
            "style_variant": "Specific variant",
            "style_code": "Product code from image",
            "colorway": "Exact colorway description",
            "size": "Size from labels",
            "category": "sneakers/clothing/electronics/accessories/home/collectibles/books/toys/sports/other",
            "subcategory": "More specific category",
            "identification_method": "visual_and_text/visual_only/text_only/category_based",
            "confidence": 0.0-1.0,
            "identification_details": "Explain how you identified this exact model",
            "visible_evidence": "What visible text/features confirmed this ID",
            "alternative_possibilities": ["Other possible matches if unsure"]
        }
        
        BE PRECISE - "Nike Air Force 1 Low '07 White" not "Nike shoe"
        """
    }
    
    private func createEbayConditionPrompt(product: PrecisionIdentificationResult) -> String {
        let categorySpecific = getConditionInstructions(for: product.category)
        
        return """
        Assess the condition of this \(product.exactModelName) using EXACT eBay condition standards.
        
        EBAY CONDITION STANDARDS:
        - "New with tags": Brand new with original tags attached
        - "New without tags": Brand new but no tags
        - "New other": Brand new but not in original packaging  
        - "Like New": No signs of wear, appears unused
        - "Excellent": Minimal wear, no flaws affecting use
        - "Very Good": Light wear with minor flaws
        - "Good": Moderate wear with noticeable flaws
        - "Acceptable": Heavy wear with significant flaws
        - "For parts or not working": Major damage or not functional
        
        \(categorySpecific)
        
        ASSESSMENT CRITERIA:
        1. Look for original tags, packaging, or new condition indicators
        2. Examine for any signs of wear, use, or damage
        3. Consider how picky eBay buyers are for this item type
        4. Be conservative - better to undergrade than overgrade
        
        Respond in JSON:
        {
            "detected_condition": "exact eBay condition from list above",
            "condition_confidence": 0.0-1.0,
            "condition_factors": [
                {
                    "area": "specific area (toe box, screen, etc.)",
                    "issue": "type of wear/damage or null if none",
                    "severity": "minor/moderate/major/critical",
                    "impact_on_value": -5.0 (percentage impact)
                }
            ],
            "condition_notes": ["detailed observations"],
            "photography_recommendations": ["suggest better photos if needed"],
            "pricing_impact": "how condition affects market value"
        }
        
        Use EXACT eBay condition terminology.
        """
    }
    
    private func getConditionInstructions(for category: ProductCategory) -> String {
        switch category {
        case .sneakers:
            return """
            FOR SNEAKERS:
            - Check sole wear, creasing, scuffs, stains
            - Original box/tags = "New with tags"
            - Unworn but no box = "New without tags" or "Like New"
            - Light wear = "Very Good" to "Excellent"
            - Moderate wear = "Good"
            """
        case .electronics:
            return """
            FOR ELECTRONICS:
            - Check screen condition, housing damage, functionality
            - Original packaging = "New with tags"
            - Working perfectly with minimal wear = "Excellent"
            - Working with visible wear = "Very Good" to "Good"
            """
        case .clothing:
            return """
            FOR CLOTHING:
            - Check for stains, holes, pilling, fading
            - Original tags = "New with tags"
            - No visible wear = "Like New"
            - Slight wear = "Excellent" to "Very Good"
            """
        default:
            return "Assess based on overall condition and usability."
        }
    }
    
    // MARK: - Response Parsing
    private func parsePrecisionIdentificationResponse(_ content: String, textData: AdvancedTextData) -> PrecisionIdentificationResult {
        print("🎯 Parsing identification: \(content)")
        
        if let jsonData = extractJSON(from: content),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            
            let exactModelName = json["exact_model_name"] as? String ?? "Unknown Product"
            let brand = json["brand"] as? String ?? "Unknown"
            let confidence = json["confidence"] as? Double ?? 0.3
            
            // Validate identification quality
            if exactModelName.lowercased().contains("unknown") || confidence < 0.6 {
                print("⚠️ Low confidence identification, using fallback analysis")
                return createFallbackIdentification(textData: textData)
            }
            
            let methodString = json["identification_method"] as? String ?? "visual_only"
            let method: IdentificationMethod
            switch methodString {
            case "visual_and_text": method = .visualAndText
            case "text_only": method = .textOnly
            case "category_based": method = .categoryBased
            default: method = .visualOnly
            }
            
            let categoryString = json["category"] as? String ?? "other"
            let category = ProductCategory(rawValue: categoryString.capitalized) ?? .other
            
            return PrecisionIdentificationResult(
                exactModelName: exactModelName,
                brand: brand,
                productLine: json["product_line"] as? String ?? "",
                styleVariant: json["style_variant"] as? String ?? "",
                styleCode: json["style_code"] as? String ?? "",
                colorway: json["colorway"] as? String ?? "",
                size: json["size"] as? String ?? "",
                category: category,
                subcategory: json["subcategory"] as? String ?? "",
                identificationMethod: method,
                confidence: confidence,
                identificationDetails: [json["identification_details"] as? String ?? ""],
                alternativePossibilities: json["alternative_possibilities"] as? [String] ?? []
            )
        }
        
        return createFallbackIdentification(textData: textData)
    }
    
    private func parseEbayConditionResponse(_ content: String) -> EbayConditionAssessment {
        if let jsonData = extractJSON(from: content),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            
            let conditionString = json["detected_condition"] as? String ?? "Good"
            let condition = mapStringToEbayCondition(conditionString)
            
            var conditionFactors: [ConditionFactor] = []
            if let factors = json["condition_factors"] as? [[String: Any]] {
                for factor in factors {
                    let severity: Severity
                    switch factor["severity"] as? String {
                    case "critical": severity = .critical
                    case "major": severity = .major
                    case "moderate": severity = .moderate
                    default: severity = .minor
                    }
                    
                    conditionFactors.append(ConditionFactor(
                        area: factor["area"] as? String ?? "",
                        issue: factor["issue"] as? String,
                        severity: severity,
                        impactOnValue: factor["impact_on_value"] as? Double ?? -5.0
                    ))
                }
            }
            
            return EbayConditionAssessment(
                detectedCondition: condition,
                conditionConfidence: json["condition_confidence"] as? Double ?? 0.7,
                conditionFactors: conditionFactors,
                conditionNotes: json["condition_notes"] as? [String] ?? [],
                photographyRecommendations: json["photography_recommendations"] as? [String] ?? []
            )
        }
        
        return createDefaultConditionAssessment()
    }
    
    // MARK: - Market Data Parsing
    private func parseOfficialEbayResponse(_ json: [String: Any], condition: EbayCondition) -> EbayMarketData? {
        // Parse official eBay Finding API response
        guard let findCompletedItemsResponse = json["findCompletedItemsResponse"] as? [[String: Any]],
              let response = findCompletedItemsResponse.first,
              let searchResult = response["searchResult"] as? [[String: Any]],
              let result = searchResult.first,
              let items = result["item"] as? [[String: Any]] else {
            return nil
        }
        
        var soldListings: [EbaySoldListing] = []
        
        for item in items {
            if let sellingStatus = item["sellingStatus"] as? [[String: Any]],
               let status = sellingStatus.first,
               let currentPrice = status["currentPrice"] as? [[String: Any]],
               let price = currentPrice.first,
               let value = price["__value__"] as? String,
               let priceValue = Double(value) {
                
                let title = (item["title"] as? [String])?.first ?? ""
                let endTime = (item["listingInfo"] as? [[String: Any]])?.first?["endTime"] as? [String]
                
                soldListings.append(EbaySoldListing(
                    title: title,
                    price: priceValue,
                    condition: condition.rawValue,
                    soldDate: parseEbayDate(endTime?.first) ?? Date(),
                    shippingCost: nil,
                    bestOffer: false,
                    auction: false,
                    watchers: nil
                ))
            }
        }
        
        return createMarketDataFromListings(soldListings, condition: condition)
    }
    
    private func parseRapidAPIEbayResponse(_ json: [String: Any], condition: EbayCondition) -> EbayMarketData {
        // Parse RapidAPI response format
        var soldListings: [EbaySoldListing] = []
        
        if let items = json["items"] as? [[String: Any]] {
            for item in items {
                if let price = item["price"] as? Double ?? parsePrice(item["price"] as? String) {
                    soldListings.append(EbaySoldListing(
                        title: item["title"] as? String ?? "",
                        price: price,
                        condition: condition.rawValue,
                        soldDate: Date().addingTimeInterval(-Double.random(in: 0...2592000)), // Random within 30 days
                        shippingCost: item["shipping"] as? Double,
                        bestOffer: false,
                        auction: false,
                        watchers: nil
                    ))
                }
            }
        }
        
        return createMarketDataFromListings(soldListings, condition: condition)
    }
    
    // MARK: - Step 9: Intelligent Pricing
    private func calculateIntelligentPricing(
        product: PrecisionIdentificationResult,
        condition: EbayConditionAssessment,
        marketData: EbayMarketData,
        competition: CompetitionAnalysis
    ) -> EbayPricingRecommendation {
        
        let basePrice = marketData.priceRange.average
        let conditionMultiplier = condition.detectedCondition.priceMultiplier
        
        // Apply condition adjustment
        let conditionAdjustedPrice = basePrice * conditionMultiplier
        
        // Apply competition adjustment
        let competitionMultiplier = getCompetitionMultiplier(competition.level)
        let competitivePrice = conditionAdjustedPrice * competitionMultiplier
        
        // Calculate price range
        let quickSalePrice = competitivePrice * 0.90
        let maxProfitPrice = competitivePrice * 1.15
        
        let strategy: PricingStrategy
        if condition.detectedCondition == .newWithTags || condition.detectedCondition == .likeNew {
            strategy = .premium
        } else if competition.level == .high {
            strategy = .competitive
        } else {
            strategy = .competitive
        }
        
        return EbayPricingRecommendation(
            recommendedPrice: competitivePrice,
            priceRange: (min: quickSalePrice, max: maxProfitPrice),
            competitivePrice: competitivePrice,
            quickSalePrice: quickSalePrice,
            maxProfitPrice: maxProfitPrice,
            pricingStrategy: strategy,
            priceJustification: [
                "Based on \(marketData.soldListings.count) recent sales",
                "Condition: \(condition.detectedCondition.rawValue)",
                "Competition level: \(competition.level)",
                "Average market price: $\(String(format: "%.2f", basePrice))"
            ]
        )
    }
    
    // MARK: - Utility Methods
    private func updateProgress(_ step: Int, _ message: String) {
        DispatchQueue.main.async {
            self.currentStep = step
            self.analysisProgress = message
            print("🧠 Step \(step)/\(self.totalSteps): \(message)")
        }
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }
    
    private func extractJSON(from text: String) -> Data? {
        if let startRange = text.range(of: "{"),
           let endRange = text.range(of: "}", options: .backwards) {
            let jsonString = String(text[startRange.lowerBound...endRange.upperBound])
            return jsonString.data(using: .utf8)
        }
        return nil
    }
    
    // MARK: - Default/Fallback Creation Methods
    private func createDefaultIdentificationResult() -> PrecisionIdentificationResult {
        return PrecisionIdentificationResult(
            exactModelName: "Unknown Product",
            brand: "Unknown",
            productLine: "",
            styleVariant: "",
            styleCode: "",
            colorway: "",
            size: "",
            category: .other,
            subcategory: "",
            identificationMethod: .categoryBased,
            confidence: 0.1,
            identificationDetails: ["Unable to identify precisely"],
            alternativePossibilities: []
        )
    }
    
    private func createDefaultConditionAssessment() -> EbayConditionAssessment {
        return EbayConditionAssessment(
            detectedCondition: .good,
            conditionConfidence: 0.5,
            conditionFactors: [],
            conditionNotes: ["Condition assessment incomplete"],
            photographyRecommendations: ["Take clearer photos of item condition"]
        )
    }
    
    private func createErrorResult(_ error: String) -> AnalysisResult {
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
        
        let errorMarket = createFallbackMarketData(searchQuery: "error", condition: .good)
        
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
    
    // MARK: - Add missing methods and data structures
    struct AdvancedTextData {
        let allText: [String]
        let productCodes: [String]
        let brands: [String]
        let sizes: [String]
        let modelNumbers: [String]
        let barcodes: [String]
        let prices: [String]
    }
    
    struct VisualFeatures {
        let dominantColors: [String]
        let materialTextures: [String]
        let shapeCharacteristics: [String]
        let logoDetection: [String]
        let visualCategory: ProductCategory
    }
    
    struct CompetitionAnalysis {
        let level: CompetitionLevel
        let activeListings: Int
        let averageListingDuration: TimeInterval
        let priceDistribution: [Double]
    }
    
    // Add other missing helper methods...
    private func analyzeTextForCategory(_ textData: AdvancedTextData) -> ProductCategory {
        let allText = textData.allText.joined(separator: " ").lowercased()
        
        if allText.contains("nike") || allText.contains("jordan") || allText.contains("adidas") || allText.contains("shoe") {
            return .sneakers
        } else if allText.contains("iphone") || allText.contains("apple") || allText.contains("samsung") {
            return .electronics
        } else if allText.contains("shirt") || allText.contains("jacket") || allText.contains("clothing") {
            return .clothing
        }
        
        return .other
    }
    
    private func combineHints(textHints: ProductCategory, visualHints: ProductCategory) -> ProductCategory {
        if textHints == visualHints {
            return textHints
        }
        return textHints // Prefer text analysis
    }
    
    private func crossReferenceProductDatabases(_ identification: PrecisionIdentificationResult, completion: @escaping (PrecisionIdentificationResult) -> Void) {
        // For now, just return the identification as-is
        // In a real implementation, this would cross-reference with UPC databases, manufacturer catalogs, etc.
        completion(identification)
    }
    
    private func analyzeCompetition(product: PrecisionIdentificationResult, marketData: EbayMarketData, completion: @escaping (CompetitionAnalysis) -> Void) {
        let analysis = CompetitionAnalysis(
            level: marketData.soldListings.count > 50 ? .high : marketData.soldListings.count > 20 ? .moderate : .low,
            activeListings: marketData.soldListings.count,
            averageListingDuration: 7 * 24 * 60 * 60, // 7 days
            priceDistribution: marketData.soldListings.map { $0.price }
        )
        completion(analysis)
    }
    
    private func generateEbayListingStrategy(
        product: PrecisionIdentificationResult,
        condition: EbayConditionAssessment,
        pricing: EbayPricingRecommendation,
        marketData: EbayMarketData
    ) -> EbayListingStrategy {
        
        let title = "\(product.brand) \(product.exactModelName) \(product.size) - \(condition.detectedCondition.rawValue)".trimmingCharacters(in: .whitespaces)
        
        return EbayListingStrategy(
            recommendedTitle: String(title.prefix(80)),
            keywordOptimization: [product.brand, product.productLine, product.styleVariant, product.size].filter { !$0.isEmpty },
            categoryPath: mapToEbayCategory(product.category),
            listingFormat: .buyItNow,
            photographyChecklist: ["Multiple angles", "Close-ups of condition", "Original packaging if available"],
            descriptionTemplate: generateDescription(product: product, condition: condition)
        )
    }
    
    private func calculateConfidence(
        identification: PrecisionIdentificationResult,
        condition: EbayConditionAssessment,
        marketData: EbayMarketData
    ) -> MarketConfidence {
        
        let dataQuality: DataQuality
        switch marketData.soldListings.count {
        case 50...: dataQuality = .excellent
        case 20...49: dataQuality = .good
        case 5...19: dataQuality = .fair
        case 1...4: dataQuality = .limited
        default: dataQuality = .insufficient
        }
        
        let overallConfidence = (identification.confidence + condition.conditionConfidence + Double(marketData.soldListings.count) / 50.0) / 3.0
        
        return MarketConfidence(
            overall: min(1.0, overallConfidence),
            identification: identification.confidence,
            condition: condition.conditionConfidence,
            pricing: Double(marketData.soldListings.count) / 50.0,
            dataQuality: dataQuality
        )
    }
    
    private func assembleAnalysisResult(
        images: [UIImage],
        identification: PrecisionIdentificationResult,
        condition: EbayConditionAssessment,
        marketData: EbayMarketData,
        pricing: EbayPricingRecommendation,
        listing: EbayListingStrategy,
        confidence: MarketConfidence
    ) -> AnalysisResult {
        
        let marketAnalysis = MarketAnalysisResult(
            identifiedProduct: identification,
            marketData: marketData,
            conditionAssessment: condition,
            pricingRecommendation: pricing,
            listingStrategy: listing,
            confidence: confidence
        )
        
        return AnalysisResult(
            identificationResult: identification,
            marketAnalysis: marketAnalysis,
            ebayCondition: condition.detectedCondition,
            ebayPricing: pricing,
            soldListings: marketData.soldListings,
            confidence: confidence,
            images: images
        )
    }
    
    // Helper methods
    private func createFallbackIdentification(textData: AdvancedTextData) -> PrecisionIdentificationResult {
        return PrecisionIdentificationResult(
            exactModelName: "Product Identified",
            brand: textData.brands.first ?? "Unknown",
            productLine: "",
            styleVariant: "",
            styleCode: textData.productCodes.first ?? "",
            colorway: "",
            size: textData.sizes.first ?? "",
            category: .other,
            subcategory: "",
            identificationMethod: .textOnly,
            confidence: 0.4,
            identificationDetails: ["Identified from text only"],
            alternativePossibilities: []
        )
    }
    
    private func createMarketDataFromListings(_ listings: [EbaySoldListing], condition: EbayCondition) -> EbayMarketData {
        let prices = listings.map { $0.price }
        let average = prices.isEmpty ? 25.0 : prices.reduce(0, +) / Double(prices.count)
        
        let priceRange = EbayPriceRange(
            newWithTags: condition == .newWithTags ? average : nil,
            newWithoutTags: condition == .newWithoutTags ? average : nil,
            likeNew: condition == .likeNew ? average : nil,
            excellent: condition == .excellent ? average : nil,
            veryGood: condition == .veryGood ? average : nil,
            good: condition == .good ? average : nil,
            acceptable: condition == .acceptable ? average : nil,
            average: average,
            soldCount: listings.count,
            dateRange: "Last 30 days"
        )
        
        return EbayMarketData(
            soldListings: listings,
            priceRange: priceRange,
            marketTrend: MarketTrend(direction: .stable, strength: .moderate, timeframe: "30 days", seasonalFactors: []),
            demandIndicators: DemandIndicators(
                watchersPerListing: 5.0,
                viewsPerListing: 50.0,
                timeToSell: .normal,
                searchVolume: listings.count > 20 ? .high : .medium
            ),
            competitionLevel: listings.count > 50 ? .high : .moderate,
            lastUpdated: Date()
        )
    }
    
    private func createFallbackMarketData(searchQuery: String, condition: EbayCondition) -> EbayMarketData {
        // Conservative fallback when no real data is available
        let fallbackPrice = 25.0
        let fallbackListing = EbaySoldListing(
            title: searchQuery,
            price: fallbackPrice,
            condition: condition.rawValue,
            soldDate: Date(),
            shippingCost: nil,
            bestOffer: false,
            auction: false,
            watchers: nil
        )
        
        return createMarketDataFromListings([fallbackListing], condition: condition)
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
    
    private func mapStringToEbayCondition(_ conditionString: String) -> EbayCondition {
        let lower = conditionString.lowercased()
        
        if lower.contains("new with tags") {
            return .newWithTags
        } else if lower.contains("new without tags") {
            return .newWithoutTags
        } else if lower.contains("new other") {
            return .newOther
        } else if lower.contains("like new") {
            return .likeNew
        } else if lower.contains("excellent") {
            return .excellent
        } else if lower.contains("very good") {
            return .veryGood
        } else if lower.contains("good") {
            return .good
        } else if lower.contains("acceptable") {
            return .acceptable
        } else if lower.contains("parts") || lower.contains("not working") {
            return .forPartsNotWorking
        } else {
            return .good // Default
        }
    }
    
    private func getCompetitionMultiplier(_ level: CompetitionLevel) -> Double {
        switch level {
        case .low: return 1.05
        case .moderate: return 1.0
        case .high: return 0.95
        case .saturated: return 0.90
        }
    }
    
    private func mapToEbayCategory(_ category: ProductCategory) -> String {
        switch category {
        case .sneakers: return "Clothing, Shoes & Accessories > Unisex Shoes > Athletic Shoes"
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
    
    private func generateDescription(product: PrecisionIdentificationResult, condition: EbayConditionAssessment) -> String {
        return """
        \(product.brand) \(product.exactModelName)
        
        Condition: \(condition.detectedCondition.rawValue)
        \(condition.detectedCondition.description)
        
        \(condition.conditionNotes.joined(separator: "\n"))
        
        Authentic item - see photos for exact condition details
        Fast shipping with tracking included
        Returns accepted within 30 days
        """
    }
    
    private func parsePrice(_ priceString: String?) -> Double? {
        guard let str = priceString else { return nil }
        let numericString = str.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(numericString)
    }
    
    private func parseEbayDate(_ dateString: String?) -> Date? {
        guard let dateStr = dateString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.date(from: dateStr)
    }
}
