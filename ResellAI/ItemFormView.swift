import SwiftUI
import Foundation

// MARK: - Item Form View for Adding to Inventory
struct ItemFormView: View {
    let analysis: AnalysisResult
    let onSave: (InventoryItem) -> Void
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editedName: String = ""
    @State private var editedBrand: String = ""
    @State private var editedCondition: String = ""
    @State private var editedPurchasePrice: Double = 0
    @State private var editedSuggestedPrice: Double = 0
    @State private var editedSource: String = "Thrift Store"
    @State private var editedNotes: String = ""
    @State private var editedSize: String = ""
    @State private var editedColorway: String = ""
    @State private var editedStorageLocation: String = ""
    
    let sources = ["Thrift Store", "Goodwill Bins", "Estate Sale", "Yard Sale", "Facebook Marketplace", "OfferUp", "Auction", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("📸 Item Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<analysis.images.count, id: \.self) { index in
                                Image(uiImage: analysis.images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 100)
                }
                
                Section("🏷️ Product Details") {
                    TextField("Item Name", text: $editedName)
                    TextField("Brand", text: $editedBrand)
                    TextField("Size", text: $editedSize)
                    TextField("Colorway", text: $editedColorway)
                    
                    Picker("Condition", selection: $editedCondition) {
                        ForEach(EbayCondition.allCases, id: \.self) { condition in
                            Text(condition.rawValue).tag(condition.rawValue)
                        }
                    }
                }
                
                Section("💰 Pricing") {
                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        Text("$")
                        TextField("0.00", value: $editedPurchasePrice, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Suggested Price")
                        Spacer()
                        Text("$")
                        TextField("0.00", value: $editedSuggestedPrice, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    if editedPurchasePrice > 0 && editedSuggestedPrice > 0 {
                        let estimatedFees = editedSuggestedPrice * 0.1325 + 8.50 + 0.30
                        let estimatedProfit = editedSuggestedPrice - editedPurchasePrice - estimatedFees
                        let estimatedROI = (estimatedProfit / editedPurchasePrice) * 100
                        
                        HStack {
                            Text("Est. Profit")
                            Spacer()
                            Text("$\(String(format: "%.2f", estimatedProfit))")
                                .foregroundColor(estimatedProfit > 0 ? .green : .red)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("Est. ROI")
                            Spacer()
                            Text("\(String(format: "%.1f", estimatedROI))%")
                                .foregroundColor(estimatedROI > 100 ? .green : estimatedROI > 50 ? .orange : .red)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                Section("📦 Source & Storage") {
                    Picker("Source", selection: $editedSource) {
                        ForEach(sources, id: \.self) { source in
                            Text(source).tag(source)
                        }
                    }
                    
                    TextField("Storage Location", text: $editedStorageLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("📝 Notes") {
                    TextField("Additional Notes", text: $editedNotes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section("🤖 AI Analysis Summary") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Confidence:")
                            Spacer()
                            Text("\(String(format: "%.0f", analysis.confidence.overall * 100))%")
                                .fontWeight(.bold)
                                .foregroundColor(analysis.confidence.overall > 0.8 ? .green : .orange)
                        }
                        
                        HStack {
                            Text("Market Data:")
                            Spacer()
                            Text("\(analysis.soldListings.count) sold listings")
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Category:")
                            Spacer()
                            Text(analysis.category)
                                .foregroundColor(.purple)
                        }
                    }
                    .font(.caption)
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
                    .fontWeight(.bold)
                    .disabled(editedName.isEmpty || editedPurchasePrice <= 0)
                }
            }
        }
        .onAppear {
            loadFromAnalysis()
        }
    }
    
    private func loadFromAnalysis() {
        editedName = analysis.itemName
        editedBrand = analysis.brand
        editedCondition = analysis.actualCondition
        editedSuggestedPrice = analysis.realisticPrice
        editedSize = analysis.identificationResult.size
        editedColorway = analysis.identificationResult.colorway
    }
    
    private func saveItem() {
        let imageData = analysis.images.first?.jpegData(compressionQuality: 0.8)
        let additionalImageData = analysis.images.dropFirst().compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        let newItem = InventoryItem(
            itemNumber: inventoryManager.nextItemNumber,
            name: editedName,
            category: analysis.category,
            purchasePrice: editedPurchasePrice,
            suggestedPrice: editedSuggestedPrice,
            source: editedSource,
            condition: editedCondition,
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
            brand: editedBrand,
            size: editedSize,
            colorway: editedColorway,
            storageLocation: editedStorageLocation,
            exactModel: analysis.itemName,
            styleCode: analysis.identificationResult.styleCode,
            ebayCondition: analysis.ebayCondition
        )
        
        onSave(newItem)
    }
}

// MARK: - Direct eBay Listing View
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
                        Text("🚀 DIRECT EBAY LISTING")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Professional listing generation")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Analysis Summary
                    AnalysisSummaryCard(analysis: analysis)
                    
                    // Generated Listing
                    if generatedListing.isEmpty {
                        Button(action: {
                            generateListing()
                        }) {
                            HStack(spacing: 12) {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Generating...")
                                } else {
                                    Image(systemName: "wand.and.stars")
                                        .font(.title2)
                                    Text("🤖 Generate Professional eBay Listing")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                            .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isGenerating)
                    } else {
                        GeneratedListingSection(
                            listing: generatedListing,
                            listingURL: listingURL,
                            onShare: { showingShareSheet = true },
                            onCopy: { copyToClipboard() }
                        )
                    }
                    
                    Spacer(minLength: 50)
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
        
        // Generate optimized eBay listing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            generatedListing = generateOptimizedEbayListing()
        }
    }
    
    private func generateOptimizedEbayListing() -> String {
        return """
        🔥 \(analysis.ebayTitle) 🔥
        
        ⭐ CONDITION: \(analysis.actualCondition)
        \(analysis.ebayCondition.description)
        
        💎 ITEM DETAILS:
        • Brand: \(analysis.brand)
        • Category: \(analysis.category)
        • Model: \(analysis.itemName)
        • Size: \(analysis.identificationResult.size)
        • Colorway: \(analysis.identificationResult.colorway)
        • Style Code: \(analysis.identificationResult.styleCode)
        • AI Verified Authentic
        
        📊 MARKET INSIGHTS:
        • Based on \(analysis.soldListings.count) recent sales
        • Average market price: $\(String(format: "%.2f", analysis.averagePrice))
        • High demand item with \(analysis.confidence.overall > 0.8 ? "excellent" : "good") market data
        
        📦 FAST SHIPPING:
        • Same or next business day shipping
        • Carefully packaged with tracking
        • 30-day return policy
        
        🎯 WHY BUY FROM US:
        ✅ AI-verified authentic items
        ✅ Professional condition assessment
        ✅ Fast & secure shipping
        ✅ Excellent customer service
        ✅ Market-competitive pricing
        
        📱 QUESTIONS? Message us anytime!
        
        🔍 Keywords: \(analysis.keywords.joined(separator: " "))
        
        Starting bid: $\(String(format: "%.2f", analysis.quickSalePrice))
        Buy It Now: $\(String(format: "%.2f", analysis.realisticPrice))
        
        Powered by ResellAI - Professional reselling technology 🤖
        """
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatedListing
    }
}

// MARK: - Supporting Components
struct AnalysisSummaryCard: View {
    let analysis: AnalysisResult
    
    var body: some View {
        VStack(spacing: 15) {
            if let firstImage = analysis.images.first {
                Image(uiImage: firstImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 12) {
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
                        Text("$\(String(format: "%.2f", analysis.realisticPrice))")
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
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Confidence: \(String(format: "%.0f", analysis.confidence.overall * 100))%")
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.05))
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct GeneratedListingSection: View {
    let listing: String
    let listingURL: String?
    let onShare: () -> Void
    let onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("📝 Professional eBay Listing")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView {
                Text(listing)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .frame(maxHeight: 400)
            
            HStack(spacing: 15) {
                Button(action: onShare) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: onCopy) {
                    HStack {
                        Image(systemName: "doc.on.clipboard")
                        Text("Copy")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            if let url = listingURL {
                Button(action: {
                    if let ebayURL = URL(string: url) {
                        UIApplication.shared.open(ebayURL)
                    }
                }) {
                    HStack {
                        Image(systemName: "link")
                        Text("View on eBay")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }
}
