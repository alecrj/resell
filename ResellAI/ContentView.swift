import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Main Content View with Real AI Integration
struct ContentView: View {
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var aiService = AIService() // Now uses RealAIAnalysisService internally
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
                // Prospecting Mode with Real AI
                ProspectingView()
                    .environmentObject(inventoryManager)
                    .environmentObject(aiService)
            } else {
                // Business Mode with Real AI
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
        
        // Log initialization status
        print("🚀 ResellAI Initialized with REAL AI Analysis")
        print("📊 AI Service Ready: \(aiService.isAnalyzing ? "Analyzing" : "Ready")")
        print("🔗 Google Sheets: \(googleSheetsService.isConnected ? "Connected" : "Disconnected")")
    }
}

// MARK: - Mode Toggle View (Enhanced)
struct ModeToggleView: View {
    @Binding var isProspectingMode: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // App Title with AI Badge
            HStack {
                Text("ResellAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("AI")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .cornerRadius(4)
            }
            
            // Mode Toggle with Enhanced Design
            HStack(spacing: 0) {
                // Business Mode Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isProspectingMode = false
                    }
                }) {
                    HStack {
                        Image(systemName: "building.2.fill")
                        Text("Business Mode")
                    }
                    .font(.headline)
                    .foregroundColor(isProspectingMode ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        isProspectingMode ?
                        AnyShapeStyle(Color.gray.opacity(0.2)) :
                        AnyShapeStyle(LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                    )

                    .animation(.easeInOut(duration: 0.2), value: isProspectingMode)
                }
                
                // Prospecting Mode Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isProspectingMode = true
                    }
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Prospecting")
                    }
                    .font(.headline)
                    .foregroundColor(isProspectingMode ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        isProspectingMode ?
                        AnyShapeStyle(LinearGradient(colors: [.purple, .purple.opacity(0.8)], startPoint: .top, endPoint: .bottom)) :
                        AnyShapeStyle(Color.gray.opacity(0.2))
                    )

                    .animation(.easeInOut(duration: 0.2), value: isProspectingMode)
                }
            }
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Mode Description with Real AI Features
            Text(isProspectingMode ?
                 "🔍 Real-time item identification • AI condition analysis • Accurate max buy prices" :
                 "📦 Complete business management • Real market research • Professional eBay listings")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - Business Tab View (Enhanced)
