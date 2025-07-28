import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Main Content View
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

// MARK: - Business Tab View
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
            
            SmartInventoryListView()
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

// MARK: - AI Analysis View (Business Mode)
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
                    // Header
                    VStack(spacing: 8) {
                        Text("🚀 AI ANALYSIS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Complete inventory analysis • eBay listing generation")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Analysis Progress
                        if aiService.isAnalyzing {
                            VStack(spacing: 8) {
                                ProgressView(value: Double(aiService.currentStep), total: Double(aiService.totalSteps))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                
                                Text(aiService.analysisProgress)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Text("Step \(aiService.currentStep)/\(aiService.totalSteps)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Photo Interface
                    if !capturedImages.isEmpty {
                        PhotoGalleryView(images: $capturedImages)
                    } else {
                        PhotoPlaceholderView {
                            showingMultiCamera = true
                        }
                    }
                    
                    // Action Buttons
                    ActionButtonsView(
                        hasPhotos: !capturedImages.isEmpty,
                        isAnalyzing: aiService.isAnalyzing,
                        photoCount: capturedImages.count,
                        onTakePhotos: { showingMultiCamera = true },
                        onAddPhotos: { showingPhotoLibrary = true },
                        onBarcodeScan: { showingBarcodeLookup = true },
                        onAnalyze: { analyzeWithAI() },
                        onReset: { resetAnalysis() }
                    )
                    
                    // Analysis Results
                    if let result = analysisResult {
                        AnalysisResultView(analysis: result) {
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
                ItemFormView(
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
    
    private func analyzeWithAI() {
        guard !capturedImages.isEmpty else { return }
        
        aiService.analyzeItem(capturedImages) { result in
            DispatchQueue.main.async {
                analysisResult = result
            }
        }
    }
    
    private func analyzeBarcode(_ barcode: String) {
        aiService.analyzeBarcode(barcode, images: capturedImages) { result in
            DispatchQueue.main.async {
                analysisResult = result
            }
        }
    }
    
    private func resetAnalysis() {
        capturedImages = []
        analysisResult = nil
    }
}

// MARK: - Prospecting View
struct ProspectingView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var aiService: AIService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingMultiCamera = false
    @State private var showingPhotoLibrary = false
    @State private var prospectAnalysis: ProspectAnalysis?
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    @State private var selectedCategory = "All Categories"
    
    let categories = ["All Categories", "Electronics", "Gaming", "Clothing", "Collectibles", "Home & Garden", "Sports", "Books", "Toys"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Prospecting Header
                    VStack(spacing: 12) {
                        Text("🔍 PROSPECTING MODE")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Text("Instant analysis • Max buy price • Perfect for sourcing")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Analysis Progress
                    if aiService.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView(value: Double(aiService.currentStep), total: Double(aiService.totalSteps))
                                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                            
                            Text(aiService.analysisProgress)
                                .font(.caption)
                                .foregroundColor(.purple)
                            
                            Text("Prospecting Analysis: Step \(aiService.currentStep)/\(aiService.totalSteps)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Photo Interface
                    if !capturedImages.isEmpty {
                        PhotoGalleryView(images: $capturedImages)
                    } else {
                        ProspectingPhotoPlaceholderView {
                            showingMultiCamera = true
                        }
                    }
                    
                    // Analysis Methods
                    VStack(spacing: 15) {
                        // Take Photos Button
                        Button(action: {
                            showingMultiCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                VStack(alignment: .leading) {
                                    Text("📸 Take Photos")
                                        .fontWeight(.bold)
                                    Text("Take up to 8 photos for analysis")
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
                        }
                        
                        // Add from Library Button
                        Button(action: {
                            showingPhotoLibrary = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
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
                        }
                        
                        // Barcode Lookup Button
                        Button(action: {
                            showingBarcodeLookup = true
                        }) {
                            HStack {
                                Image(systemName: "barcode.viewfinder")
                                VStack(alignment: .leading) {
                                    Text("📱 Barcode Scanner")
                                        .fontWeight(.bold)
                                    Text("Scan UPC/ISBN for instant lookup")
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
                        }
                        
                        // Analyze Photos Button
                        if !capturedImages.isEmpty {
                            Button(action: {
                                analyzeForMaxBuyPrice()
                            }) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                    Text("🔍 GET MAX BUY PRICE (\(capturedImages.count) photos)")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.red, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                            .disabled(aiService.isAnalyzing)
                        }
                    }
                    
                    // Analysis Results
                    if let analysis = prospectAnalysis {
                        ProspectAnalysisResultView(analysis: analysis)
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
        
        aiService.analyzeForProspecting(
            images: capturedImages,
            category: selectedCategory
        ) { analysis in
            DispatchQueue.main.async {
                prospectAnalysis = analysis
            }
        }
    }
    
    private func lookupBarcode(_ barcode: String) {
        aiService.lookupBarcodeForProspecting(barcode) { analysis in
            DispatchQueue.main.async {
                prospectAnalysis = analysis
            }
        }
    }
}

// MARK: - Smart Inventory List View
struct SmartInventoryListView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @State private var searchText = ""
    @State private var filterStatus: ItemStatus?
    @State private var showingFilters = false
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    @State private var selectedItem: InventoryItem?
    @State private var showingAutoListing = false
    
    var filteredItems: [InventoryItem] {
        inventoryManager.items
            .filter { item in
                if let status = filterStatus {
                    return item.status == status
                }
                return true
            }
            .filter { item in
                if searchText.isEmpty {
                    return true
                }
                return item.name.localizedCaseInsensitiveContains(searchText) ||
                       item.source.localizedCaseInsensitiveContains(searchText) ||
                       item.inventoryCode.localizedCaseInsensitiveContains(searchText)
            }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Smart Search Bar with Barcode Scanner
                HStack {
                    SearchBarView(text: $searchText)
                    
                    Button(action: {
                        showingBarcodeLookup = true
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(.trailing, 8)
                    }
                }
                
                List {
                    ForEach(filteredItems) { item in
                        SmartInventoryItemRowView(item: item) { updatedItem in
                            inventoryManager.updateItem(updatedItem)
                            googleSheetsService.updateItem(updatedItem)
                        } onAutoList: { item in
                            selectedItem = item
                            showingAutoListing = true
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Smart Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("All Items") {
                            filterStatus = nil
                        }
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Button(status.rawValue) {
                                filterStatus = status
                            }
                        }
                        Divider()
                        Button("📊 Export to CSV") {
                            exportToCSV()
                        }
                        Button("🔄 Sync to Google Sheets") {
                            googleSheetsService.syncAllItems(inventoryManager.items)
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingBarcodeLookup) {
            BarcodeScannerView(scannedCode: $scannedBarcode)
                .onDisappear {
                    if let barcode = scannedBarcode {
                        lookupItemByBarcode(barcode: barcode)
                    }
                }
        }
        .sheet(isPresented: $showingAutoListing) {
            if let item = selectedItem {
                AutoListingView(item: item)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        inventoryManager.deleteItems(at: offsets, from: filteredItems)
    }
    
    private func exportToCSV() {
        let csv = inventoryManager.exportCSV()
        print("📄 CSV Export generated with smart inventory codes")
    }
    
    private func lookupItemByBarcode(barcode: String) {
        // Find item by barcode or inventory code
        if let item = inventoryManager.findItem(byInventoryCode: barcode) {
            selectedItem = item
            showingAutoListing = true
        } else {
            print("🔍 Item not found with code: \(barcode)")
        }
    }
}

// MARK: - UI Components

// Photo Placeholder
struct PhotoPlaceholderView: View {
    let onTakePhotos: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 300)
            
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Take Multiple Photos")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Take up to 8 photos for item analysis")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    Text("✓ Computer vision analysis")
                    Text("✓ Real-time market research")
                    Text("✓ Realistic pricing")
                    Text("✓ Direct eBay listing")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .onTapGesture {
            onTakePhotos()
        }
    }
}

// Prospecting Photo Placeholder
struct ProspectingPhotoPlaceholderView: View {
    let onTakePhotos: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.1), .pink.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 300)
            
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                VStack(spacing: 8) {
                    Text("Prospecting Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Get instant max buy price for any item")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    Text("✓ Instant item identification")
                    Text("✓ Max buy price calculation")
                    Text("✓ Profit potential analysis")
                    Text("✓ Buy/Avoid recommendation")
                }
                .font(.caption)
                .foregroundColor(.purple)
            }
        }
        .onTapGesture {
            onTakePhotos()
        }
    }
}

// Photo Gallery
struct PhotoGalleryView: View {
    @Binding var images: [UIImage]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Photo Display
            TabView(selection: $selectedIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 320)
            
            // Photo Controls
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📸 \(selectedIndex + 1) of \(images.count) photos")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Multi-angle analysis ready")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    deleteCurrentPhoto()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
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

// Action Buttons
struct ActionButtonsView: View {
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
            // Photo and Barcode Row
            HStack(spacing: 10) {
                // Take Photos Button
                Button(action: onTakePhotos) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("📷 Camera")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                
                // Add Photos Button
                Button(action: onAddPhotos) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("🖼️ Library")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                
                // Barcode Scanner Button
                Button(action: onBarcodeScan) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("📱 Barcode")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
            }
            
            // Analysis Button
            if hasPhotos {
                Button(action: onAnalyze) {
                    HStack {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("🚀 Analyzing...")
                        } else {
                            Image(systemName: "brain.head.profile")
                            Text("🚀 ITEM ANALYSIS (\(photoCount) photos)")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
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
                    .shadow(radius: 5)
                }
                .disabled(isAnalyzing)
                
                // Reset Button
                if !isAnalyzing {
                    Button(action: onReset) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset Analysis")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// Search Bar
struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search by name, code, or source...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

// Smart Inventory Item Row
struct SmartInventoryItemRowView: View {
    let item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    let onAutoList: (InventoryItem) -> Void
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Smart Inventory Code Display
                Text(item.inventoryCode.isEmpty ? "No Code" : item.inventoryCode)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(item.inventoryCode.isEmpty ? .red : .blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.inventoryCode.isEmpty ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Text("\(item.source) • $\(String(format: "%.2f", item.purchasePrice))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !item.storageLocation.isEmpty {
                        Text("📍 \(item.storageLocation)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                if item.profit > 0 {
                    Text("Profit: $\(String(format: "%.2f", item.profit)) (\(String(format: "%.1f", item.roi))%)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(12)
                
                // Auto-List Button
                Button(action: {
                    onAutoList(item)
                }) {
                    Image(systemName: "wand.and.stars")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text("#\(item.itemNumber)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            ItemDetailView(item: item, onUpdate: onUpdate)
        }
    }
}

// Settings View
struct AppSettingsView: View {
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @EnvironmentObject var ebayListingService: EbayListingService
    
    var body: some View {
        NavigationView {
            Form {
                Section("🚀 AI Analysis") {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("AI Analysis Engine")
                                .fontWeight(.semibold)
                            Text("Ultra-accurate • Real market data • Computer vision")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Section("🚀 Direct eBay Listing") {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("One-Tap eBay Listing")
                                .fontWeight(.semibold)
                            Text(ebayListingService.isListing ? "Listing in progress..." : "Ready to list")
                                .font(.caption)
                                .foregroundColor(ebayListingService.isListing ? .orange : .green)
                        }
                        Spacer()
                        if ebayListingService.isListing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                Section("📊 Google Sheets") {
                    HStack {
                        Image(systemName: "tablecells")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Auto-Sync Inventory")
                                .fontWeight(.semibold)
                            Text(googleSheetsService.syncStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if googleSheetsService.isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                Section("🔥 Features") {
                    FeatureStatusRowView(icon: "camera.fill", title: "Multi-Photo Analysis", enabled: true)
                    FeatureStatusRowView(icon: "eye.fill", title: "Computer Vision", enabled: true)
                    FeatureStatusRowView(icon: "chart.line.uptrend.xyaxis", title: "Real-Time Market Research", enabled: true)
                    FeatureStatusRowView(icon: "brain", title: "AI Pricing", enabled: true)
                    FeatureStatusRowView(icon: "bolt.fill", title: "Direct eBay Listing", enabled: true)
                    FeatureStatusRowView(icon: "magnifyingglass.circle", title: "Prospecting Mode", enabled: true)
                    FeatureStatusRowView(icon: "barcode.viewfinder", title: "Barcode Scanner", enabled: true)
                    FeatureStatusRowView(icon: "archivebox.fill", title: "Smart Inventory Codes", enabled: true)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct FeatureStatusRowView: View {
    let icon: String
    let title: String
    let enabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
            Spacer()
            Image(systemName: enabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(enabled ? .green : .red)
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
