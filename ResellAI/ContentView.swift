import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Main Content View with Clean UI
struct ContentView: View {
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var aiService = AIService()
    @StateObject private var googleSheetsService = GoogleSheetsService()
    @StateObject private var ebayListingService = EbayListingService()
    
    @State private var isProspectingMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Clean Mode Toggle
            CleanModeToggle(isProspectingMode: $isProspectingMode)
            
            // Main Content
            if isProspectingMode {
                ProspectingView()
                    .environmentObject(inventoryManager)
                    .environmentObject(aiService)
            } else {
                BusinessTabView()
                    .environmentObject(inventoryManager)
                    .environmentObject(aiService)
                    .environmentObject(googleSheetsService)
                    .environmentObject(ebayListingService)
            }
        }
        .onAppear {
            initializeServices()
        }
    }
    
    private func initializeServices() {
        googleSheetsService.authenticate()
        print("🚀 ResellAI Ready")
    }
}

// MARK: - Clean Mode Toggle
struct CleanModeToggle: View {
    @Binding var isProspectingMode: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Simple App Title
            HStack {
                Text("ResellAI")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // API Status Indicator
                Circle()
                    .fill(isAPIConfigured ? .green : .red)
                    .frame(width: 8, height: 8)
            }
            
            // Clean Mode Selector
            HStack(spacing: 0) {
                ModeButton(
                    title: "Business",
                    icon: "building.2",
                    isSelected: !isProspectingMode
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isProspectingMode = false
                    }
                }
                
                ModeButton(
                    title: "Prospect",
                    icon: "magnifyingglass",
                    isSelected: isProspectingMode
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isProspectingMode = true
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var isAPIConfigured: Bool {
        !APIConfig.openAIKey.isEmpty
    }
}

struct ModeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.blue : Color.clear
            )
            .cornerRadius(8)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Clean Business Tab View
struct BusinessTabView: View {
    var body: some View {
        TabView {
            CleanAnalysisView()
                .tabItem {
                    Image(systemName: "viewfinder")
                    Text("Analyze")
                }
            
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Dashboard")
                }
            
            SmartInventoryListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Inventory")
                }
            
            InventoryOrganizationView()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("Storage")
                }
            
            AppSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Clean Analysis View
