import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Main Content View with Enhanced Features
struct ContentView: View {
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var aiService = AIService()
    @StateObject private var googleSheetsService = GoogleSheetsService()
    @StateObject private var ebayListingService = EbayListingService()
    
    // Homepage mode toggle
    @State private var isProspectingMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Homepage Mode Toggle
            ModeToggleView(isProspectingMode: $isProspectingMode)
            
            // Main Content
            if isProspectingMode {
                // Prospecting Mode
                ProspectingView()
                    .environmentObject(inventoryManager)
                    .environmentObject(aiService)
            } else {
                // Business Mode
                BusinessTabView()
                    .environmentObject(inventoryManager)
                    .environmentObject(aiService)
                    .environmentObject(googleSheetsService)
                    .environmentObject(ebayListingService)
            }
        }
        .onAppear {
            googleSheetsService.authenticate()
        }
    }
}

// MARK: - Mode Toggle View
struct ModeToggleView: View {
    @Binding var isProspectingMode: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("ResellAI")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            // Mode Toggle
            HStack(spacing: 0) {
                // Business Mode Button
                Button(action: {
                    isProspectingMode = false
                }) {
                    HStack {
                        Image(systemName: "building.2.fill")
                        Text("Business Mode")
                    }
                    .font(.headline)
                    .foregroundColor(isProspectingMode ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isProspectingMode ? Color.gray.opacity(0.2) : Color.blue)
                    .animation(.easeInOut(duration: 0.2), value: isProspectingMode)
                }
                
                // Prospecting Mode Button
                Button(action: {
                    isProspectingMode = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Prospecting")
                    }
                    .font(.headline)
                    .foregroundColor(isProspectingMode ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isProspectingMode ? Color.purple : Color.gray.opacity(0.2))
                    .animation(.easeInOut(duration: 0.2), value: isProspectingMode)
                }
            }
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Mode Description
            Text(isProspectingMode ?
                 "🔍 Analyze items instantly • Get max buy price • Perfect for sourcing" :
                 "📦 Manage inventory • Track profits • Auto-generate eBay listings")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - Business Tab View with Enhanced Inventory
struct BusinessTabView: View {
    var body: some View {
        TabView {
            AIAnalysisView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("🚀 Analysis")
                }
            
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("📊 Dashboard")
                }
            
            EnhancedSmartInventoryListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("📦 Inventory")
                }
            
            InventoryOrganizationView()
                .tabItem {
                    Image(systemName: "archivebox.fill")
                    Text("🏷️ Organization")
                }
            
            AppSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("⚙️ Settings")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Enhanced AI Analysis View
struct AIAnalysisView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @EnvironmentObject var ebayListingService: EbayListingService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingMultiCamera = false
    @State private var showingPhotoLibrary = false
    @State private var analysisResult: AnalysisResult?
    @State private var showingItemForm = false
    @State private var showingDirectListing = false
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Analysis Status
                    VStack(spacing: 8) {
                        Text("🚀 AI ANALYSIS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Complete inventory analysis • eBay listing generation")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Real-time Analysis Progress
                        if aiService.isAnalyzing {
                            VStack(spacing: 12) {
                                ProgressView(value: Double(aiService.currentStep), total: Double(aiService.totalSteps))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    .frame(height: 8)
                                
                                Text(aiService.analysisProgress)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.center)
                                
                                Text("Step \(aiService.currentStep)/\(aiService.totalSteps)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Cancel button for long-running analysis
                                Button("Cancel Analysis") {
                                    // Add cancel functionality if needed
                                    resetAnalysis()
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Photo Interface with Enhanced UI
                    if !capturedImages.isEmpty {
                        EnhancedPhotoGalleryView(images: $capturedImages)
                    } else {
                        PhotoPlaceholderView {
                            showingMultiCamera = true
                        }
                    }
                    
                    // Enhanced Action Buttons
                    EnhancedActionButtonsView(
                        hasPhotos: !capturedImages.isEmpty,
                        isAnalyzing: aiService.isAnalyzing,
                        photoCount: capturedImages.count,
                        onTakePhotos: { showingMultiCamera = true },
                        onAddPhotos: { showingPhotoLibrary = true },
                        onBarcodeScan: { showingBarcodeLookup = true },
                        onAnalyze: { analyzeWithRealAI() },
                        onReset: { resetAnalysis() }
                    )
                    
                    // Enhanced Analysis Results with Better Layout
                    if let result = analysisResult {
                        EnhancedAnalysisResultView(analysis: result) {
                            showingItemForm = true
                        } onDirectList: {
                            showingDirectListing = true
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingMultiCamera) {
            CameraView { photos in
                capturedImages.append(contentsOf: photos)
                analysisResult = nil
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryPicker { photos in
                capturedImages.append(contentsOf: photos)
                analysisResult = nil
            }
        }
        .sheet(isPresented: $showingItemForm) {
            if let result = analysisResult {
                EnhancedItemFormView(
                    analysis: result,
                    onSave: { item in
                        let savedItem = inventoryManager.addItem(item)
                        googleSheetsService.uploadItem(savedItem)
                        showingItemForm = false
                        resetAnalysis()
                    }
                )
                .environmentObject(inventoryManager)
            }
        }
        .sheet(isPresented: $showingDirectListing) {
            if let result = analysisResult {
                DirectEbayListingView(analysis: result)
                    .environmentObject(ebayListingService)
            }
        }
        .sheet(isPresented: $showingBarcodeLookup) {
            BarcodeScannerView(scannedCode: $scannedBarcode)
                .onDisappear {
                    if let barcode = scannedBarcode {
                        analyzeBarcode(barcode)
                    }
                }
        }
    }
    
    private func analyzeWithRealAI() {
        guard !capturedImages.isEmpty else { return }
        
        print("🚀 Starting REAL AI Analysis with \(capturedImages.count) images")
        
        aiService.analyzeItem(capturedImages) { result in
            DispatchQueue.main.async {
                analysisResult = result
                print("✅ Analysis Complete: \(result.itemName) - $\(String(format: "%.2f", result.realisticPrice))")
            }
        }
    }
    
    private func analyzeBarcode(_ barcode: String) {
        print("📱 Analyzing barcode: \(barcode)")
        
        aiService.analyzeBarcode(barcode, images: capturedImages) { result in
            DispatchQueue.main.async {
                analysisResult = result
            }
        }
    }
    
    private func resetAnalysis() {
        capturedImages = []
        analysisResult = nil
        scannedBarcode = nil
        print("🔄 Analysis reset")
    }
}

// MARK: - Enhanced Photo Gallery View
struct EnhancedPhotoGalleryView: View {
    @Binding var images: [UIImage]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 15) {
            // Main Photo Display with Better UI
            ZStack {
                TabView(selection: $selectedIndex) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Image(uiImage: images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 320)
                
                // Image counter overlay
                VStack {
                    HStack {
                        Spacer()
                        Text("\(selectedIndex + 1)/\(images.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                            .padding()
                    }
                    Spacer()
                }
            }
            
            // Photo Controls with Enhanced UI
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📸 Multi-angle Analysis Ready")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("AI will analyze all \(images.count) photos for best results")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    deleteCurrentPhoto()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func deleteCurrentPhoto() {
        if images.count > 1 {
            images.remove(at: selectedIndex)
            if selectedIndex >= images.count {
                selectedIndex = images.count - 1
            }
        } else {
            images.removeAll()
            selectedIndex = 0
        }
    }
}

// MARK: - Enhanced Action Buttons
struct EnhancedActionButtonsView: View {
    let hasPhotos: Bool
    let isAnalyzing: Bool
    let photoCount: Int
    let onTakePhotos: () -> Void
    let onAddPhotos: () -> Void
    let onBarcodeScan: () -> Void
    let onAnalyze: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Photo and Barcode Row with Better Styling
            HStack(spacing: 12) {
                // Take Photos Button
                Button(action: onTakePhotos) {
                    VStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        Text("Camera")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                // Add Photos Button
                Button(action: onAddPhotos) {
                    VStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                        Text("Library")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                // Barcode Scanner Button
                Button(action: onBarcodeScan) {
                    VStack(spacing: 4) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                        Text("Scan")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.orange, .orange.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            
            // Analysis Button with Enhanced UI
            if hasPhotos {
                Button(action: onAnalyze) {
                    HStack(spacing: 12) {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.9)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("🚀 ANALYZING...")
                                .fontWeight(.bold)
                        } else {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                            Text("🚀 ANALYZE ITEM (\(photoCount) photos)")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.headline)
                    .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .disabled(isAnalyzing)
                .scaleEffect(isAnalyzing ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isAnalyzing)
                
                // Reset Button with Better Styling
                if !isAnalyzing {
                    Button(action: onReset) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset Analysis")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// MARK: - Enhanced Analysis Result View
struct EnhancedAnalysisResultView: View {
    let analysis: AnalysisResult
    let onAddToInventory: () -> Void
    let onDirectList: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Analysis Header with Better Design
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("✅ ITEM IDENTIFIED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text(analysis.itemName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if !analysis.brand.isEmpty {
                            Text(analysis.brand)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Confidence: \(String(format: "%.0f", analysis.confidence * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Condition: \(String(format: "%.0f", analysis.conditionScore))/100")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("$\(String(format: "%.2f", analysis.realisticPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Realistic Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(analysis.actualCondition)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.05))
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
            
            // Enhanced Pricing Strategy
            PricingStrategyCard(analysis: analysis)
            
            // Enhanced Market Intelligence
            MarketIntelligenceCard(analysis: analysis)
            
            // Enhanced Action Buttons
            VStack(spacing: 12) {
                Button(action: onAddToInventory) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("📦 Add to Inventory")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                Button(action: onDirectList) {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.title2)
                        Text("🚀 Direct List to eBay")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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
                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.02))
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Enhanced Item Form View
struct EnhancedItemFormView: View {
    let analysis: AnalysisResult
    let onSave: (InventoryItem) -> Void
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var purchasePrice: Double = 0.0
    @State private var source = "Thrift Store"
    @State private var notes = ""
    @State private var storageLocation = ""
    @State private var binNumber = ""
    @State private var customTitle = ""
    @State private var customDescription = ""
    @State private var customKeywords = ""
    
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
                        Text("Brand")
                        Spacer()
                        Text(analysis.brand.isEmpty ? "No brand detected" : analysis.brand)
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
                        Spacer()
                        Text("$")
                        TextField("0.00", value: $purchasePrice, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
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
                
                Section("Listing Customization") {
                    TextField("Custom Title", text: $customTitle, axis: .vertical)
                        .lineLimit(2...3)
                    
                    TextField("Custom Description", text: $customDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Additional Keywords", text: $customKeywords)
                }
                
                Section("Additional Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Enhanced Profit Calculation Preview
                if purchasePrice > 0 {
                    Section("💰 Profit Analysis") {
                        let estimatedFees = analysis.feesBreakdown.totalFees
                        let estimatedProfit = analysis.realisticPrice - purchasePrice - estimatedFees
                        let estimatedROI = purchasePrice > 0 ? (estimatedProfit / purchasePrice) * 100 : 0
                        
                        HStack {
                            Text("Purchase Price")
                            Spacer()
                            Text("$\(String(format: "%.2f", purchasePrice))")
                        }
                        
                        HStack {
                            Text("Selling Price")
                            Spacer()
                            Text("$\(String(format: "%.2f", analysis.realisticPrice))")
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Total Fees")
                            Spacer()
                            Text("$\(String(format: "%.2f", estimatedFees))")
                                .foregroundColor(.orange)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Estimated Profit")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$\(String(format: "%.2f", estimatedProfit))")
                                .fontWeight(.bold)
                                .foregroundColor(estimatedProfit > 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Estimated ROI")
                                .fontWeight(.semibold)
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(purchasePrice <= 0)
                    .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            // Pre-populate custom fields with AI analysis
            customTitle = analysis.ebayTitle
            customDescription = analysis.description
            customKeywords = analysis.keywords.joined(separator: ", ")
        }
    }
    
    private func saveItem() {
        // Convert first image to Data
        let imageData = analysis.images.first?.jpegData(compressionQuality: 0.8)
        
        // Convert additional images to Data
        let additionalImageData = analysis.images.dropFirst().compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // Combine original keywords with custom ones
        var allKeywords = analysis.keywords
        if !customKeywords.isEmpty {
            let customKeywordArray = customKeywords.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            allKeywords.append(contentsOf: customKeywordArray)
        }
        
        let item = InventoryItem(
            itemNumber: inventoryManager.nextItemNumber,
            name: analysis.itemName,
            category: analysis.category,
            purchasePrice: purchasePrice,
            suggestedPrice: analysis.realisticPrice,
            source: source,
            condition: analysis.actualCondition,
            title: customTitle.isEmpty ? analysis.ebayTitle : customTitle,
            description: customDescription.isEmpty ? analysis.description : customDescription,
            keywords: allKeywords,
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

// MARK: - Improved Prospecting View
struct ProspectingView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var aiService: AIService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingMultiCamera = false
    @State private var showingPhotoLibrary = false
    @State private var prospectAnalysis: ProspectAnalysis?
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Prospecting Header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🔍 PROSPECTING MODE")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                
                                Text("Instant analysis • Get max buy price • Perfect for sourcing")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Refresh Button
                            Button(action: {
                                refreshAnalysis()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                    .padding(12)
                                    .background(Color.purple.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Analysis Progress for Prospecting
                    if aiService.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView(value: Double(aiService.currentStep), total: Double(aiService.totalSteps))
                                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                            
                            Text(aiService.analysisProgress)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                                .multilineTextAlignment(.center)
                            
                            Text("Prospecting Analysis: Step \(aiService.currentStep)/\(aiService.totalSteps)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Photo Interface
                    if !capturedImages.isEmpty {
                        EnhancedPhotoGalleryView(images: $capturedImages)
                    } else {
                        ProspectingPhotoPlaceholderView {
                            showingMultiCamera = true
                        }
                    }
                    
                    // Prospecting Analysis Methods
                    VStack(spacing: 15) {
                        // Take Photos Button
                        Button(action: {
                            showingMultiCamera = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("📸 Take Photos")
                                        .fontWeight(.bold)
                                    Text("Identify item and get pricing")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .purple.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        
                        // Add from Library Button
                        Button(action: {
                            showingPhotoLibrary = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("🖼️ Add from Library")
                                        .fontWeight(.bold)
                                    Text("Select photos from your library")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
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
                            .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        
                        // Barcode Lookup Button
                        Button(action: {
                            showingBarcodeLookup = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("📱 Barcode Scanner")
                                        .fontWeight(.bold)
                                    Text("Scan for instant identification")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        
                        // Analyze Photos Button
                        if !capturedImages.isEmpty {
                            Button(action: {
                                analyzeForMaxBuyPrice()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.title2)
                                    Text("🔍 ANALYZE ITEM (\(capturedImages.count) photos)")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [.red, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: .red.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .disabled(aiService.isAnalyzing)
                        }
                    }
                    
                    // Analysis Results
                    if let analysis = prospectAnalysis {
                        ImprovedProspectAnalysisResultView(analysis: analysis)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingMultiCamera) {
            CameraView { photos in
                capturedImages.append(contentsOf: photos)
                prospectAnalysis = nil
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryPicker { photos in
                capturedImages.append(contentsOf: photos)
                prospectAnalysis = nil
            }
        }
        .sheet(isPresented: $showingBarcodeLookup) {
            BarcodeScannerView(scannedCode: $scannedBarcode)
                .onDisappear {
                    if let barcode = scannedBarcode {
                        lookupBarcode(barcode)
                    }
                }
        }
    }
    
    private func analyzeForMaxBuyPrice() {
        guard !capturedImages.isEmpty else { return }
        
        print("🔍 Starting REAL Prospecting Analysis with \(capturedImages.count) images")
        
        aiService.analyzeForProspecting(
            images: capturedImages,
            category: "All Categories"
        ) { analysis in
            DispatchQueue.main.async {
                prospectAnalysis = analysis
                print("✅ Prospecting Analysis Complete: \(analysis.recommendation.title) - Max Pay: $\(String(format: "%.2f", analysis.maxBuyPrice))")
            }
        }
    }
    
    private func lookupBarcode(_ barcode: String) {
        print("📱 Looking up barcode for prospecting: \(barcode)")
        
        aiService.lookupBarcodeForProspecting(barcode) { analysis in
            DispatchQueue.main.async {
                prospectAnalysis = analysis
            }
        }
    }
    
    private func refreshAnalysis() {
        capturedImages = []
        prospectAnalysis = nil
        scannedBarcode = nil
        print("🔄 Prospecting analysis refreshed")
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
