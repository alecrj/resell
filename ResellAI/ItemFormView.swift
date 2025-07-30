import SwiftUI
import Foundation

// MARK: - Clean Item Form View
struct ItemFormView: View {
    let analysis: AnalysisResult
    let onSave: (InventoryItem) -> Void
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var condition: String = ""
    @State private var purchasePrice: Double = 0
    @State private var suggestedPrice: Double = 0
    @State private var source: String = "Thrift Store"
    @State private var notes: String = ""
    @State private var size: String = ""
    @State private var colorway: String = ""
    @State private var storageLocation: String = ""
    
    let sources = ["Thrift Store", "Goodwill Bins", "Estate Sale", "Yard Sale", "Facebook Marketplace", "OfferUp", "Auction", "Other"]
    
    var estimatedProfit: Double {
        guard purchasePrice > 0 && suggestedPrice > 0 else { return 0 }
        let fees = suggestedPrice * 0.1325 + 8.50 + 0.30
        return suggestedPrice - purchasePrice - fees
    }
    
    var estimatedROI: Double {
        guard purchasePrice > 0 && estimatedProfit > 0 else { return 0 }
        return (estimatedProfit / purchasePrice) * 100
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Photos Section
                if !analysis.images.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(0..<analysis.images.count, id: \.self) { index in
                                    Image(uiImage: analysis.images[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    } header: {
                        Text("Photos")
                    }
                }
                
                // Product Details
                Section("Product Details") {
                    TextField("Item Name", text: $name)
                    TextField("Brand", text: $brand)
                    TextField("Size", text: $size)
                    TextField("Color/Style", text: $colorway)
                    
                    Picker("Condition", selection: $condition) {
                        ForEach(EbayCondition.allCases, id: \.self) { condition in
                            Text(condition.rawValue).tag(condition.rawValue)
                        }
                    }
                }
                
                // Pricing
                Section("Pricing") {
                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        Text("$")
                        TextField("0.00", value: $purchasePrice, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Suggested Price")
                        Spacer()
                        Text("$")
                        TextField("0.00", value: $suggestedPrice, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    // Profit Display
                    if purchasePrice > 0 && suggestedPrice > 0 {
                        HStack {
                            Text("Est. Profit")
                            Spacer()
                            Text("$\(String(format: "%.2f", estimatedProfit))")
                                .fontWeight(.semibold)
                                .foregroundColor(estimatedProfit > 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Est. ROI")
                            Spacer()
                            Text("\(String(format: "%.0f", estimatedROI))%")
                                .fontWeight(.semibold)
                                .foregroundColor(getROIColor(estimatedROI))
                        }
                    }
                }
                
                // Source & Storage
                Section("Source & Storage") {
                    Picker("Source", selection: $source) {
                        ForEach(sources, id: \.self) { source in
                            Text(source).tag(source)
                        }
                    }
                    
                    TextField("Storage Location", text: $storageLocation)
                        .textInputAutocapitalization(.words)
                }
                
                // Notes
                Section("Notes") {
                    TextField("Additional Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                // AI Analysis Summary
                Section("AI Analysis") {
                    HStack {
                        Text("Confidence")
                        Spacer()
                        Text("\(String(format: "%.0f", analysis.confidence.overall * 100))%")
                            .fontWeight(.semibold)
                            .foregroundColor(getConfidenceColor(analysis.confidence.overall))
                    }
                    
                    HStack {
                        Text("Market Data")
                        Spacer()
                        Text("\(analysis.soldListings.count) sales")
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Category")
                        Spacer()
                        Text(analysis.category)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add to Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || purchasePrice <= 0)
                }
            }
        }
        .onAppear {
            loadFromAnalysis()
        }
    }
    
    private func loadFromAnalysis() {
        name = analysis.itemName
        brand = analysis.brand
        condition = analysis.actualCondition
        suggestedPrice = analysis.realisticPrice
        size = analysis.identificationResult.size
        colorway = analysis.identificationResult.colorway
    }
    
    private func saveItem() {
        let imageData = analysis.images.first?.jpegData(compressionQuality: 0.8)
        let additionalImageData = analysis.images.dropFirst().compactMap { $0.jpegData(compressionQuality: 0.7) }
        
        let newItem = InventoryItem(
            itemNumber: inventoryManager.nextItemNumber,
            name: name,
            category: analysis.category,
            purchasePrice: purchasePrice,
            suggestedPrice: suggestedPrice,
            source: source,
            condition: condition,
            title: analysis.ebayTitle,
            description: analysis.description,
            keywords: analysis.keywords,
            status: .analyzed,
            dateAdded: Date(),
            imageData: imageData,
            additionalImageData: additionalImageData.isEmpty ? nil : additionalImageData,
            aiConfidence: analysis.confidence.overall,
            competitorCount: analysis.competitorCount,
            demandLevel: analysis.demandLevel,
            brand: brand,
            size: size,
            colorway: colorway,
            storageLocation: storageLocation,
            exactModel: analysis.itemName,
            styleCode: analysis.identificationResult.styleCode,
            ebayCondition: analysis.ebayCondition
        )
        
        onSave(newItem)
    }
    
    private func getROIColor(_ roi: Double) -> Color {
        switch roi {
        case 100...: return .green
        case 50..<100: return .orange
        default: return .red
        }
    }
    
    private func getConfidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
}

// MARK: - Clean Direct eBay Listing View
struct DirectEbayListingView: View {
    let analysis: AnalysisResult
    @EnvironmentObject var ebayListingService: EbayListingService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var generatedListing = ""
    @State private var isGenerating = false
    @State private var listingURL: String?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create eBay Listing")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Professional listing generation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Analysis Summary
                    CleanAnalysisSummary(analysis: analysis)
                    
                    // Generated Listing
                    if generatedListing.isEmpty {
                        Button(action: generateListing) {
                            HStack(spacing: 8) {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Generating...")
                                } else {
                                    Image(systemName: "doc.text")
                                    Text("Generate Professional Listing")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                        .disabled(isGenerating)
                    } else {
                        CleanGeneratedListing(
                            listing: generatedListing,
                            listingURL: listingURL,
                            onShare: { showingShareSheet = true },
                            onCopy: copyToClipboard
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generatedListing])
        }
    }
    
    private func generateListing() {
        isGenerating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            generatedListing = createOptimizedListing()
        }
    }
    
    private func createOptimizedListing() -> String {
        return """
        \(analysis.ebayTitle)
        
        CONDITION: \(analysis.actualCondition)
        \(analysis.ebayCondition.description)
        
        DETAILS:
        • Brand: \(analysis.brand)
        • Category: \(analysis.category)
        • Model: \(analysis.itemName)
        • Size: \(analysis.identificationResult.size)
        • Style: \(analysis.identificationResult.colorway)
        • Code: \(analysis.identificationResult.styleCode)
        • Verified Authentic
        
        MARKET INSIGHTS:
        • Based on \(analysis.soldListings.count) recent sales
        • Average price: $\(String(format: "%.2f", analysis.averagePrice))
        • \(analysis.confidence.overall > 0.8 ? "High" : "Good") confidence analysis
        
        SHIPPING:
        • Fast shipping with tracking
        • Carefully packaged
        • 30-day returns
        
        WHY BUY FROM US:
        ✓ AI-verified authentic items
        ✓ Professional condition assessment
        ✓ Fast shipping
        ✓ Excellent service
        
        Keywords: \(analysis.keywords.joined(separator: " "))
        
        Starting: $\(String(format: "%.2f", analysis.quickSalePrice))
        Buy Now: $\(String(format: "%.2f", analysis.realisticPrice))
        """
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatedListing
    }
}

// MARK: - Clean Analysis Summary
struct CleanAnalysisSummary: View {
    let analysis: AnalysisResult
    
    var body: some View {
        VStack(spacing: 12) {
            if let firstImage = analysis.images.first {
                Image(uiImage: firstImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 150)
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(analysis.itemName)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if !analysis.brand.isEmpty {
                            Text(analysis.brand)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(String(format: "%.0f", analysis.realisticPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Market Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Condition: \(analysis.actualCondition)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", analysis.confidence.overall * 100))% confident")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !analysis.soldListings.isEmpty {
                    Text("Based on \(analysis.soldListings.count) recent sales")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Clean Generated Listing
struct CleanGeneratedListing: View {
    let listing: String
    let listingURL: String?
    let onShare: () -> Void
    let onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Professional eBay Listing")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView {
                Text(listing)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .frame(maxHeight: 300)
            
            HStack(spacing: 12) {
                Button("Share") {
                    onShare()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Copy") {
                    onCopy()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if let url = listingURL {
                Button("View on eBay") {
                    if let ebayURL = URL(string: url) {
                        UIApplication.shared.open(ebayURL)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
