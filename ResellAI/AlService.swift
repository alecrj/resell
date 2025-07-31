//
//  AIService.swift
//  ResellAI
//
//  Simple wrapper for existing AI services
//

import SwiftUI
import Foundation

// MARK: - AIService Wrapper
class AIService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress = "Ready"
    @Published var currentStep = 0
    @Published var totalSteps = 6
    
    private let realService = RealAIAnalysisService()
    
    init() {
        // Bind published properties
        realService.$isAnalyzing.assign(to: &$isAnalyzing)
        realService.$analysisProgress.assign(to: &$analysisProgress)
        realService.$currentStep.assign(to: &$currentStep)
        realService.$totalSteps.assign(to: &$totalSteps)
    }
    
    func analyzeItem(_ images: [UIImage], completion: @escaping (AnalysisResult?) -> Void) {
        realService.analyzeItem(images: images, completion: completion)
    }
    
    func analyzeForProspecting(images: [UIImage], category: String, completion: @escaping (ProspectAnalysis?) -> Void) {
        realService.analyzeForProspecting(images: images, category: category, completion: completion)
    }
    
    func analyzeBarcode(_ barcode: String, images: [UIImage], completion: @escaping (AnalysisResult?) -> Void) {
        realService.analyzeBarcode(barcode, images: images, completion: completion)
    }
    
    func lookupBarcodeForProspecting(_ barcode: String, completion: @escaping (ProspectAnalysis?) -> Void) {
        realService.lookupBarcodeForProspecting(barcode, completion: completion)
    }
}

// MARK: - EbayListingService Wrapper
class EbayListingService: ObservableObject {
    @Published var isListing = false
    @Published var listingProgress = "Ready to list"
    @Published var listingResults: [EbayListingResult] = []
    
    private let realService = EbayListingManager()
    
    init() {
        // Bind published properties
        realService.$isListing.assign(to: &$isListing)
        realService.$listingProgress.assign(to: &$listingProgress)
        realService.$listingResults.assign(to: &$listingResults)
    }
    
    func listItemToEbay(item: InventoryItem, analysis: AnalysisResult, completion: @escaping (EbayListingResult) -> Void) {
        realService.listItemToEbay(item: item, analysis: analysis, completion: completion)
    }
    
    func generateOptimizedTitle(for analysis: AnalysisResult) -> String {
        return realService.generateOptimizedTitle(for: analysis)
    }
}