struct BusinessTabView: View {
    var body: some View {
        TabView {
            RealAIAnalysisView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("🚀 AI Analysis")
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

// MARK: - Real AI Analysis View (Updated)
struct RealAIAnalysisView: View {
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
    @State private var showingAPIStatus = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Real AI Status
                    VStack(spacing: 8) {
                        HStack {
                            Text("ITEM ANALYSIS")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            // API Status Button
                            Button(action: {
                                showingAPIStatus = true
                            }) {
                                Image(systemName: isAPIConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundColor(isAPIConfigured ? .green : .red)
                            }
                        }
                        
                        Text(" Real time market research • Professional analysis")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // API Configuration Status
                        if !isAPIConfigured {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Configure API keys for real analysis")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
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
                                
                                HStack {
                                    Text("Step \(aiService.currentStep)/\(aiService.totalSteps)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("Real AI Processing...")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                
                                // Cancel button for long-running analysis
                                Button("Cancel Analysis") {
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
                        RealPhotoGalleryView(images: $capturedImages)
                    } else {
                        RealPhotoPlaceholderView {
                            showingMultiCamera = true
                        }
                    }
                    
                    // Enhanced Action Buttons
                    RealActionButtonsView(
                        hasPhotos: !capturedImages.isEmpty,
                        isAnalyzing: aiService.isAnalyzing,
                        photoCount: capturedImages.count,
                        isAPIConfigured: isAPIConfigured,
                        onTakePhotos: { showingMultiCamera = true },
                        onAddPhotos: { showingPhotoLibrary = true },
                        onBarcodeScan: { showingBarcodeLookup = true },
                        onAnalyze: { analyzeWithRealAI() },
                        onReset: { resetAnalysis() }
                    )
                    
                    // Analysis Results with Real Data Indicators
                    if let result = analysisResult {
                        RealAnalysisResultView(analysis: result) {
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
        .sheet(isPresented: $showingAPIStatus) {
            APIStatusView()
        }
    }
    
    private var isAPIConfigured: Bool {
        !APIConfig.openAIKey.isEmpty
    }
    
    private func analyzeWithRealAI() {
        guard !capturedImages.isEmpty else { return }
        
        print("🚀 Starting Analysis with \(capturedImages.count) images")
        
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

// MARK: - Real Photo Gallery View (Enhanced)
struct RealPhotoGalleryView: View {
    @Binding var images: [UIImage]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 15) {
            // Main Photo Display with Real AI Indicators
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
                
                // Enhanced image counter overlay with AI badge
                VStack {
                    HStack {
                        Spacer()
                        HStack {
                            Text("\(selectedIndex + 1)/\(images.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("AI")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.white)
                                .cornerRadius(3)
                        }
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
            
            // Enhanced Photo Controls
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🧠 Analysis Ready")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Resell AI will analyze all \(images.count) photos for maximum accuracy")
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

// MARK: - Real Photo Placeholder View
struct RealPhotoPlaceholderView: View {
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
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                )
            
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("AI")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(6)
                }
                
                VStack(spacing: 8) {
                    Text("Photo Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Take multiple photos for complete GPT-4 Vision analysis")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    Text("✓ Real AI Analysis")
                    Text("✓ Live Market Research & Pricing")
                    Text("✓ Accurate Condition Assessment")
                    Text("✓ Professional eBay Listing Generation")
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

// MARK: - Real Action Buttons (Enhanced)
struct RealActionButtonsView: View {
    let hasPhotos: Bool
    let isAnalyzing: Bool
    let photoCount: Int
    let isAPIConfigured: Bool
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
            
            // Real AI Analysis Button
            if hasPhotos {
                Button(action: onAnalyze) {
                    HStack(spacing: 12) {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.9)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("🧠 ANALYZING...")
                                .fontWeight(.bold)
                        } else {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("🧠 ANALYZE WITH RESELL AI")
                                    .fontWeight(.bold)
                                Text("\(photoCount) photos • Live market data")
                                    .font(.caption)
                                    .opacity(0.9)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: isAPIConfigured ? [.purple, .pink] : [.gray, .gray.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.headline)
                    .shadow(color: isAPIConfigured ? .purple.opacity(0.4) : .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isAnalyzing || !isAPIConfigured)
                .scaleEffect(isAnalyzing ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isAnalyzing)
                
                // API Configuration Warning
                if !isAPIConfigured {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Configure OpenAI API key to enable real analysis")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
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

// MARK: - Real Analysis Result View
struct RealAnalysisResultView: View {
    let analysis: AnalysisResult
    let onAddToInventory: () -> Void
    let onDirectList: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Real AI Analysis Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(analysis.itemName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("AI")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.green)
                                .cornerRadius(3)
                        }
                        
                        if !analysis.brand.isEmpty {
                            Text(analysis.brand)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("AI Confidence: \(String(format: "%.0f", analysis.confidence * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if analysis.confidence > 0.8 {
                                Text("HIGH")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(3)
                            }
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
                
                // Real Condition and Score
                HStack {
                    VStack(alignment: .leading) {
                        Text("AI Condition Analysis")
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
                        Text("Market Data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(analysis.recentSoldPrices.count) sales")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            
            // Use existing components for the rest
            PricingStrategyCard(analysis: analysis)
            MarketIntelligenceCard(analysis: analysis)
            
            // Enhanced Action Buttons
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
                        Text("🚀 Generate Professional Listing")
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
}

// MARK: - API Status View
struct APIStatusView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🔧 API Status")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    APIStatusRow(
                        title: "OpenAI GPT-4 Vision",
                        isConfigured: !APIConfig.openAIKey.isEmpty,
                        description: "Required for real item analysis"
                    )
                    
                    APIStatusRow(
                        title: "RapidAPI Market Research",
                        isConfigured: !APIConfig.rapidAPIKey.isEmpty,
                        description: "Required for live market data"
                    )
                    
                    APIStatusRow(
                        title: "Google Sheets Sync",
                        isConfigured: !APIConfig.googleAppsScriptURL.isEmpty,
                        description: "Optional for data backup"
                    )
                }
                
                Text("Configure these APIs in your app's environment variables for full functionality.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct APIStatusRow: View {
    let title: String
    let isConfigured: Bool
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: isConfigured ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isConfigured ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(isConfigured ? "Configured" : "Missing")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isConfigured ? .green : .red)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Enhanced Prospecting View
struct ProspectingView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var aiService: AIService
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingMultiCamera = false
    @State private var showingPhotoLibrary = false
    @State private var prospectAnalysis: ProspectAnalysis?
    @State private var showingBarcodeLookup = false
    @State private var scannedBarcode: String?
    @State private var showingAPIStatus = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Enhanced Prospecting Header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("🔍 REAL AI PROSPECTING")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.purple)
                                    
                                    Text("AI")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.green)
                                        .cornerRadius(4)
                                }
                                
                                Text("Real-time analysis • Accurate max buy prices • Perfect for sourcing")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // API Status Button
                            Button(action: {
                                showingAPIStatus = true
                            }) {
                                Image(systemName: !APIConfig.openAIKey.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundColor(!APIConfig.openAIKey.isEmpty ? .green : .red)
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
                            
                            Text("Real AI Prospecting: Step \(aiService.currentStep)/\(aiService.totalSteps)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Photo Interface
                    if !capturedImages.isEmpty {
                        RealPhotoGalleryView(images: $capturedImages)
                    } else {
                        ProspectingPhotoPlaceholderView {
                            showingMultiCamera = true
                        }
                    }
                    
                    // Enhanced Prospecting Analysis Methods
                    VStack(spacing: 15) {
                        // Take Photos Button
                        Button(action: {
                            showingMultiCamera = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("📸 Real AI Photo Analysis")
                                        .fontWeight(.bold)
                                    Text("GPT-4 Vision identifies items and calculates max buy price")
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
                                    Text("🖼️ Analyze Existing Photos")
                                        .fontWeight(.bold)
                                    Text("Select photos from your library for AI analysis")
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
                                    Text("📱 Real Barcode Lookup")
                                        .fontWeight(.bold)
                                    Text("Scan for instant product identification and pricing")
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
                                    VStack(alignment: .leading) {
                                        Text("🔍 ANALYZE WITH REAL AI")
                                            .fontWeight(.bold)
                                        Text("\(capturedImages.count) photos • Live market data • Accurate pricing")
                                            .font(.caption)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: !APIConfig.openAIKey.isEmpty ? [.red, .pink] : [.gray, .gray.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: !APIConfig.openAIKey.isEmpty ? .red.opacity(0.4) : .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(aiService.isAnalyzing || APIConfig.openAIKey.isEmpty)
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
        .sheet(isPresented: $showingAPIStatus) {
            APIStatusView()
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
                print("✅ REAL Prospecting Complete: \(analysis.recommendation.title) - Max Pay: $\(String(format: "%.2f", analysis.maxBuyPrice))")
            }
        }
    }
    
    private func lookupBarcode(_ barcode: String) {
        print("📱 Looking up barcode with Real AI: \(barcode)")
        
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
        print("🔄 Real AI Prospecting refreshed")
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
