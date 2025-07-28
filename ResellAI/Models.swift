// MARK: - Fixed Models.swift with Simple Naming
import SwiftUI
import Foundation

// MARK: - Core Models with Smart Inventory System
struct InventoryItem: Identifiable, Codable {
    let id = UUID()
    var itemNumber: Int
    var inventoryCode: String = "" // Smart inventory code (e.g., "A-001", "B-023")
    var name: String
    var category: String
    var purchasePrice: Double
    var suggestedPrice: Double
    var actualPrice: Double?
    var source: String
    var condition: String
    var title: String
    var description: String
    var keywords: [String]
    var status: ItemStatus
    var dateAdded: Date
    var dateListed: Date?
    var dateSold: Date?
    var imageData: Data?
    var additionalImageData: [Data]? // Multiple photos support
    var ebayURL: String?
    var resalePotential: Int?
    var marketNotes: String?
    
    // AI analysis fields
    var conditionScore: Double?
    var aiConfidence: Double?
    var competitorCount: Int?
    var demandLevel: String?
    var listingStrategy: String?
    var sourcingTips: [String]?
    
    // Barcode support and product details
    var barcode: String?
    var brand: String = ""
    var size: String = ""
    var colorway: String = ""
    var releaseYear: String = ""
    var subcategory: String = ""
    var authenticationNotes: String = ""
    
    // Physical inventory management
    var storageLocation: String = "" // Where it's physically stored
    var binNumber: String = ""       // Specific bin/box number
    var isPackaged: Bool = false     // Ready for shipping
    var packagedDate: Date?          // When it was packaged
    
    // Initialize with comprehensive defaults
    init(itemNumber: Int, name: String, category: String, purchasePrice: Double,
         suggestedPrice: Double, source: String, condition: String, title: String,
         description: String, keywords: [String], status: ItemStatus, dateAdded: Date,
         actualPrice: Double? = nil, dateListed: Date? = nil, dateSold: Date? = nil,
         imageData: Data? = nil, additionalImageData: [Data]? = nil, ebayURL: String? = nil,
         resalePotential: Int? = nil, marketNotes: String? = nil,
         conditionScore: Double? = nil, aiConfidence: Double? = nil,
         competitorCount: Int? = nil, demandLevel: String? = nil,
         listingStrategy: String? = nil, sourcingTips: [String]? = nil,
         barcode: String? = nil, brand: String = "", size: String = "",
         colorway: String = "", releaseYear: String = "", subcategory: String = "",
         authenticationNotes: String = "", inventoryCode: String = "",
         storageLocation: String = "", binNumber: String = "") {
        self.itemNumber = itemNumber
        self.inventoryCode = inventoryCode
        self.name = name
        self.category = category
        self.purchasePrice = purchasePrice
        self.suggestedPrice = suggestedPrice
        self.actualPrice = actualPrice
        self.source = source
        self.condition = condition
        self.title = title
        self.description = description
        self.keywords = keywords
        self.status = status
        self.dateAdded = dateAdded
        self.dateListed = dateListed
        self.dateSold = dateSold
        self.imageData = imageData
        self.additionalImageData = additionalImageData
        self.ebayURL = ebayURL
        self.resalePotential = resalePotential
        self.marketNotes = marketNotes
        self.conditionScore = conditionScore
        self.aiConfidence = aiConfidence
        self.competitorCount = competitorCount
        self.demandLevel = demandLevel
        self.listingStrategy = listingStrategy
        self.sourcingTips = sourcingTips
        self.barcode = barcode
        self.brand = brand
        self.size = size
        self.colorway = colorway
        self.releaseYear = releaseYear
        self.subcategory = subcategory
        self.authenticationNotes = authenticationNotes
        self.storageLocation = storageLocation
        self.binNumber = binNumber
    }
    
    var profit: Double {
        guard let actualPrice = actualPrice else { return 0 }
        let fees = actualPrice * 0.1325 // Updated eBay fees
        return actualPrice - purchasePrice - fees
    }
    
    var roi: Double {
        guard purchasePrice > 0 else { return 0 }
        return (profit / purchasePrice) * 100
    }
    
