//
//  AIService.swift
//  ResellAI
//
//  Complete AI Service Integration - No Duplicates
//

import SwiftUI
import Foundation

// MARK: - Complete AI Service with Proper Integration
class AIService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 8
    
    private let realService = RealAIAnalysisService()
    
    init() {
        print("🤖 AI Service initialized")
        
        // Bind published properties from real service to avoid threading issues
        realService.$isAnalyzing.receive(on: DispatchQueue.main).assign(to: &$isAnalyzing)
        realService.$analysisProgress.receive(on: DispatchQueue.main).assign(to: &$analysisProgress)
        realService.$currentStep.receive(on: DispatchQueue.main).assign(to: &$currentStep)
        realService.$totalSteps.receive(on: DispatchQueue.main).assign(to: &$totalSteps)
    }
    
    // MARK: - Main Analysis Function
    func analyzeItem(_ images: [UIImage], completion: @escaping (AnalysisResult?) -> Void) {
        guard !images.isEmpty else {
            print("❌ No images provided for analysis")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        print("🔍 Starting analysis with \(images.count) images")
        
        // Use real service for analysis
        realService.analyzeItem(images: images) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Prospecting Analysis
    func analyzeForProspecting(images: [UIImage], category: String, completion: @escaping (ProspectAnalysis?) -> Void) {
        guard !images.isEmpty else {
            print("❌ No images provided for prospecting")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        print("🎯 Starting prospecting analysis with \(images.count) images")
        
        realService.analyzeForProspecting(images: images, category: category) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Barcode Analysis
    func analyzeBarcode(_ barcode: String, images: [UIImage], completion: @escaping (AnalysisResult?) -> Void) {
        print("📱 Analyzing barcode: \(barcode)")
        
        realService.analyzeBarcode(barcode, images: images) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func lookupBarcodeForProspecting(_ barcode: String, completion: @escaping (ProspectAnalysis?) -> Void) {
        print("🎯 Looking up barcode for prospecting: \(barcode)")
        
        realService.lookupBarcodeForProspecting(barcode) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Additional Analysis Features
    func getProductAuthentication(images: [UIImage], productInfo: PrecisionIdentificationResult, completion: @escaping (AuthenticationResult) -> Void) {
        realService.authenticateProduct(images, productInfo: productInfo) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func getMarketIntelligence(for product: String, completion: @escaping (MarketIntelligence) -> Void) {
        realService.getMarketIntelligence(for: product) { intelligence in
            DispatchQueue.main.async {
                completion(intelligence)
            }
        }
    }
    
    func extractTextFromImages(_ images: [UIImage], completion: @escaping ([String]) -> Void) {
        realService.extractTextFromImages(images) { textArray in
            DispatchQueue.main.async {
                completion(textArray)
            }
        }
    }
    
    func detectBrands(in images: [UIImage], completion: @escaping ([String]) -> Void) {
        realService.detectBrands(in: images) { brands in
            DispatchQueue.main.async {
                completion(brands)
            }
        }
    }
    
    // MARK: - Status Methods
    var isConfigured: Bool {
        return !Configuration.openAIKey.isEmpty
    }
    
    var configurationStatus: String {
        if isConfigured {
            return "OpenAI configured and ready"
        } else {
            return "OpenAI API key missing"
        }
    }
    
    // MARK: - Utility Methods
    func cancelAnalysis() {
        DispatchQueue.main.async {
            self.isAnalyzing = false
            self.analysisProgress = "Analysis cancelled"
            self.currentStep = 0
        }
    }
    
    func resetProgress() {
        DispatchQueue.main.async {
            self.currentStep = 0
            self.analysisProgress = "Ready"
            self.isAnalyzing = false
        }
    }
}

// MARK: - eBay Listing Service Integration
class EbayListingService: ObservableObject {
    @Published var isListing = false
    @Published var listingProgress = "Ready to list"
    @Published var listingResults: [EbayListingResult] = []
    
    private let realService = EbayListingManager()
    
    init() {
        print("🏪 eBay Listing Service initialized")
        
        // Bind published properties with proper threading
        realService.$isListing.receive(on: DispatchQueue.main).assign(to: &$isListing)
        realService.$listingProgress.receive(on: DispatchQueue.main).assign(to: &$listingProgress)
        realService.$listingResults.receive(on: DispatchQueue.main).assign(to: &$listingResults)
    }
    
    // MARK: - eBay Listing Functions
    func listItemToEbay(item: InventoryItem, analysis: AnalysisResult, completion: @escaping (EbayListingResult) -> Void) {
        print("🏪 Creating eBay listing for: \(item.name)")
        
        realService.listItemToEbay(item: item, analysis: analysis) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func generateOptimizedTitle(for analysis: AnalysisResult) -> String {
        return realService.generateOptimizedTitle(for: analysis)
    }
    
    func generateOptimizedDescription(for item: InventoryItem, analysis: AnalysisResult) -> String {
        return realService.generateOptimizedDescription(for: item, analysis: analysis)
    }
    
    func getListingPerformance() -> ListingPerformance {
        return realService.getListingPerformance()
    }
    
    func getRecentListings() -> [EbayListingResult] {
        return realService.getRecentListings()
    }
    
    // MARK: - Batch Operations
    func listMultipleItems(items: [(item: InventoryItem, analysis: AnalysisResult)], completion: @escaping ([EbayListingResult]) -> Void) {
        realService.listMultipleItems(items: items) { results in
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    // MARK: - Auto-Listing Queue
    func addToAutoListingQueue(_ item: InventoryItem) {
        realService.addToAutoListingQueue(item)
    }
    
    func removeFromAutoListingQueue(_ item: InventoryItem) {
        realService.removeFromAutoListingQueue(item)
    }
    
    var autoListingQueueCount: Int {
        return realService.autoListingQueue.count
    }
}

// MARK: - Service Status Monitoring
extension AIService {
    func performHealthCheck() -> ServiceHealthStatus {
        let openAIHealthy = !Configuration.openAIKey.isEmpty
        let analysisHealthy = !isAnalyzing || analysisProgress != "Analysis failed"
        
        return ServiceHealthStatus(
            openAIConfigured: openAIHealthy,
            analysisWorking: analysisHealthy,
            overallHealthy: openAIHealthy && analysisHealthy,
            lastUpdated: Date()
        )
    }
}

extension EbayListingService {
    func performHealthCheck() -> EbayServiceHealthStatus {
        let ebayConfigured = !Configuration.ebayAPIKey.isEmpty
        let listingWorking = !isListing || listingProgress != "Listing failed"
        
        return EbayServiceHealthStatus(
            ebayConfigured: ebayConfigured,
            listingWorking: listingWorking,
            overallHealthy: ebayConfigured && listingWorking,
            lastUpdated: Date()
        )
    }
}

// MARK: - Health Status Data Structures
struct ServiceHealthStatus {
    let openAIConfigured: Bool
    let analysisWorking: Bool
    let overallHealthy: Bool
    let lastUpdated: Date
}

struct EbayServiceHealthStatus {
    let ebayConfigured: Bool
    let listingWorking: Bool
    let overallHealthy: Bool
    let lastUpdated: Date
}
