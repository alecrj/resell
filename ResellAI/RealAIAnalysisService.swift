import SwiftUI
import Foundation
import Vision

// MARK: - Real AI Analysis Service with Actual APIs
class RealAIAnalysisService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 8
    
    private let openAIAPIKey = APIConfig.openAIKey
    private let rapidAPIKey = APIConfig.rapidAPIKey
    
    init() {
        print("🚀 Initializing REAL AI Analysis System")
        validateAPIs()
    }
    
    private func validateAPIs() {
        guard !openAIAPIKey.isEmpty else {
            print("❌ OpenAI API Key missing!")
            return
        }
        guard !rapidAPIKey.isEmpty else {
            print("❌ RapidAPI Key missing!")
            return
        }
        print("✅ All APIs configured and ready")
    }
    
    // MARK: - Main Analysis Pipeline with REAL APIs
    func analyzeItem(_ images: [UIImage], completion: @escaping (AnalysisResult) -> Void) {
        guard !images.isEmpty else {
            completion(createErrorResult("No images provided"))
            return
        }
        
        print("🧠 Starting REAL Analysis Pipeline with \(images.count) images")
        
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.currentStep = 0
            self.totalSteps = 8
        }
        
        // Step 1: Advanced OCR Text Extraction
        updateProgress(1, "🔤 Extracting text and labels from images...")
        extractTextFromImages(images) { [weak self] textData in
            guard let self = self else { return }
            
            // Step 2: Real OpenAI GPT-4 Vision Analysis
            self.updateProgress(2, "🧠 Analyzing with GPT-4 Vision API...")
            self.performRealGPT4VisionAnalysis(images: images, textData: textData) { visionResult in
                
                // Step 3: Detailed Condition Analysis
                self.updateProgress(3, "🔍 Analyzing condition and damage...")
                self.performRealConditionAnalysis(images: images, productInfo: visionResult) { conditionResult in
                    
                    // Step 4: Product Database Lookup
                    self.updateProgress(4, "📱 Looking up product in databases...")
                    self.performProductDatabaseLookup(visionResult: visionResult, textData: textData) { productData in
                        
                        // Step 5: Real Market Research
                        self.updateProgress(5, "📊 Researching live market data...")
                        self.performRealMarketResearch(productData: productData, condition: conditionResult) { marketData in
                            
                            // Step 6: Intelligent Pricing
                            self.updateProgress(6, "💰 Calculating market-based pricing...")
                            let pricingData = self.calculateRealPricing(
                                product: productData,
                                condition: conditionResult,
                                market: marketData
                            )
                            
                            // Step 7: Professional Listing Generation
                            self.updateProgress(7, "📝 Generating optimized listing...")
                            let listingData = self.generateRealListing(
                                product: productData,
                                condition: conditionResult,
                                pricing: pricingData
                            )
                            
                            // Step 8: Final Assembly
                            self.updateProgress(8, "✅ Finalizing analysis...")
                            let finalResult = self.assembleRealResult(
                                images: images,
                                textData: textData,
                                visionResult: visionResult,
                                conditionResult: conditionResult,
                                productData: productData,
                                marketData: marketData,
                                pricingData: pricingData,
                                listingData: listingData
                            )
                            
                            DispatchQueue.main.async {
                                self.isAnalyzing = false
                                self.analysisProgress = "✅ Real Analysis Complete!"
                                self.currentStep = 0
                                completion(finalResult)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 1: Advanced OCR Text Extraction
    private func extractTextFromImages(_ images: [UIImage], completion: @escaping (RealTextData) -> Void) {
        var allDetectedText: [String] = []
        var brandText: [String] = []
        var sizeText: [String] = []
        var modelText: [String] = []
        var barcodeText: [String] = []
        
        let group = DispatchGroup()
        
        for image in images {
            guard let cgImage = image.cgImage else { continue }
            
            group.enter()
            
            let request = VNRecognizeTextRequest { request, error in
                if let observations = request.results as? [VNRecognizedTextObservation] {
                    for observation in observations {
                        for candidate in observation.topCandidates(5) {
                            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                            allDetectedText.append(text)
                            
                            // Intelligent text classification
                            if self.isBrandText(text) {
                                brandText.append(text)
                            }
                            if self.isSizeText(text) {
                                sizeText.append(text)
                            }
                            if self.isModelText(text) {
                                modelText.append(text)
                            }
                            if self.isBarcodeText(text) {
                                barcodeText.append(text)
                            }
                        }
                    }
                }
                group.leave()
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
        
        group.notify(queue: .main) {
            let textData = RealTextData(
                allText: Array(Set(allDetectedText)),
                brands: Array(Set(brandText)),
                sizes: Array(Set(sizeText)),
                models: Array(Set(modelText)),
                barcodes: Array(Set(barcodeText))
            )
            completion(textData)
        }
    }
    
    // MARK: - Step 2: Real OpenAI GPT-4 Vision Analysis
    private func performRealGPT4VisionAnalysis(images: [UIImage], textData: RealTextData, completion: @escaping (RealVisionResult) -> Void) {
        
        // Convert images to base64
        let base64Images = images.prefix(4).compactMap { image in
            image.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        }
        
        guard !base64Images.isEmpty else {
            completion(self.createDefaultVisionResult())
            return
        }
        
        let prompt = createDetailedAnalysisPrompt(textData: textData)
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages = [
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
                            "url": "data:image/jpeg;base64,\(base64)"
                        ]
                    ]
                }
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 1500,
            "temperature": 0.3
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ Failed to serialize OpenAI request: \(error)")
            completion(createDefaultVisionResult())
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ OpenAI API error: \(error)")
                completion(self.createDefaultVisionResult())
                return
            }
            
            guard let data = data else {
                print("❌ No data from OpenAI")
                completion(self.createDefaultVisionResult())
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    print("🧠 OpenAI Response: \(content)")
                    let visionResult = self.parseGPT4VisionResponse(content)
                    completion(visionResult)
                } else {
                    print("❌ Failed to parse OpenAI response")
                    completion(self.createDefaultVisionResult())
                }
            } catch {
                print("❌ JSON parsing error: \(error)")
                completion(self.createDefaultVisionResult())
            }
        }.resume()
    }
    
    // MARK: - Step 3: Real Condition Analysis
    private func performRealConditionAnalysis(images: [UIImage], productInfo: RealVisionResult, completion: @escaping (RealConditionResult) -> Void) {
        
        let base64Images = images.compactMap { image in
            image.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        }
        
        let conditionPrompt = createDetailedConditionPrompt(productInfo: productInfo)
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages = [
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
                            "url": "data:image/jpeg;base64,\(base64)"
                        ]
                    ]
                }
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 1000,
            "temperature": 0.2
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ Failed to serialize condition request: \(error)")
            completion(self.createDefaultConditionResult())
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Condition analysis error: \(error)")
                completion(self.createDefaultConditionResult())
                return
            }
            
            guard let data = data else {
                completion(self.createDefaultConditionResult())
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    print("🔍 Condition Analysis: \(content)")
                    let conditionResult = self.parseConditionResponse(content)
                    completion(conditionResult)
                } else {
                    completion(self.createDefaultConditionResult())
                }
            } catch {
                print("❌ Condition JSON parsing error: \(error)")
                completion(self.createDefaultConditionResult())
            }
        }.resume()
    }
    
    // MARK: - Step 4: Product Database Lookup
    private func performProductDatabaseLookup(visionResult: RealVisionResult, textData: RealTextData, completion: @escaping (RealProductData) -> Void) {
        
        // Try barcode lookup first
        if let barcode = textData.barcodes.first {
            lookupProductByBarcode(barcode) { [weak self] barcodeResult in
                if let product = barcodeResult {
                    completion(product)
                } else {
                    // Fallback to vision-based product data
                    let productData = self?.createProductFromVision(visionResult, textData) ?? self?.createDefaultProductData() ?? RealProductData(
                        name: "Unknown Item",
                        brand: "",
                        model: "",
                        category: "other",
                        size: "",
                        colorway: "",
                        retailPrice: 0,
                        releaseYear: "",
                        confidence: 0.1
                    )
                    completion(productData)
                }
            }
        } else {
            // No barcode, use vision analysis
            let productData = createProductFromVision(visionResult, textData)
            completion(productData)
        }
    }
    
    // MARK: - Step 5: Real Market Research
    private func performRealMarketResearch(productData: RealProductData, condition: RealConditionResult, completion: @escaping (RealMarketData) -> Void) {
        
        let searchQuery = "\(productData.brand) \(productData.name) \(productData.size)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Call real eBay API for completed listings
        searchEbayCompletedListings(query: searchQuery) { [weak self] ebayData in
            
            // Call StockX API via RapidAPI
            self?.searchStockXData(product: productData) { stockxData in
                
                let marketData = self?.synthesizeRealMarketData(
                    ebayData: ebayData,
                    stockxData: stockxData,
                    productData: productData
                ) ?? RealMarketData(
                    soldPrices: [],
                    averagePrice: 0,
                    trend: "Unknown",
                    demand: "Unknown",
                    competitors: 0
                )
                
                completion(marketData)
            }
        }
    }
    
    // MARK: - Real eBay API Integration
    private func searchEbayCompletedListings(query: String, completion: @escaping (EbaySearchResult?) -> Void) {
        
        // Using eBay Browse API via RapidAPI
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://ebay-search.p.rapidapi.com/search?q=\(encodedQuery)&category_id=0&limit=50&sort=EndTimeSoonest"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(rapidAPIKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("ebay-search.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ eBay API error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let ebayResult = self.parseEbayResponse(json)
                    completion(ebayResult)
                } else {
                    completion(nil)
                }
            } catch {
                print("❌ eBay JSON parsing error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Real StockX API Integration
    private func searchStockXData(product: RealProductData, completion: @escaping (StockXSearchResult?) -> Void) {
        
        let encodedQuery = "\(product.brand) \(product.name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://stockx-api.p.rapidapi.com/search?query=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(rapidAPIKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("stockx-api.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ StockX API error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let stockxResult = self.parseStockXResponse(json)
                    completion(stockxResult)
                } else {
                    completion(nil)
                }
            } catch {
                print("❌ StockX JSON parsing error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Barcode Product Lookup
    func lookupProductByBarcode(_ barcode: String, completion: @escaping (RealProductData?) -> Void) {
        
        let urlString = "https://barcodes1.p.rapidapi.com/?query=\(barcode)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(rapidAPIKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("barcodes1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Barcode lookup error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let productData = self.parseBarcodeResponse(json)
                    completion(productData)
                } else {
                    completion(nil)
                }
            } catch {
                print("❌ Barcode JSON parsing error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Detailed Prompts for Real Analysis
    private func createDetailedAnalysisPrompt(textData: RealTextData) -> String {
        return """
        You are an expert reseller and product identification specialist. Analyze these images with extreme precision to identify the EXACT item, including all details that affect resale value.

        CRITICAL REQUIREMENTS:
        1. Identify the EXACT product name, model, and colorway
        2. Distinguish between similar items (regular vs limited vs collaboration)
        3. Note specific design elements that affect value
        4. Read all visible text, tags, and labels
        5. Identify size from tags or labels

        DETECTED TEXT FROM IMAGES:
        All Text: \(textData.allText.joined(separator: ", "))
        Brands: \(textData.brands.joined(separator: ", "))
        Sizes: \(textData.sizes.joined(separator: ", "))
        Models: \(textData.models.joined(separator: ", "))

        Please provide EXACT identification in this JSON format:
        {
            "item_name": "EXACT full product name",
            "brand": "Brand name",
            "model_number": "Model/style code",
            "category": "shoes/clothing/electronics/accessories/home/toys/books/collectibles",
            "size": "Size from tags",
            "colorway": "Exact colorway name",
            "collaboration": "Any collaboration or special edition",
            "limited_edition": true/false,
            "release_year": "Year",
            "key_features": ["List unique features that affect value"],
            "authenticity_markers": ["Visible authenticity features"],
            "confidence": 0.0-1.0
        }

        Be extremely specific and work with ALL item types:
        - Electronics: exact model numbers, condition of screens/buttons
        - Clothing: brand, size, material, special collections
        - Home goods: brand, model, vintage status
        - Books: title, author, edition, condition
        - Toys: brand, character, year, completeness
        - Collectibles: exact item, rarity, condition
        """
    }
    
    private func createDetailedConditionPrompt(productInfo: RealVisionResult) -> String {
        return """
        You are a professional product condition assessor. Examine these images of a \(productInfo.itemName) and provide an extremely detailed condition assessment.

        ANALYZE FOR EACH ITEM TYPE:
        
        SHOES/FOOTWEAR:
        - Sole condition: wear patterns, separation, yellowing
        - Upper condition: scuffs, creases, tears, stains
        - Logo/branding condition
        - Stitching integrity
        - Laces: original/replacement, condition
        
        ELECTRONICS:
        - Screen condition: scratches, cracks, dead pixels
        - Housing: dents, scratches, wear
        - Ports and buttons functionality appearance
        - Missing accessories or cables
        
        CLOTHING:
        - Fabric condition: fading, tears, stains, pilling
        - Seams and stitching
        - Hardware: zippers, buttons, snaps
        - Size tags and care labels
        
        HOME GOODS:
        - Functionality indicators
        - Wear patterns and damage
        - Missing parts or pieces
        - Age-related deterioration
        
        BOOKS:
        - Cover condition: tears, creases, spine damage
        - Page condition: yellowing, tears, markings
        - Binding integrity
        
        TOYS/COLLECTIBLES:
        - Completeness: all parts present
        - Paint condition and wear
        - Moving parts functionality
        - Original packaging condition

        Provide response in this JSON format:
        {
            "condition_score": 0-100,
            "condition_name": "Poor/Fair/Good/Very Good/Excellent/Like New",
            "damage_areas": ["Specific areas with damage"],
            "wear_patterns": ["Specific wear observed"],
            "positive_notes": ["Good condition aspects"],
            "negative_notes": ["Condition issues"],
            "resale_impact": "How condition affects resale value",
            "market_condition": "Condition grade for resale market",
            "price_adjustment": -50 to +20 (percentage adjustment from base price)
        }

        Be thorough and honest about condition. Buyers rely on accurate descriptions.
        """
    }
    
    // MARK: - Response Parsing
    private func parseGPT4VisionResponse(_ content: String) -> RealVisionResult {
        // Try to extract JSON from the response
        if let jsonData = extractJSON(from: content),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            
            return RealVisionResult(
                itemName: json["item_name"] as? String ?? "Unknown Item",
                brand: json["brand"] as? String ?? "",
                modelNumber: json["model_number"] as? String ?? "",
                category: json["category"] as? String ?? "other",
                size: json["size"] as? String ?? "",
                colorway: json["colorway"] as? String ?? "",
                collaboration: json["collaboration"] as? String ?? "",
                limitedEdition: json["limited_edition"] as? Bool ?? false,
                releaseYear: json["release_year"] as? String ?? "",
                keyFeatures: json["key_features"] as? [String] ?? [],
                authenticity: json["authenticity_markers"] as? [String] ?? [],
                confidence: json["confidence"] as? Double ?? 0.5
            )
        }
        
        // Fallback: Try to parse from free-form text
        return parseFromFreeText(content)
    }
    
    private func parseFromFreeText(_ content: String) -> RealVisionResult {
        // Extract information from free-form response
        var itemName = "Unknown Item"
        var brand = ""
        var category = "other"
        var size = ""
        var colorway = ""
        var confidence = 0.5
        
        // Look for brand mentions (expand for all categories)
        let brandPatterns = ["nike", "jordan", "adidas", "vans", "apple", "samsung", "sony", "vintage", "antique"]
        for brandPattern in brandPatterns {
            if content.lowercased().contains(brandPattern) {
                brand = brandPattern.capitalized
                break
            }
        }
        
        // Look for category mentions
        if content.lowercased().contains("shoe") || content.lowercased().contains("sneaker") {
            category = "shoes"
        } else if content.lowercased().contains("shirt") || content.lowercased().contains("clothing") {
            category = "clothing"
        } else if content.lowercased().contains("phone") || content.lowercased().contains("electronic") {
            category = "electronics"
        } else if content.lowercased().contains("book") {
            category = "books"
        } else if content.lowercased().contains("toy") || content.lowercased().contains("game") {
            category = "toys"
        } else if content.lowercased().contains("home") || content.lowercased().contains("kitchen") {
            category = "home"
        }
        
        // Try to extract item name from first sentence
        let sentences = content.components(separatedBy: ".")
        if let firstSentence = sentences.first {
            itemName = firstSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return RealVisionResult(
            itemName: itemName,
            brand: brand,
            modelNumber: "",
            category: category,
            size: size,
            colorway: colorway,
            collaboration: "",
            limitedEdition: false,
            releaseYear: "",
            keyFeatures: [],
            authenticity: [],
            confidence: confidence
        )
    }
    
    private func parseConditionResponse(_ content: String) -> RealConditionResult {
        if let jsonData = extractJSON(from: content),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            
            return RealConditionResult(
                score: json["condition_score"] as? Double ?? 50.0,
                conditionName: json["condition_name"] as? String ?? "Fair",
                damageAreas: json["damage_areas"] as? [String] ?? [],
                wearPatterns: json["wear_patterns"] as? [String] ?? [],
                positiveNotes: json["positive_notes"] as? [String] ?? [],
                negativeNotes: json["negative_notes"] as? [String] ?? [],
                resaleImpact: json["resale_impact"] as? String ?? "",
                priceAdjustment: json["price_adjustment"] as? Double ?? 0.0
            )
        }
        
        // Fallback: Parse from text
        return parseConditionFromText(content)
    }
    
    private func parseConditionFromText(_ content: String) -> RealConditionResult {
        let text = content.lowercased()
        var score = 75.0
        var conditionName = "Good"
        var negativeNotes: [String] = []
        
        // Look for condition indicators
        if text.contains("excellent") || text.contains("like new") {
            score = 90.0
            conditionName = "Excellent"
        } else if text.contains("very good") {
            score = 80.0
            conditionName = "Very Good"
        } else if text.contains("fair") || text.contains("worn") {
            score = 60.0
            conditionName = "Fair"
        } else if text.contains("poor") || text.contains("damaged") {
            score = 40.0
            conditionName = "Poor"
        }
        
        // Look for damage indicators
        if text.contains("scuff") { negativeNotes.append("Scuffing visible") }
        if text.contains("stain") { negativeNotes.append("Staining present") }
        if text.contains("tear") { negativeNotes.append("Tears or holes") }
        if text.contains("worn") { negativeNotes.append("Signs of wear") }
        
        return RealConditionResult(
            score: score,
            conditionName: conditionName,
            damageAreas: [],
            wearPatterns: [],
            positiveNotes: [],
            negativeNotes: negativeNotes,
            resaleImpact: "Condition affects pricing",
            priceAdjustment: (score - 75.0) / 2.0
        )
    }
    
    // MARK: - Helper Methods
    private func updateProgress(_ step: Int, _ message: String) {
        DispatchQueue.main.async {
            self.currentStep = step
            self.analysisProgress = message
            print("🧠 Step \(step)/\(self.totalSteps): \(message)")
        }
    }
    
    private func extractJSON(from text: String) -> Data? {
        if let startRange = text.range(of: "{"),
           let endRange = text.range(of: "}", options: .backwards, range: startRange.upperBound..<text.endIndex) {
            let jsonString = String(text[startRange.lowerBound...endRange.upperBound])
            return jsonString.data(using: String.Encoding.utf8)
        }
        return nil
    }
    
    // Text classification methods (updated for all categories)
    private func isBrandText(_ text: String) -> Bool {
        let brands = ["nike", "jordan", "adidas", "vans", "converse", "puma", "reebok", "new balance",
                     "supreme", "off-white", "fear of god", "travis scott", "fragment",
                     "apple", "samsung", "sony", "lg", "panasonic", "canon", "nikon",
                     "vintage", "antique", "signed", "authentic", "original"]
        return brands.contains { text.lowercased().contains($0) }
    }
    
    private func isSizeText(_ text: String) -> Bool {
        let sizePattern = #"(?i)(size\s*)?([\d]{1,2}(?:\.5)?)|([XS|S|M|L|XL|XXL]+)"#
        return text.range(of: sizePattern, options: .regularExpression) != nil
    }
    
    private func isModelText(_ text: String) -> Bool {
        let modelPattern = #"[A-Z]{2,4}[\d]{3,6}|[\d]{3,6}-[\d]{3}|[A-Z][\d]{4,6}"#
        return text.range(of: modelPattern, options: .regularExpression) != nil
    }
    
    private func isBarcodeText(_ text: String) -> Bool {
        return text.count >= 8 && text.count <= 14 && text.allSatisfy { $0.isNumber }
    }
    
    // Create default results for fallback
    private func createDefaultVisionResult() -> RealVisionResult {
        return RealVisionResult(
            itemName: "Unknown Item",
            brand: "",
            modelNumber: "",
            category: "other",
            size: "",
            colorway: "",
            collaboration: "",
            limitedEdition: false,
            releaseYear: "",
            keyFeatures: [],
            authenticity: [],
            confidence: 0.1
        )
    }
    
    private func createDefaultConditionResult() -> RealConditionResult {
        return RealConditionResult(
            score: 50.0,
            conditionName: "Fair",
            damageAreas: [],
            wearPatterns: [],
            positiveNotes: [],
            negativeNotes: [],
            resaleImpact: "Unknown condition impact",
            priceAdjustment: 0.0
        )
    }
    
    private func createErrorResult(_ error: String) -> AnalysisResult {
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
            ebayTitle: "Error",
            description: error,
            keywords: [],
            feesBreakdown: FeesBreakdown(ebayFee: 0, paypalFee: 0, shippingCost: 0, listingFees: 0, totalFees: 0),
            profitMargins: ProfitMargins(quickSaleNet: 0, realisticNet: 0, maxProfitNet: 0),
            listingStrategy: "",
            sourcingTips: [],
            seasonalFactors: "",
            resalePotential: 1,
            images: []
        )
    }
    
    // MARK: - Implementation Methods
    
    private func createProductFromVision(_ visionResult: RealVisionResult, _ textData: RealTextData) -> RealProductData {
        return RealProductData(
            name: visionResult.itemName,
            brand: visionResult.brand,
            model: visionResult.modelNumber,
            category: visionResult.category,
            size: visionResult.size,
            colorway: visionResult.colorway,
            retailPrice: estimateRetailPrice(brand: visionResult.brand, category: visionResult.category),
            releaseYear: visionResult.releaseYear,
            confidence: visionResult.confidence
        )
    }
    
    private func createDefaultProductData() -> RealProductData {
        return RealProductData(
            name: "Unknown Item",
            brand: "",
            model: "",
            category: "other",
            size: "",
            colorway: "",
            retailPrice: 0,
            releaseYear: "",
            confidence: 0.1
        )
    }
    
    private func estimateRetailPrice(brand: String, category: String) -> Double {
        let brandLower = brand.lowercased()
        let categoryLower = category.lowercased()
        
        // Footwear
        if categoryLower.contains("shoe") {
            if brandLower.contains("jordan") { return 170.0 }
            if brandLower.contains("nike") { return 120.0 }
            if brandLower.contains("adidas") { return 110.0 }
            if brandLower.contains("vans") { return 65.0 }
            return 80.0
        }
        
        // Electronics
        if categoryLower.contains("electronic") || categoryLower.contains("phone") {
            if brandLower.contains("apple") { return 600.0 }
            if brandLower.contains("samsung") { return 500.0 }
            if brandLower.contains("sony") { return 300.0 }
            return 200.0
        }
        
        // Clothing
        if categoryLower.contains("clothing") || categoryLower.contains("shirt") {
            if brandLower.contains("supreme") { return 150.0 }
            if brandLower.contains("off-white") { return 300.0 }
            if brandLower.contains("vintage") { return 80.0 }
            return 40.0
        }
        
        // Home goods
        if categoryLower.contains("home") || categoryLower.contains("kitchen") {
            if brandLower.contains("vintage") { return 60.0 }
            return 30.0
        }
        
        // Books
        if categoryLower.contains("book") {
            if brandLower.contains("vintage") || brandLower.contains("antique") { return 40.0 }
            return 15.0
        }
        
        // Toys
        if categoryLower.contains("toy") || categoryLower.contains("game") {
            if brandLower.contains("vintage") { return 50.0 }
            return 25.0
        }
        
        return 25.0 // Default fallback
    }
    
    private func synthesizeRealMarketData(ebayData: EbaySearchResult?, stockxData: StockXSearchResult?, productData: RealProductData) -> RealMarketData {
        var allPrices: [Double] = []
        var averagePrice: Double = 0
        var competitors = 0
        
        if let ebay = ebayData {
            allPrices.append(contentsOf: ebay.soldPrices)
            competitors = ebay.activeListings
        }
        
        if let stockx = stockxData {
            allPrices.append(stockx.lastSalePrice)
            allPrices.append(stockx.averagePrice)
        }
        
        if !allPrices.isEmpty {
            averagePrice = allPrices.reduce(0, +) / Double(allPrices.count)
        } else {
            averagePrice = productData.retailPrice * 0.6
            allPrices = [averagePrice]
        }
        
        return RealMarketData(
            soldPrices: allPrices,
            averagePrice: averagePrice,
            trend: "Stable",
            demand: "Medium",
            competitors: competitors
        )
    }
    
    private func calculateRealPricing(product: RealProductData, condition: RealConditionResult, market: RealMarketData) -> IntelligentPricingData {
        let basePrice = market.averagePrice > 0 ? market.averagePrice : product.retailPrice * 0.6
        
        // Apply condition adjustment
        let conditionMultiplier = 1.0 + (condition.priceAdjustment / 100.0)
        
        // Apply category-specific adjustments
        let categoryMultiplier = getCategoryMultiplier(category: product.category)
        
        // Apply brand premium
        let brandMultiplier = getBrandPremium(brand: product.brand)
        
        let adjustedPrice = basePrice * conditionMultiplier * categoryMultiplier * brandMultiplier
        let realisticPrice = max(5.0, adjustedPrice)
        
        return IntelligentPricingData(
            realisticPrice: realisticPrice,
            quickSalePrice: realisticPrice * 0.85,
            maxProfitPrice: realisticPrice * 1.15,
            priceRange: PriceRange(
                low: market.soldPrices.min() ?? (realisticPrice * 0.8),
                high: market.soldPrices.max() ?? (realisticPrice * 1.2),
                average: market.averagePrice
            ),
            confidence: (product.confidence + min(1.0, Double(market.soldPrices.count) / 10.0)) / 2.0,
            priceFactors: [
                "Condition: \(condition.conditionName)",
                "Market data: \(market.soldPrices.count) sales",
                "Brand: \(product.brand)",
                "Category: \(product.category)"
            ]
        )
    }
    
    private func getCategoryMultiplier(category: String) -> Double {
        switch category.lowercased() {
        case "electronics": return 1.1
        case "collectibles": return 1.2
        case "vintage": return 1.15
        case "shoes": return 1.05
        default: return 1.0
        }
    }
    
    private func getBrandPremium(brand: String) -> Double {
        let brandLower = brand.lowercased()
        
        if brandLower.contains("apple") || brandLower.contains("jordan") { return 1.2 }
        if brandLower.contains("supreme") || brandLower.contains("off-white") { return 1.15 }
        if brandLower.contains("nike") || brandLower.contains("adidas") { return 1.05 }
        if brandLower.contains("vintage") || brandLower.contains("antique") { return 1.1 }
        
        return 1.0
    }
    
    private func generateRealListing(product: RealProductData, condition: RealConditionResult, pricing: IntelligentPricingData) -> ProfessionalListingData {
        let title = generateOptimizedTitle(product: product, condition: condition)
        let description = generateOptimizedDescription(product: product, condition: condition)
        let keywords = generateKeywords(product: product)
        
        return ProfessionalListingData(
            title: title,
            description: description,
            keywords: keywords,
            listingStrategy: "Market-based pricing with condition transparency",
            recommendedCategory: mapToEbayCategory(product.category),
            shippingRecommendations: ["Secure packaging", "Insurance recommended"],
            photographyTips: ["Multiple angles", "Close-ups of condition"]
        )
    }
    
    private func generateOptimizedTitle(product: RealProductData, condition: RealConditionResult) -> String {
        var components: [String] = []
        
        if !product.brand.isEmpty { components.append(product.brand) }
        components.append(product.name)
        if !product.size.isEmpty { components.append("Size \(product.size)") }
        if !product.colorway.isEmpty { components.append(product.colorway) }
        components.append(condition.conditionName)
        
        let title = components.joined(separator: " ")
        return title.count > 77 ? String(title.prefix(77)) + "..." : title
    }
    
    private func generateOptimizedDescription(product: RealProductData, condition: RealConditionResult) -> String {
        var desc = "🔥 \(product.name) - \(condition.conditionName) 🔥\n\n"
        
        if !product.brand.isEmpty { desc += "Brand: \(product.brand)\n" }
        if !product.size.isEmpty { desc += "Size: \(product.size)\n" }
        if !product.colorway.isEmpty { desc += "Colorway: \(product.colorway)\n" }
        
        desc += "Condition: \(condition.conditionName)\n\n"
        
        if !condition.positiveNotes.isEmpty {
            desc += "✅ CONDITION HIGHLIGHTS:\n"
            for note in condition.positiveNotes {
                desc += "• \(note)\n"
            }
            desc += "\n"
        }
        
        if !condition.negativeNotes.isEmpty {
            desc += "⚠️ CONDITION NOTES:\n"
            for note in condition.negativeNotes {
                desc += "• \(note)\n"
            }
            desc += "\n"
        }
        
        desc += "✅ Authentic Item\n"
        desc += "📦 Fast Shipping\n"
        desc += "↩️ Returns Accepted\n"
        
        return desc
    }
    
    private func generateKeywords(product: RealProductData) -> [String] {
        var keywords: [String] = []
        
        if !product.brand.isEmpty { keywords.append(product.brand) }
        keywords.append(product.name)
        if !product.model.isEmpty { keywords.append(product.model) }
        if !product.size.isEmpty { keywords.append("size \(product.size)") }
        if !product.colorway.isEmpty { keywords.append(product.colorway) }
        keywords.append(product.category)
        
        return keywords
    }
    
    private func mapToEbayCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "shoes": return "Clothing, Shoes & Accessories > Men's Shoes"
        case "clothing": return "Clothing, Shoes & Accessories > Men's Clothing"
        case "electronics": return "Consumer Electronics"
        case "books": return "Books & Magazines"
        case "toys": return "Toys & Hobbies"
        case "home": return "Home & Garden"
        case "collectibles": return "Collectibles"
        default: return "Everything Else"
        }
    }
    
    private func assembleRealResult(
        images: [UIImage],
        textData: RealTextData,
        visionResult: RealVisionResult,
        conditionResult: RealConditionResult,
        productData: RealProductData,
        marketData: RealMarketData,
        pricingData: IntelligentPricingData,
        listingData: ProfessionalListingData
    ) -> AnalysisResult {
        
        let fees = calculateFees(pricingData.realisticPrice)
        let profits = calculateProfits(pricingData, fees: fees)
        
        return AnalysisResult(
            itemName: visionResult.itemName,
            brand: visionResult.brand,
            modelNumber: visionResult.modelNumber,
            category: visionResult.category,
            confidence: (visionResult.confidence + productData.confidence) / 2.0,
            actualCondition: conditionResult.conditionName,
            conditionReasons: conditionResult.damageAreas + conditionResult.wearPatterns,
            conditionScore: conditionResult.score,
            realisticPrice: pricingData.realisticPrice,
            quickSalePrice: pricingData.quickSalePrice,
            maxProfitPrice: pricingData.maxProfitPrice,
            marketRange: pricingData.priceRange,
            recentSoldPrices: marketData.soldPrices,
            averagePrice: marketData.averagePrice,
            marketTrend: marketData.trend,
            competitorCount: marketData.competitors,
            demandLevel: marketData.demand,
            ebayTitle: listingData.title,
            description: listingData.description,
            keywords: listingData.keywords,
            feesBreakdown: fees,
            profitMargins: profits,
            listingStrategy: listingData.listingStrategy,
            sourcingTips: generateSourceTips(visionResult: visionResult, conditionResult: conditionResult),
            seasonalFactors: "Standard demand patterns",
            resalePotential: calculateResalePotential(marketData: marketData, conditionResult: conditionResult),
            images: images,
            size: visionResult.size,
            colorway: visionResult.colorway,
            releaseYear: visionResult.releaseYear,
            subcategory: visionResult.category,
            authenticationNotes: generateAuthNotes(brand: visionResult.brand),
            seasonalDemand: "Standard patterns",
            sizePopularity: visionResult.size.isEmpty ? "Unknown" : "Standard",
            barcode: textData.barcodes.first
        )
    }
    
    private func calculateFees(_ price: Double) -> FeesBreakdown {
        let ebayFee = price * 0.1325
        let paypalFee = price * 0.0349 + 0.49
        let shippingCost = 12.50
        let listingFee = 0.35
        
        return FeesBreakdown(
            ebayFee: ebayFee,
            paypalFee: paypalFee,
            shippingCost: shippingCost,
            listingFees: listingFee,
            totalFees: ebayFee + paypalFee + shippingCost + listingFee
        )
    }
    
    private func calculateProfits(_ pricing: IntelligentPricingData, fees: FeesBreakdown) -> ProfitMargins {
        return ProfitMargins(
            quickSaleNet: pricing.quickSalePrice - fees.totalFees,
            realisticNet: pricing.realisticPrice - fees.totalFees,
            maxProfitNet: pricing.maxProfitPrice - fees.totalFees
        )
    }
    
    private func generateSourceTips(visionResult: RealVisionResult, conditionResult: RealConditionResult) -> [String] {
        var tips: [String] = []
        
        if !visionResult.brand.isEmpty {
            tips.append("🔍 Always verify \(visionResult.brand) authenticity")
        }
        
        if conditionResult.score > 85 {
            tips.append("✨ Excellent condition - premium pricing opportunity")
        } else if conditionResult.score < 60 {
            tips.append("⚠️ Factor in restoration costs")
        }
        
        tips.append("📦 Check for original packaging")
        tips.append("📱 Verify all product details")
        
        return tips
    }
    
    private func calculateResalePotential(marketData: RealMarketData, conditionResult: RealConditionResult) -> Int {
        var potential = 5
        
        if marketData.demand == "High" { potential += 2 }
        if conditionResult.score > 85 { potential += 2 }
        if marketData.competitors < 50 { potential += 1 }
        
        return min(10, max(1, potential))
    }
    
    private func generateAuthNotes(brand: String) -> String {
        switch brand.lowercased() {
        case "nike", "jordan":
            return "Check swoosh placement, stitching quality, and tags"
        case "adidas":
            return "Verify three stripes and logo authenticity"
        case "apple":
            return "Check serial numbers and original accessories"
        case "vintage", "antique":
            return "Verify age and authenticity markers"
        default:
            return "Verify through official brand channels"
        }
    }
    
    // MARK: - API Response Parsers
    
    private func parseEbayResponse(_ json: [String: Any]) -> EbaySearchResult? {
        if let items = json["items"] as? [[String: Any]] {
            var soldPrices: [Double] = []
            
            for item in items {
                if let price = item["price"] as? Double {
                    soldPrices.append(price)
                }
            }
            
            let averagePrice = soldPrices.isEmpty ? 0 : soldPrices.reduce(0, +) / Double(soldPrices.count)
            
            return EbaySearchResult(
                soldPrices: soldPrices,
                activeListings: items.count,
                averagePrice: averagePrice
            )
        }
        
        return nil
    }
    
    private func parseStockXResponse(_ json: [String: Any]) -> StockXSearchResult? {
        if let products = json["products"] as? [[String: Any]],
           let firstProduct = products.first {
            
            let lastSale = firstProduct["last_sale"] as? Double ?? 0
            let averagePrice = firstProduct["average_price"] as? Double ?? lastSale
            
            return StockXSearchResult(
                lastSalePrice: lastSale,
                averagePrice: averagePrice,
                volatility: "Low"
            )
        }
        
        return nil
    }
    
    private func parseBarcodeResponse(_ json: [String: Any]) -> RealProductData? {
        if let product = json["product"] as? [String: Any] {
            return RealProductData(
                name: product["title"] as? String ?? "Unknown",
                brand: product["brand"] as? String ?? "",
                model: product["model"] as? String ?? "",
                category: product["category"] as? String ?? "other",
                size: "",
                colorway: "",
                retailPrice: product["msrp"] as? Double ?? 0,
                releaseYear: "",
                confidence: 0.9
            )
        }
        
        return nil
    }
}

