import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Main Content View with Business Features
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

// MARK: - AI Analysis View
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
                        onAnalyze: { analyzeWithRealAI() },
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

// MARK: - Photo Gallery View
struct PhotoGalleryView: View {
    @Binding var images: [UIImage]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 15) {
            // Main Photo Display
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
            
            // Photo Controls
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

// MARK: - Action Buttons
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
            
            // Analysis Button
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
                
                // Reset Button
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
                        PhotoGalleryView(images: $capturedImages)
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