struct CleanAnalysisView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @EnvironmentObject var ebayListingService: EbayListingService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var analysisResult: AnalysisResult?
    @State private var showingItemForm = false
    @State private var showingDirectListing = false
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Clean Header
                    VStack(spacing: 12) {
                        Text("Item Analysis")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if !isAPIConfigured {
                            Text("Configure API keys for analysis")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        // Clean Progress Indicator
                        if aiService.isAnalyzing {
                            VStack(spacing: 8) {
                                ProgressView(value: Double(aiService.currentStep), total: Double(aiService.totalSteps))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                
                                Text(aiService.analysisProgress)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Button("Cancel") {
                                    resetAnalysis()
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Photo Section
                    if !capturedImages.isEmpty {
                        CleanPhotoGallery(images: $capturedImages)
                    } else {
                        CleanPhotoPlaceholder {
                            showingCamera = true
                        }
                    }
                    
                    // Action Buttons
                    CleanActionButtons(
                        hasPhotos: !capturedImages.isEmpty,
                        isAnalyzing: aiService.isAnalyzing,
                        isAPIConfigured: isAPIConfigured,
                        onCamera: { showingCamera = true },
                        onLibrary: { showingPhotoLibrary = true },
                        onBarcode: { showingBarcodeLookup = true },
                        onAnalyze: { analyzeItem() },
                        onReset: { resetAnalysis() }
                    )
                    
                    // Results
                    if let result = analysisResult {
                        CleanAnalysisResult(analysis: result) {
                            showingItemForm = true
                        } onDirectList: {
                            showingDirectListing = true
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { photos in
                appendImages(photos)
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryPicker { photos in
                appendImages(photos)
            }
        }
        .sheet(isPresented: $showingItemForm) {
            if let result = analysisResult {
                ItemFormView(analysis: result, onSave: saveItem)
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
    
    private var isAPIConfigured: Bool {
        !APIConfig.openAIKey.isEmpty
    }
    
    // MARK: - Performance Optimized Methods
    private func appendImages(_ photos: [UIImage]) {
        // Optimize images for performance
        let optimizedPhotos = photos.compactMap { image -> UIImage? in
            return optimizeImage(image)
        }
        capturedImages.append(contentsOf: optimizedPhotos)
        analysisResult = nil
    }
    
    private func optimizeImage(_ image: UIImage) -> UIImage? {
        let maxSize: CGFloat = 1024
        let size = image.size
        
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let optimizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return optimizedImage
    }
    
    private func analyzeItem() {
        guard !capturedImages.isEmpty else { return }
        
        aiService.analyzeItem(capturedImages) { result in
            DispatchQueue.main.async {
                self.analysisResult = result
            }
        }
    }
    
    private func analyzeBarcode(_ barcode: String) {
        aiService.analyzeBarcode(barcode, images: capturedImages) { result in
            DispatchQueue.main.async {
                self.analysisResult = result
            }
        }
    }
    
    private func saveItem(_ item: InventoryItem) {
        let savedItem = inventoryManager.addItem(item)
        googleSheetsService.uploadItem(savedItem)
        showingItemForm = false
        resetAnalysis()
    }
    
    private func resetAnalysis() {
        capturedImages = []
        analysisResult = nil
        scannedBarcode = nil
    }
}

// MARK: - Clean Photo Gallery
struct CleanPhotoGallery: View {
    @Binding var images: [UIImage]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Photo
            TabView(selection: $selectedIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 320)
            
            // Simple Controls
            HStack {
                Text("\(images.count) photos ready")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Delete") {
                    deleteCurrentPhoto()
                }
                .font(.caption)
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }
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

// MARK: - Clean Photo Placeholder
struct CleanPhotoPlaceholder: View {
    let onTakePhotos: () -> Void
    
    var body: some View {
        Button(action: onTakePhotos) {
            VStack(spacing: 20) {
                Image(systemName: "camera")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Take Photos")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Multiple photos for better analysis")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Clean Action Buttons
struct CleanActionButtons: View {
    let hasPhotos: Bool
    let isAnalyzing: Bool
    let isAPIConfigured: Bool
    let onCamera: () -> Void
    let onLibrary: () -> Void
    let onBarcode: () -> Void
    let onAnalyze: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Photo Actions
            HStack(spacing: 12) {
                ActionButton(icon: "camera", title: "Camera", color: .blue, action: onCamera)
                ActionButton(icon: "photo", title: "Library", color: .green, action: onLibrary)
                ActionButton(icon: "barcode", title: "Scan", color: .orange, action: onBarcode)
            }
            
            // Analyze Button
            if hasPhotos {
                Button(action: onAnalyze) {
                    HStack {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Analyzing...")
                        } else {
                            Image(systemName: "brain")
                            Text("Analyze Items")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAPIConfigured ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                .disabled(isAnalyzing || !isAPIConfigured)
                
                // Reset Button
                if !isAnalyzing {
                    Button("Reset", action: onReset)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(8)
        }
    }
}

// MARK: - Clean Analysis Result
struct CleanAnalysisResult: View {
    let analysis: AnalysisResult
    let onAddToInventory: () -> Void
    let onDirectList: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Result Header
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(analysis.itemName)
                            .font(.title2)
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
                        
                        Text("\(String(format: "%.0f", analysis.confidence.overall * 100))% confident")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Quick Stats
                HStack {
                    StatChip(label: "Condition", value: analysis.actualCondition, color: .blue)
                    StatChip(label: "Sales", value: "\(analysis.soldListings.count)", color: .purple)
                    StatChip(label: "Market", value: analysis.demandLevel, color: .orange)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // Pricing Strategy
            CleanPricingStrategy(analysis: analysis)
            
            // Action Buttons
            VStack(spacing: 8) {
                Button(action: onAddToInventory) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to Inventory")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: onDirectList) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Create Listing")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct StatChip: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Clean Pricing Strategy
struct CleanPricingStrategy: View {
    let analysis: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pricing Strategy")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                PriceCard(
                    title: "Quick Sale",
                    price: analysis.quickSalePrice,
                    color: .orange
                )
                
                PriceCard(
                    title: "Recommended",
                    price: analysis.realisticPrice,
                    color: .blue,
                    isRecommended: true
                )
                
                PriceCard(
                    title: "Max Profit",
                    price: analysis.maxProfitPrice,
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct PriceCard: View {
    let title: String
    let price: Double
    let color: Color
    let isRecommended: Bool
    
    init(title: String, price: Double, color: Color, isRecommended: Bool = false) {
        self.title = title
        self.price = price
        self.color = color
        self.isRecommended = isRecommended
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isRecommended ? .white : color)
            
            Text("$\(String(format: "%.0f", price))")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isRecommended ? .white : color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isRecommended ? color : color.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: isRecommended ? 0 : 1)
        )
    }
}

// MARK: - Clean Prospecting View
struct ProspectingView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var aiService: AIService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var prospectAnalysis: ProspectAnalysis?
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Simple Header
                    VStack(spacing: 12) {
                        Text("Prospecting")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Get max buy prices instantly")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if aiService.isAnalyzing {
                            ProgressView(value: Double(aiService.currentStep), total: Double(aiService.totalSteps))
                                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                            
                            Text(aiService.analysisProgress)
                                .font(.subheadline)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // Photo Interface
                    if !capturedImages.isEmpty {
                        CleanPhotoGallery(images: $capturedImages)
                    } else {
                        ProspectPhotoPlaceholder {
                            showingCamera = true
                        }
                    }
                    
                    // Prospect Actions
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ActionButton(icon: "camera", title: "Camera", color: .purple, action: { showingCamera = true })
                            ActionButton(icon: "photo", title: "Library", color: .green, action: { showingPhotoLibrary = true })
                            ActionButton(icon: "barcode", title: "Scan", color: .orange, action: { showingBarcodeLookup = true })
                        }
                        
                        if !capturedImages.isEmpty {
                            Button(action: analyzeForProspecting) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("Get Max Buy Price")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.headline)
                            }
                            .disabled(aiService.isAnalyzing || APIConfig.openAIKey.isEmpty)
                        }
                    }
                    
                    // Results
                    if let analysis = prospectAnalysis {
                        CleanProspectResult(analysis: analysis)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { photos in
                let optimized = photos.compactMap { optimizeImage($0) }
                capturedImages.append(contentsOf: optimized)
                prospectAnalysis = nil
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryPicker { photos in
                let optimized = photos.compactMap { optimizeImage($0) }
                capturedImages.append(contentsOf: optimized)
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
    
    private func optimizeImage(_ image: UIImage) -> UIImage? {
        let maxSize: CGFloat = 1024
        let size = image.size
        
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let optimizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return optimizedImage
    }
    
    private func analyzeForProspecting() {
        guard !capturedImages.isEmpty else { return }
        
        aiService.analyzeForProspecting(images: capturedImages, category: "All") { analysis in
            DispatchQueue.main.async {
                self.prospectAnalysis = analysis
            }
        }
    }
    
    private func lookupBarcode(_ barcode: String) {
        aiService.lookupBarcodeForProspecting(barcode) { analysis in
            DispatchQueue.main.async {
                self.prospectAnalysis = analysis
            }
        }
    }
}

struct ProspectPhotoPlaceholder: View {
    let onTakePhotos: () -> Void
    
    var body: some View {
        Button(action: onTakePhotos) {
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                
                VStack(spacing: 8) {
                    Text("Prospect Items")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Get instant max buy prices")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Clean Prospect Result
struct CleanProspectResult: View {
    let analysis: ProspectAnalysis
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(analysis.itemName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if !analysis.brand.isEmpty {
                            Text(analysis.brand)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(analysis.recommendation.emoji)
                            .font(.title)
                        Text(analysis.recommendation.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(analysis.recommendation.color)
                    }
                }
            }
            
            // Max Buy Price Strategy
            VStack(alignment: .leading, spacing: 12) {
                Text("Pricing Strategy")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    PriceCard(
                        title: "Max Pay",
                        price: analysis.maxBuyPrice,
                        color: .red,
                        isRecommended: true
                    )
                    
                    PriceCard(
                        title: "Target",
                        price: analysis.targetBuyPrice,
                        color: .orange
                    )
                    
                    PriceCard(
                        title: "Sell For",
                        price: analysis.estimatedSellPrice,
                        color: .green
                    )
                }
                
                // Profit Display
                if analysis.potentialProfit > 0 {
                    HStack {
                        Text("Potential Profit:")
                        Spacer()
                        Text("$\(String(format: "%.2f", analysis.potentialProfit))")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("(\(String(format: "%.0f", analysis.expectedROI))% ROI)")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // Market Intelligence
            if !analysis.recentSales.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Sales")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(analysis.recentSales.prefix(3), id: \.title) { sale in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sale.title)
                                    .font(.caption)
                                    .lineLimit(1)
                                Text(sale.condition)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.0f", sale.price))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