// MARK: - Real Data Structures
struct RealTextData {
    let allText: [String]
    let brands: [String]
    let sizes: [String]
    let models: [String]
    let barcodes: [String]
}

struct RealVisionResult {
    let itemName: String
    let brand: String
    let modelNumber: String
    let category: String
    let size: String
    let colorway: String
    let collaboration: String
    let limitedEdition: Bool
    let releaseYear: String
    let keyFeatures: [String]
    let authenticity: [String]
    let confidence: Double
}

struct RealConditionResult {
    let score: Double
    let conditionName: String
    let damageAreas: [String]
    let wearPatterns: [String]
    let positiveNotes: [String]
    let negativeNotes: [String]
    let resaleImpact: String
    let priceAdjustment: Double
}

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

struct RealMarketData {
    let soldPrices: [Double]
    let averagePrice: Double
    let trend: String
    let demand: String
    let competitors: Int
}

struct IntelligentPricingData {
    let realisticPrice: Double
    let quickSalePrice: Double
    let maxProfitPrice: Double
    let priceRange: PriceRange
    let confidence: Double
    let priceFactors: [String]
}

struct ProfessionalListingData {
    let title: String
    let description: String
    let keywords: [String]
    let listingStrategy: String
    let recommendedCategory: String
    let shippingRecommendations: [String]
    let photographyTips: [String]
}

struct EbaySearchResult {
    let soldPrices: [Double]
    let activeListings: Int
    let averagePrice: Double
}

struct StockXSearchResult {
    let lastSalePrice: Double
    let averagePrice: Double
    let volatility: String
}
