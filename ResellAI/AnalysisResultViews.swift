import SwiftUI

// MARK: - Updated Analysis Result Views for eBay Standards

// MARK: - Main Analysis Result View with Real eBay Data
struct AnalysisResultView: View {
    let analysis: AnalysisResult
    let onAddToInventory: () -> Void
    let onDirectList: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Google Lens-Level Identification Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(analysis.itemName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            // AI Confidence Badge
                            ConfidenceBadge(confidence: analysis.confidence.overall)
                        }
                        
                        if !analysis.brand.isEmpty {
                            Text(analysis.brand)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        // Product Details Row
                        HStack {
                            if !analysis.identificationResult.styleCode.isEmpty {
                                Text("Style: \(analysis.identificationResult.styleCode)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            if !analysis.identificationResult.size.isEmpty {
                                Text("Size: \(analysis.identificationResult.size)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            Text(analysis.identificationResult.identificationMethod.displayName)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(String(format: "%.2f", analysis.realisticPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Market Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // eBay Condition Assessment
                EbayConditionCard(
                    condition: analysis.ebayCondition,
                    assessment: analysis.marketAnalysis.conditionAssessment
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            
            // Real eBay Market Data
            RealEbayMarketCard(marketData: analysis.marketAnalysis.marketData)
            
            // Pricing Strategy with Real Data
            EbayPricingStrategyCard(
                pricing: analysis.ebayPricing,
                soldListings: analysis.soldListings
            )
            
            // Market Intelligence with Real Metrics
            RealMarketIntelligenceCard(
                analysis: analysis.marketAnalysis,
                soldCount: analysis.soldListings.count
            )
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    onAddToInventory()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("📦 Add to Smart Inventory")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                
                Button(action: {
                    onDirectList()
                }) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("🚀 Generate Professional eBay Listing")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - eBay Condition Card
struct EbayConditionCard: View {
    let condition: EbayCondition
    let assessment: EbayConditionAssessment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏷️ EBAY CONDITION ASSESSMENT")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(condition.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(condition.color)
                    
                    Text(condition.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(String(format: "%.0f", assessment.conditionConfidence * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Condition Factors
            if !assessment.conditionFactors.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Condition Details:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(assessment.conditionFactors.indices, id: \.self) { index in
                        let factor = assessment.conditionFactors[index]
                        ConditionFactorRow(factor: factor)
                    }
                }
            }
            
            // Condition Notes
            if !assessment.conditionNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(assessment.conditionNotes, id: \.self) { note in
                        Text("• \(note)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(condition.color.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Condition Factor Row
struct ConditionFactorRow: View {
    let factor: ConditionFactor
    
    var body: some View {
        HStack {
            Text(factor.area)
                .font(.caption)
                .fontWeight(.medium)
            
            if let issue = factor.issue {
                Text("- \(issue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(factor.impactOnValue, specifier: "%.0f")%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(factor.severity.color)
        }
    }
}

// MARK: - Real eBay Market Card
struct RealEbayMarketCard: View {
    let marketData: EbayMarketData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📊 REAL EBAY MARKET DATA")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(marketData.lastUpdated, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Market Summary
            HStack {
                MarketStatCard(
                    title: "Sold Items",
                    value: "\(marketData.soldListings.count)",
                    subtitle: marketData.priceRange.dateRange,
                    color: .blue
                )
                
                MarketStatCard(
                    title: "Avg Price",
                    value: "$\(String(format: "%.2f", marketData.priceRange.average))",
                    subtitle: "Market average",
                    color: .green
                )
                
                MarketStatCard(
                    title: "Competition",
                    value: marketData.competitionLevel.displayName,
                    subtitle: "Current level",
                    color: marketData.competitionLevel.color
                )
            }
            
            // Price Breakdown by Condition
            if hasConditionPrices(marketData.priceRange) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("💰 Prices by Condition")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ConditionPriceGrid(priceRange: marketData.priceRange)
                }
            }
            
            // Market Trend
            MarketTrendIndicator(trend: marketData.marketTrend)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func hasConditionPrices(_ priceRange: EbayPriceRange) -> Bool {
        return priceRange.newWithTags != nil ||
               priceRange.excellent != nil ||
               priceRange.veryGood != nil ||
               priceRange.good != nil
    }
}

// MARK: - Condition Price Grid
struct ConditionPriceGrid: View {
    let priceRange: EbayPriceRange
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            
            if let price = priceRange.newWithTags {
                ConditionPriceChip(condition: "New w/ Tags", price: price, color: .green)
            }
            
            if let price = priceRange.excellent {
                ConditionPriceChip(condition: "Excellent", price: price, color: .blue)
            }
            
            if let price = priceRange.veryGood {
                ConditionPriceChip(condition: "Very Good", price: price, color: .orange)
            }
            
            if let price = priceRange.good {
                ConditionPriceChip(condition: "Good", price: price, color: .purple)
            }
        }
    }
}

// MARK: - Condition Price Chip
struct ConditionPriceChip: View {
    let condition: String
    let price: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("$\(String(format: "%.0f", price))")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(condition)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - eBay Pricing Strategy Card
struct EbayPricingStrategyCard: View {
    let pricing: EbayPricingRecommendation
    let soldListings: [EbaySoldListing]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💰 INTELLIGENT PRICING STRATEGY")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                PriceStrategyCard(
                    title: "Quick Sale",
                    price: pricing.quickSalePrice,
                    subtitle: "Fast turnover",
                    color: .orange,
                    isRecommended: false
                )
                
                PriceStrategyCard(
                    title: "Recommended",
                    price: pricing.recommendedPrice,
                    subtitle: "Best value",
                    color: .blue,
                    isRecommended: true
                )
                
                PriceStrategyCard(
                    title: "Max Profit",
                    price: pricing.maxProfitPrice,
                    subtitle: "Patient sale",
                    color: .green,
                    isRecommended: false
                )
            }
            
            // Strategy Details
            VStack(alignment: .leading, spacing: 6) {
                Text("💡 Pricing Justification")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ForEach(pricing.priceJustification, id: \.self) { reason in
                    Text("• \(reason)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            
            // Recent Sales Evidence
            if !soldListings.isEmpty {
                RecentSalesPreview(soldListings: Array(soldListings.prefix(3)))
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - FIXED: Price Strategy Card with proper type handling
struct PriceStrategyCard: View {
    let title: String
    let price: Double
    let subtitle: String
    let color: Color
    let isRecommended: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isRecommended ? .white : color)
            
            Text("$\(String(format: "%.0f", price))")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isRecommended ? .white : color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(isRecommended ? .white.opacity(0.8) : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            // FIXED: Use AnyShapeStyle to handle both LinearGradient and Color
            isRecommended ?
            AnyShapeStyle(LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .top, endPoint: .bottom)) :
            AnyShapeStyle(color.opacity(0.1))
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: isRecommended ? 2 : 1)
        )
    }
}

// MARK: - Recent Sales Preview
struct RecentSalesPreview: View {
    let soldListings: [EbaySoldListing]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🔥 Recent eBay Sales")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ForEach(soldListings.indices, id: \.self) { index in
                let listing = soldListings[index]
                RecentSaleRow(listing: listing)
            }
        }
    }
}

// MARK: - Recent Sale Row
struct RecentSaleRow: View {
    let listing: EbaySoldListing
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(listing.title)
                    .font(.caption)
                    .lineLimit(1)
                
                Text(listing.condition)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.2f", listing.price))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(listing.soldDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Real Market Intelligence Card
struct RealMarketIntelligenceCard: View {
    let analysis: MarketAnalysisResult
    let soldCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🧠 MARKET INTELLIGENCE")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                MarketStatCard(
                    title: "Data Quality",
                    value: analysis.confidence.dataQuality.displayName,
                    subtitle: "\(soldCount) sales",
                    color: analysis.confidence.dataQuality.color
                )
                
                MarketStatCard(
                    title: "Demand",
                    value: analysis.marketData.demandIndicators.searchVolume.displayName,
                    subtitle: "Search volume",
                    color: analysis.marketData.demandIndicators.searchVolume.color
                )
                
                MarketStatCard(
                    title: "Time to Sell",
                    value: analysis.marketData.demandIndicators.timeToSell.displayName,
                    subtitle: "Expected",
                    color: analysis.marketData.demandIndicators.timeToSell.color
                )
                
                MarketStatCard(
                    title: "Overall Score",
                    value: "\(String(format: "%.0f", analysis.confidence.overall * 100))%",
                    subtitle: "Confidence",
                    color: getConfidenceColor(analysis.confidence.overall)
                )
            }
            
            // Market Trend
            MarketTrendIndicator(trend: analysis.marketData.marketTrend)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func getConfidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6...0.79: return .blue
        case 0.4...0.59: return .orange
        default: return .red
        }
    }
}

// MARK: - Market Stat Card
struct MarketStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Market Trend Indicator
struct MarketTrendIndicator: View {
    let trend: MarketTrend
    
    var body: some View {
        HStack {
            Text("📈 Market Trend:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(trend.direction.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(trend.direction.color)
            
            Text("(\(trend.strength.displayName))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Confidence Badge
struct ConfidenceBadge: View {
    let confidence: Double
    
    var body: some View {
        Text("\(String(format: "%.0f", confidence * 100))%")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(confidenceColor)
            .cornerRadius(4)
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6...0.79: return .blue
        case 0.4...0.59: return .orange
        default: return .red
        }
    }
}

// MARK: - Extensions for Display Names and Colors

extension IdentificationMethod {
    var displayName: String {
        switch self {
        case .visualAndText: return "Visual + Text"
        case .visualOnly: return "Visual Only"
        case .textOnly: return "Text Only"
        case .categoryBased: return "Category"
        }
    }
}

extension Severity {
    var color: Color {
        switch self {
        case .minor: return .green
        case .moderate: return .orange
        case .major: return .red
        case .critical: return .purple
        }
    }
}

extension CompetitionLevel {
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .saturated: return "Saturated"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .moderate: return .blue
        case .high: return .orange
        case .saturated: return .red
        }
    }
}

extension DataQuality {
    var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .limited: return "Limited"
        case .insufficient: return "Poor"
        }
    }
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .limited: return .red
        case .insufficient: return .gray
        }
    }
}

extension SearchVolume {
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    var color: Color {
        switch self {
        case .high: return .green
        case .medium: return .orange
        case .low: return .red
        }
    }
}

extension TimeToSell {
    var displayName: String {
        switch self {
        case .immediate: return "< 1 day"
        case .fast: return "1-7 days"
        case .normal: return "1-4 weeks"
        case .slow: return "1-3 months"
        case .difficult: return "3+ months"
        }
    }
    
    var color: Color {
        switch self {
        case .immediate, .fast: return .green
        case .normal: return .blue
        case .slow: return .orange
        case .difficult: return .red
        }
    }
}

extension TrendDirection {
    var displayName: String {
        switch self {
        case .increasing: return "Increasing"
        case .stable: return "Stable"
        case .decreasing: return "Decreasing"
        }
    }
    
    var color: Color {
        switch self {
        case .increasing: return .green
        case .stable: return .blue
        case .decreasing: return .red
        }
    }
}

extension TrendStrength {
    var displayName: String {
        switch self {
        case .strong: return "Strong"
        case .moderate: return "Moderate"
        case .weak: return "Weak"
        }
    }
}

// MARK: - Keep existing ItemFormView and DirectEbayListingView
// These remain the same but will work with the new AnalysisResult structure
