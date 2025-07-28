//
//  AnalysisResultViews.swift
//  ResellAI
//
//  Created by Alec on 7/27/25.
//

import SwiftUI

// MARK: - Analysis Result Views

// MARK: - Analysis Result View
struct AnalysisResultView: View {
    let analysis: AnalysisResult
    let onAddToInventory: () -> Void
    let onDirectList: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Analysis Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(analysis.itemName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if !analysis.brand.isEmpty {
                            Text(analysis.brand)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        Text("Confidence: \(String(format: "%.0f", analysis.confidence * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(String(format: "%.2f", analysis.realisticPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Realistic Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Condition and Score
                HStack {
                    VStack(alignment: .leading) {
                        Text("Condition")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(analysis.actualCondition)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        Text("Condition Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.0f", analysis.conditionScore))/100")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(getConditionColor(analysis.conditionScore))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Resale Potential")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(analysis.resalePotential)/10")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(getPotentialColor(analysis.resalePotential))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            
            // Pricing Strategy
            PricingStrategyCard(analysis: analysis)
            
            // Market Intelligence
            MarketIntelligenceCard(analysis: analysis)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    hapticFeedback(.medium)
                    onAddToInventory()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("📦 Add to Inventory")
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
                    hapticFeedback(.medium)
                    onDirectList()
                }) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("🚀 Direct List to eBay")
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
    
    private func getConditionColor(_ score: Double) -> Color {
        switch score {
        case 90...100: return .green
        case 70...89: return .blue
        case 50...69: return .orange
        default: return .red
        }
    }
    
    private func getPotentialColor(_ potential: Int) -> Color {
        switch potential {
        case 8...10: return .green
        case 6...7: return .blue
        case 4...5: return .orange
        default: return .red
        }
    }
}

// MARK: - Pricing Strategy Card
struct PricingStrategyCard: View {
    let analysis: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💰 PRICING STRATEGY")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                PriceCard(
                    title: "Quick Sale",
                    price: analysis.quickSalePrice,
                    subtitle: "Fast turnover",
                    color: .orange
                )
                
                PriceCard(
                    title: "Realistic",
                    price: analysis.realisticPrice,
                    subtitle: "Recommended",
                    color: .blue
                )
                