    var estimatedProfit: Double {
        let fees = suggestedPrice * 0.1325
        return suggestedPrice - purchasePrice - fees
    }
    
    var estimatedROI: Double {
        guard purchasePrice > 0 else { return 0 }
        return (estimatedProfit / purchasePrice) * 100
    }
    
    // Net profit calculations
    var netProfitAfterAllFees: Double {
        let totalFees = suggestedPrice * 0.1325 + 8.50 + 0.30 // eBay + shipping + listing
        return suggestedPrice - purchasePrice - totalFees
    }
    
    var breakEvenPrice: Double {
        let totalFeeRate = 0.1325 + (8.80 / suggestedPrice) // eBay fees + fixed costs
        return purchasePrice / (1 - totalFeeRate)
    }
}

// FIXED ItemStatus enum with migration support
enum ItemStatus: String, CaseIterable, Codable {
    case photographed = "📷 Photographed"
    case analyzed = "🧠 AI Analyzed"
    case toList = "📋 Ready to List"
    case listed = "🏪 Listed"
    case sold = "💰 Sold"
    case prospecting = "🔍 Prospecting"
    
    // Migration support for old enum values
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Handle legacy values
        switch rawValue {
        case "Analyzed", "analyzed", "🧠 AI Analyzed":
            self = .analyzed
        case "Photographed", "photographed", "📷 Photographed":
            self = .photographed
        case "Ready to List", "toList", "📋 Ready to List":
            self = .toList
        case "Listed", "listed", "🏪 Listed":
            self = .listed
        case "Sold", "sold", "💰 Sold":
            self = .sold
        case "Prospecting", "prospecting", "🔍 Prospecting":
            self = .prospecting
        default:
            print("⚠️ Unknown ItemStatus: '\(rawValue)', defaulting to analyzed")
            self = .analyzed
        }
    }
    
    var color: Color {
        switch self {
        case .photographed: return .orange
        case .analyzed: return .blue
        case .toList: return .red
        case .listed: return .yellow
        case .sold: return .green
        case .prospecting: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .photographed: return "camera.fill"
        case .analyzed: return "brain.head.profile"
        case .toList: return "list.bullet"
        case .listed: return "storefront.fill"
        case .sold: return "dollarsign.circle.fill"
        case .prospecting: return "magnifyingglass.circle"
        }
    }
}

// MARK: - Smart Inventory Categories
enum InventoryCategory: String, CaseIterable {
    case tshirts = "T-Shirts"
    case jackets = "Jackets & Outerwear"
    case jeans = "Jeans & Denim"
    case workPants = "Work Pants"
    case dresses = "Dresses"
    case shoes = "Shoes & Footwear"
    case accessories = "Accessories"
    case electronics = "Electronics"
    case collectibles = "Collectibles"
    case home = "Home & Garden"
    case books = "Books"
    case toys = "Toys & Games"
    case sports = "Sports & Outdoors"
    case other = "Other"
    
    var inventoryLetter: String {
        switch self {
        case .tshirts: return "A"
        case .jackets: return "B"
        case .jeans: return "C"
        case .workPants: return "D"
        case .dresses: return "E"
        case .shoes: return "F"
        case .accessories: return "G"
        case .electronics: return "H"
        case .collectibles: return "I"
        case .home: return "J"
        case .books: return "K"
        case .toys: return "L"
        case .sports: return "M"
        case .other: return "Z"
        }
    }
    
    var storageTips: [String] {
        switch self {
        case .tshirts:
            return ["Fold neatly", "Store flat to prevent wrinkles", "Group by size"]
        case .jackets:
            return ["Hang to prevent creasing", "Use garment bags", "Store in cool, dry place"]
        case .jeans:
            return ["Fold along seams", "Stack by size", "Keep heavy items separate"]
        case .workPants:
            return ["Hang or fold carefully", "Check for stains before storing", "Group by brand"]
        case .dresses:
            return ["Hang on padded hangers", "Use garment bags", "Store by length"]
        case .shoes:
            return ["Clean before storing", "Use shoe boxes", "Stuff with paper to maintain shape"]
        case .accessories:
            return ["Use small containers", "Keep sets together", "Protect delicate items"]
        case .electronics:
            return ["Original boxes preferred", "Anti-static bags", "Temperature controlled area"]
        default:
            return ["Handle with care", "Clean before storing", "Label clearly"]
        }
    }
}

enum SourceLocation: String, CaseIterable {
    case cityWalk = "City Walk"
    case goodwillBins = "Goodwill Bins"
    case goodCents = "Good Cents"
    case estateSale = "Estate Sale"
    case yardSale = "Yard Sale"
    case facebookMarketplace = "Facebook Marketplace"
    case offerUp = "OfferUp"
    case craigslist = "Craigslist"
    case auction = "Auction"
    case thriftStore = "Thrift Store"
    case online = "Online"
    case other = "Other"
    
    var profitability: String {
        switch self {
        case .goodwillBins: return "🔥 Highest"
        case .estateSale, .yardSale: return "🎯 Very High"
        case .goodCents, .thriftStore: return "💰 High"
        case .auction: return "⚡ Variable"
        case .facebookMarketplace, .offerUp: return "📱 Medium"
        default: return "📊 Low-Medium"
        }
    }
}

// MARK: - Analysis Models (Updated with Simple Names)
protocol ItemAnalysis {
    var itemName: String { get }
    var category: String { get }
    var suggestedPrice: Double { get }
    var confidence: Double { get }
    var ebayTitle: String { get }
    var description: String { get }
    var keywords: [String] { get }
    var condition: String { get }
    var resalePotential: Int { get }
    var marketNotes: String { get }
}

struct BasicItemAnalysis: ItemAnalysis {
    let itemName: String
    let category: String
    let suggestedPrice: Double
    let confidence: Double
    let ebayTitle: String
    let description: String
    let keywords: [String]
    let condition: String
    let resalePotential: Int
    let marketNotes: String
}

struct ItemAnalysisResult: ItemAnalysis {
    let itemName: String
    let category: String
    let modelNumber: String
    let suggestedPrice: Double
    let priceRange: PriceRange
    let confidence: Double
    let ebayTitle: String
    let description: String
    let keywords: [String]
    let condition: String
    let resalePotential: Int
    let marketNotes: String
    let authenticationNotes: String
    let shippingNotes: String
    let competitionLevel: String
    let seasonalDemand: String
    let photosAnalyzed: Int
}

struct PriceRange {
    var low: Double
    var high: Double
    var average: Double
    
    init(low: Double = 0, high: Double = 0, average: Double = 0) {
        self.low = low
        self.high = high
        self.average = average
    }
}

// MARK: - Prospecting Models
struct ProspectAnalysis {
    let itemName: String
    let brand: String
    let condition: String
    let confidence: Double
    let estimatedValue: Double
    let maxPayPrice: Double        // Max price you should pay
    let potentialProfit: Double
    let expectedROI: Double
    let recommendation: ProspectDecision
    let reasons: [String]
    let riskLevel: String
    let demandLevel: String
    let competitorCount: Int
    let marketTrend: String
    let sellTimeEstimate: String
    let seasonalFactors: String
    let sourcingTips: [String]
    let images: [UIImage]
    
    // Prospecting-specific properties
    let breakEvenPrice: Double     // Minimum to break even
    let targetBuyPrice: Double     // Ideal purchase price for good profit
    let quickFlipPotential: Bool   // Can be sold quickly
    let holidayDemand: Bool        // Higher demand during holidays
}

// MARK: - Missing Types for Services
struct QuickIdentification {
    let itemName: String
    let brand: String
    let condition: String
    let confidence: Double
}

struct ProspectRecommendation {
    let decision: ProspectDecision
    let reasons: [String]
    let riskLevel: String
    let sourcingTips: [String]
}

enum ProspectDecision {
    case buy, investigate, avoid
    
    var emoji: String {
        switch self {
        case .buy: return "✅"
        case .investigate: return "🤔"
        case .avoid: return "❌"
        }
    }
    
    var title: String {
        switch self {
        case .buy: return "BUY NOW"
        case .investigate: return "INVESTIGATE"
        case .avoid: return "AVOID"
        }
    }
    
    var color: Color {
        switch self {
        case .buy: return .green
        case .investigate: return .orange
        case .avoid: return .red
        }
    }
    