                PriceCard(
                    title: "Max Profit",
                    price: analysis.maxProfitPrice,
                    subtitle: "Patient sale",
                    color: .green
                )
            }
            
            // Fees Breakdown
            VStack(alignment: .leading, spacing: 6) {
                Text("💸 Fees & Profit (at realistic price)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("eBay Fee:")
                    Spacer()
                    Text("$\(String(format: "%.2f", analysis.feesBreakdown.ebayFee))")
                }
                .font(.caption)
                
                HStack {
                    Text("Shipping:")
                    Spacer()
                    Text("$\(String(format: "%.2f", analysis.feesBreakdown.shippingCost))")
                }
                .font(.caption)
                
                Divider()
                
                HStack {
                    Text("Net Profit:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("$\(String(format: "%.2f", analysis.profitMargins.realisticNet))")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .font(.caption)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Price Card
struct PriceCard: View {
    let title: String
    let price: Double
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text("$\(String(format: "%.0f", price))")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Market Intelligence Card
struct MarketIntelligenceCard: View {
    let analysis: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 MARKET INTELLIGENCE")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                MarketStatCard(
                    title: "Competition",
                    value: "\(analysis.competitorCount) listings",
                    color: analysis.competitorCount > 100 ? .red : .green
                )
                
                MarketStatCard(
                    title: "Demand",
                    value: analysis.demandLevel,
                    color: getDemandColor(analysis.demandLevel)
                )
                
                MarketStatCard(
                    title: "Trend",
                    value: analysis.marketTrend,
                    color: getTrendColor(analysis.marketTrend)
                )
                
                MarketStatCard(
                    title: "Avg. Price",
                    value: "$\(String(format: "%.0f", analysis.averagePrice))",
                    color: .blue
                )
            }
            
            // Recent Sales Data
            if !analysis.recentSoldPrices.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("📈 Recent Sales")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(analysis.recentSoldPrices.prefix(5), id: \.self) { price in
                            Text("$\(String(format: "%.0f", price))")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func getDemandColor(_ demand: String) -> Color {
        switch demand.lowercased() {
        case "high": return .green
        case "medium": return .orange
        case "low": return .red
        default: return .gray
        }
    }
    
    private func getTrendColor(_ trend: String) -> Color {
        switch trend.lowercased() {
        case "increasing": return .green
        case "stable": return .blue
        case "decreasing": return .red
        default: return .gray
        }
    }
}

// MARK: - Market Stat Card
struct MarketStatCard: View {
    let title: String
    let value: String
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Item Form View
struct ItemFormView: View {
    let analysis: AnalysisResult
    let onSave: (InventoryItem) -> Void
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var purchasePrice: Double = 0.0
    @State private var source = "Thrift Store"
    @State private var notes = ""
    @State private var storageLocation = ""
    @State private var binNumber = ""
    
    let sources = ["Thrift Store", "Goodwill Bins", "Estate Sale", "Yard Sale", "Facebook Marketplace", "OfferUp", "Auction", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(analysis.itemName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Suggested Price")
                        Spacer()
                        Text("$\(String(format: "%.2f", analysis.realisticPrice))")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Inventory Code")
                        Spacer()
                        Text("Auto-assigned")
                            .foregroundColor(.blue)
                    }
                }
                
                Section("Purchase Information") {
                    HStack {
                        Text("Purchase Price")
                        TextField("0.00", value: $purchasePrice, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Source", selection: $source) {
                        ForEach(sources, id: \.self) { source in
                            Text(source).tag(source)
                        }
                    }
                }
                
                Section("Storage") {
                    TextField("Storage Location (e.g., Closet A, Shelf 2)", text: $storageLocation)
                    TextField("Bin Number (optional)", text: $binNumber)
                }
                
                Section("Additional Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Profit Calculation Preview
                if purchasePrice > 0 {
                    Section("Profit Preview") {
                        let estimatedProfit = analysis.realisticPrice - purchasePrice - analysis.feesBreakdown.totalFees
                        let estimatedROI = purchasePrice > 0 ? (estimatedProfit / purchasePrice) * 100 : 0
                        
                        HStack {
                            Text("Estimated Profit")
                            Spacer()
                            Text("$\(String(format: "%.2f", estimatedProfit))")
                                .fontWeight(.bold)
                                .foregroundColor(estimatedProfit > 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Estimated ROI")
                            Spacer()
                            Text("\(String(format: "%.1f", estimatedROI))%")
                                .fontWeight(.bold)
                                .foregroundColor(estimatedROI > 100 ? .green : estimatedROI > 50 ? .orange : .red)
                        }
                    }
                }
            }
            .navigationTitle("Add to Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        hapticFeedback(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        hapticFeedback(.medium)
                        saveItem()
                    }
                    .disabled(purchasePrice <= 0)
                }
            }
        }
    }
    
    private func saveItem() {
        // Convert first image to Data
        let imageData = analysis.images.first?.jpegData(compressionQuality: 0.8)
        
        // Convert additional images to Data
        let additionalImageData = analysis.images.dropFirst().compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        let item = InventoryItem(
            itemNumber: inventoryManager.nextItemNumber,
            name: analysis.itemName,
            category: analysis.category,
            purchasePrice: purchasePrice,
            suggestedPrice: analysis.realisticPrice,
            source: source,
            condition: analysis.actualCondition,
            title: analysis.ebayTitle,
            description: analysis.description,
            keywords: analysis.keywords,
            status: .analyzed,
            dateAdded: Date(),
            imageData: imageData,
            additionalImageData: additionalImageData.isEmpty ? nil : additionalImageData,
            resalePotential: analysis.resalePotential,
            marketNotes: notes,
            conditionScore: analysis.conditionScore,
            aiConfidence: analysis.confidence,
            competitorCount: analysis.competitorCount,
            demandLevel: analysis.demandLevel,
            listingStrategy: analysis.listingStrategy,
            sourcingTips: analysis.sourcingTips,
            barcode: analysis.barcode,
            brand: analysis.brand,
            size: analysis.size,
            colorway: analysis.colorway,
            releaseYear: analysis.releaseYear,
            subcategory: analysis.subcategory,
            authenticationNotes: analysis.authenticationNotes,
            storageLocation: storageLocation,
            binNumber: binNumber
        )
        
        onSave(item)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Direct eBay Listing View
struct DirectEbayListingView: View {
    let analysis: AnalysisResult
    @EnvironmentObject var ebayListingService: EbayListingService
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPrice: Double
    @State private var customTitle = ""
    @State private var customDescription = ""
    
    init(analysis: AnalysisResult) {
        self.analysis = analysis
        self._selectedPrice = State(initialValue: analysis.realisticPrice)
        self._customTitle = State(initialValue: analysis.ebayTitle)
        self._customDescription = State(initialValue: analysis.description)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🚀 DIRECT EBAY LISTING")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("One-tap listing to eBay")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Item Preview
                    ItemPreviewCard(analysis: analysis, selectedPrice: selectedPrice)
                    
                    // Price Selection
                    PriceSelectionCard(analysis: analysis, selectedPrice: $selectedPrice)
                    
                    // Listing Options
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📝 Listing Details")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("eBay Title", text: $customTitle, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...3)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Item Description", text: $customDescription, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(4...8)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // List Button
                    Button(action: {
                        hapticFeedback(.heavy)
                        listToEbay()
                    }) {
                        HStack {
                            if ebayListingService.isListing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Listing to eBay...")
                            } else {
                                Image(systemName: "bolt.fill")
                                Text("🚀 LIST TO EBAY NOW")
                            }
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
                        .cornerRadius(16)
                        .font(.headline)
                        .shadow(radius: 5)
                    }
                    .disabled(ebayListingService.isListing)
                    
                    if let listingURL = ebayListingService.listingURL {
                        VStack(spacing: 12) {
                            Text("✅ Successfully Listed!")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Button("View on eBay") {
                                if let url = URL(string: listingURL) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        hapticFeedback(.light)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func listToEbay() {
        // Create a temporary inventory item for listing
        let tempItem = InventoryItem(
            itemNumber: 999999,
            name: analysis.itemName,
            category: analysis.category,
            purchasePrice: 0,
            suggestedPrice: selectedPrice,
            source: "Direct Listing",
            condition: analysis.actualCondition,
            title: customTitle,
            description: customDescription,
            keywords: analysis.keywords,
            status: .listed,
            dateAdded: Date()
        )
        
        ebayListingService.listDirectlyToEbay(item: tempItem, analysis: analysis) { success, url in
            if success {
                print("✅ Successfully listed to eBay")
            } else {
                print("❌ Failed to list to eBay")
            }
        }
    }
}

// MARK: - Item Preview Card
struct ItemPreviewCard: View {
    let analysis: AnalysisResult
    let selectedPrice: Double
    
    var body: some View {
        VStack(spacing: 12) {
            if let image = analysis.images.first {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(analysis.itemName)
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Price:")
                    Spacer()
                    Text(String(format: "$%.2f", selectedPrice))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Condition:")
                    Spacer()
                    Text(analysis.actualCondition)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Price Selection Card
struct PriceSelectionCard: View {
    let analysis: AnalysisResult
    @Binding var selectedPrice: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💰 Select Listing Price")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(spacing: 12) {
                PriceOption(
                    title: "Quick Sale",
                    price: analysis.quickSalePrice,
                    subtitle: "Fast",
                    isSelected: selectedPrice == analysis.quickSalePrice,
                    color: .orange
                ) {
                    selectedPrice = analysis.quickSalePrice
                }
                
                PriceOption(
                    title: "Realistic",
                    price: analysis.realisticPrice,
                    subtitle: "Recommended",
                    isSelected: selectedPrice == analysis.realisticPrice,
                    color: .blue
                ) {
                    selectedPrice = analysis.realisticPrice
                }
                
                PriceOption(
                    title: "Max Profit",
                    price: analysis.maxProfitPrice,
                    subtitle: "Patient",
                    isSelected: selectedPrice == analysis.maxProfitPrice,
                    color: .green
                ) {
                    selectedPrice = analysis.maxProfitPrice
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Price Option
struct PriceOption: View {
    let title: String
    let price: Double
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            onTap()
        }) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? color : .secondary)
                
                Text("$\(String(format: "%.0f", price))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? color : .primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? color.opacity(0.2) : Color.clear)
                    .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