    var description: String {
        switch self {
        case .buy: return "Great profit opportunity!"
        case .investigate: return "Proceed with caution"
        case .avoid: return "Not profitable at this price"
        }
    }
}

// MARK: - Photo Source
enum PhotoSource {
    case camera
    case photoLibrary
    case multiPhoto
}

// MARK: - App Constants
struct ResellAIConstants {
    static let maxPhotosPerItem = 8
    static let minConfidenceThreshold = 0.3
    static let defaultROITarget = 200.0
    static let maxAnalysisTime: TimeInterval = 30.0
    static let cacheExpirationTime: TimeInterval = 3600.0 // 1 hour
    static let supportedImageFormats = ["jpg", "jpeg", "png", "heic"]
    static let maxImageSize: Int = 10 * 1024 * 1024 // 10MB
    
    struct Fees {
        static let ebayFinalValueFee = 0.1325 // 13.25%
        static let averageShippingCost = 8.50
        static let listingFee = 0.30
        static let promotionalFee = 0.02 // 2% for promoted listings
    }
    
    struct Timing {
        static let optimalListingDays = ["Sunday", "Monday", "Tuesday"]
        static let optimalListingHours = ["6 PM", "7 PM", "8 PM", "9 PM"]
        static let peakShoppingMonths = ["November", "December", "January"]
    }
    
    struct Prospecting {
        static let minROIThreshold = 50.0      // Minimum 50% ROI
        static let idealROIThreshold = 100.0   // Ideal 100%+ ROI
        static let maxRiskThreshold = 0.3      // 30% max risk tolerance
        static let quickSaleMultiplier = 0.85  // 15% discount for quick sale
        static let maxBuyMultiplier = 0.6      // Buy at 60% of estimated value max
    }
}

// MARK: - Business Intelligence Models
struct InventoryStatistics {
    let totalItems: Int
    let listedItems: Int
    let soldItems: Int
    let totalInvestment: Double
    let totalProfit: Double
    let averageROI: Double
    let estimatedValue: Double
    
    var potentialProfit: Double {
        estimatedValue - totalInvestment - (estimatedValue * 0.13) // Minus fees
    }
    
    var successRate: Double {
        guard totalItems > 0 else { return 0 }
        return Double(soldItems) / Double(totalItems) * 100
    }
    
    var averageTimeToSell: Double {
        // This would be calculated from actual data
        return 12.0 // days
    }
}

// MARK: - API Data Models (Updated Names)
struct VisionAnalysisResults {
    let detectedCondition: String
    let conditionScore: Double
    let damageFound: [String]
    let textDetected: [String]
    let confidenceLevel: Double
}

struct AIResults {
    let itemName: String
    let brand: String
    let modelNumber: String
    let size: String
    let colorway: String
    let releaseYear: String
    let category: String
    let subcategory: String
    let confidence: Double
    let realisticCondition: String
    let conditionJustification: String
    let estimatedRetailPrice: Double
    let realisticUsedPrice: Double
    let priceJustification: String
    let keywords: [String]
    let competitionLevel: String
    let marketReality: String
    let authenticationNotes: String
    let seasonalDemand: String
    let sizePopularity: String
}

struct LiveMarketData {
    let recentSales: [Double]
    let averagePrice: Double
    let trend: String
    let competitorCount: Int
    let demandLevel: String
    let seasonalTrends: String
}

struct AdvancedPricingData {
    let realisticPrice: Double
    let quickSalePrice: Double
    let maxProfitPrice: Double
    let priceRange: PriceRange
    let confidenceLevel: Double
}

struct FeesBreakdown {
    let ebayFee: Double
    let paypalFee: Double
    let shippingCost: Double
    let listingFees: Double
    let totalFees: Double
}

struct ProfitMargins {
    let quickSaleNet: Double
    let realisticNet: Double
    let maxProfitNet: Double
}

// MARK: - Analysis Results (Updated Name)
struct AnalysisResult {
    let itemName: String
    let brand: String
    let modelNumber: String
    let category: String
    let confidence: Double
    let actualCondition: String
    let conditionReasons: [String]
    let conditionScore: Double
    let realisticPrice: Double
    let quickSalePrice: Double
    let maxProfitPrice: Double
    let marketRange: PriceRange
    let recentSoldPrices: [Double]
    let averagePrice: Double
    let marketTrend: String
    let competitorCount: Int
    let demandLevel: String
    let ebayTitle: String
    let description: String
    let keywords: [String]
    let feesBreakdown: FeesBreakdown
    let profitMargins: ProfitMargins
    let listingStrategy: String
    let sourcingTips: [String]
    let seasonalFactors: String
    let resalePotential: Int
    let images: [UIImage]
    
    // Product details
    let size: String
    let colorway: String
    let releaseYear: String
    let subcategory: String
    let authenticationNotes: String
    let seasonalDemand: String
    let sizePopularity: String
    let barcode: String?
    
    // Initialize with product details
    init(itemName: String, brand: String, modelNumber: String, category: String, confidence: Double,
         actualCondition: String, conditionReasons: [String], conditionScore: Double,
         realisticPrice: Double, quickSalePrice: Double, maxProfitPrice: Double, marketRange: PriceRange,
         recentSoldPrices: [Double], averagePrice: Double, marketTrend: String, competitorCount: Int,
         demandLevel: String, ebayTitle: String, description: String, keywords: [String],
         feesBreakdown: FeesBreakdown, profitMargins: ProfitMargins, listingStrategy: String,
         sourcingTips: [String], seasonalFactors: String, resalePotential: Int, images: [UIImage],
         size: String = "", colorway: String = "", releaseYear: String = "", subcategory: String = "",
         authenticationNotes: String = "", seasonalDemand: String = "", sizePopularity: String = "",
         barcode: String? = nil) {
        self.itemName = itemName
        self.brand = brand
        self.modelNumber = modelNumber
        self.category = category
        self.confidence = confidence
        self.actualCondition = actualCondition
        self.conditionReasons = conditionReasons
        self.conditionScore = conditionScore
        self.realisticPrice = realisticPrice
        self.quickSalePrice = quickSalePrice
        self.maxProfitPrice = maxProfitPrice
        self.marketRange = marketRange
        self.recentSoldPrices = recentSoldPrices
        self.averagePrice = averagePrice
        self.marketTrend = marketTrend
        self.competitorCount = competitorCount
        self.demandLevel = demandLevel
        self.ebayTitle = ebayTitle
        self.description = description
        self.keywords = keywords
        self.feesBreakdown = feesBreakdown
        self.profitMargins = profitMargins
        self.listingStrategy = listingStrategy
        self.sourcingTips = sourcingTips
        self.seasonalFactors = seasonalFactors
        self.resalePotential = resalePotential
        self.images = images
        self.size = size
        self.colorway = colorway
        self.releaseYear = releaseYear
        self.subcategory = subcategory
        self.authenticationNotes = authenticationNotes
        self.seasonalDemand = seasonalDemand
        self.sizePopularity = sizePopularity
        self.barcode = barcode
    }
}

// MARK: - Barcode Data Structure
struct BarcodeData {
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

// MARK: - Market Analysis Models
struct MarketIntelligence {
    let category: String
    let averagePrice: Double
    let competitionLevel: String
    let demandTrend: String
    let seasonalFactors: String
    let topKeywords: [String]
    let pricingStrategy: String
    let listingTips: [String]
}

// MARK: - Automation Models
struct AutoListingTemplate {
    let category: String
    let titleTemplate: String
    let descriptionTemplate: String
    let keywordTemplates: [String]
    let pricingStrategy: String
    let shippingSettings: String
    let returnPolicy: String
}

// MARK: - Error Handling
enum ResellAIError: Error, LocalizedError {
    case invalidImage
    case analysisTimeout
    case networkError
    case apiKeyMissing
    case insufficientData
    case cameraUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format or size"
        case .analysisTimeout:
            return "Analysis timed out - please try again"
        case .networkError:
            return "Network connection error"
        case .apiKeyMissing:
            return "API key not configured"
        case .insufficientData:
            return "Insufficient data for analysis"
        case .cameraUnavailable:
            return "Camera not available"
        }
    }
}
