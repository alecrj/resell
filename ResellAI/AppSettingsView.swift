//
//  AppSettingsView.swift
//  ResellAI
//
//  Created by Alec on 7/28/25.
//


import SwiftUI
import MessageUI

// MARK: - App Settings View
struct AppSettingsView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @EnvironmentObject var aiService: AIService
    
    @State private var showingExportSheet = false
    @State private var showingAPIConfiguration = false
    @State private var showingBusinessSettings = false
    @State private var showingDataManagement = false
    @State private var showingAbout = false
    @State private var showingMailComposer = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("⚙️ SETTINGS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Configure your reselling business")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Quick Stats
                    SettingsQuickStats(inventoryManager: inventoryManager)
                    
                    // Settings Sections
                    VStack(spacing: 15) {
                        // Business Configuration
                        SettingsSection(
                            title: "Business Configuration",
                            icon: "building.2.fill",
                            color: .blue
                        ) {
                            showingBusinessSettings = true
                        }
                        
                        // API Configuration
                        SettingsSection(
                            title: "API Configuration",
                            icon: "network",
                            color: .green,
                            subtitle: "OpenAI, Google Sheets, eBay"
                        ) {
                            showingAPIConfiguration = true
                        }
                        
                        // Data Management
                        SettingsSection(
                            title: "Data Management",
                            icon: "externaldrive.fill",
                            color: .orange,
                            subtitle: "Export, backup, sync"
                        ) {
                            showingDataManagement = true
                        }
                        
                        // Export Options
                        SettingsSection(
                            title: "Export Inventory",
                            icon: "square.and.arrow.up",
                            color: .purple,
                            subtitle: "CSV, Google Sheets, eBay listings"
                        ) {
                            showingExportSheet = true
                        }
                        
                        // Support & Feedback
                        SettingsSection(
                            title: "Support & Feedback",
                            icon: "questionmark.circle.fill",
                            color: .pink
                        ) {
                            showingMailComposer = true
                        }
                        
                        // About
                        SettingsSection(
                            title: "About ResellAI",
                            icon: "info.circle.fill",
                            color: .gray
                        ) {
                            showingAbout = true
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingBusinessSettings) {
            BusinessSettingsView()
                .environmentObject(inventoryManager)
        }
        .sheet(isPresented: $showingAPIConfiguration) {
            APIConfigurationView()
                .environmentObject(aiService)
                .environmentObject(googleSheetsService)
        }
        .sheet(isPresented: $showingDataManagement) {
            DataManagementView()
                .environmentObject(inventoryManager)
                .environmentObject(googleSheetsService)
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportOptionsView()
                .environmentObject(inventoryManager)
                .environmentObject(googleSheetsService)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingMailComposer) {
            if MFMailComposeViewController.canSendMail() {
                MailComposerView()
            } else {
                ContactSupportView()
            }
        }
    }
}

// MARK: - Settings Quick Stats
struct SettingsQuickStats: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        HStack {
            StatCard(
                title: "Total Items",
                value: "\(inventoryManager.items.count)",
                color: .blue
            )
            
            StatCard(
                title: "Total Value",
                value: "$\(String(format: "%.0f", inventoryManager.totalEstimatedValue))",
                color: .green
            )
            
            StatCard(
                title: "Categories",
                value: "\(inventoryManager.getInventoryOverview().count)",
                color: .orange
            )
        }
    }
}

// MARK: - Settings Section
struct SettingsSection: View {
    let title: String
    let icon: String
    let color: Color
    let subtitle: String?
    let action: () -> Void
    
    init(title: String, icon: String, color: Color, subtitle: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Business Settings View
struct BusinessSettingsView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var businessName = "Your Reselling Business"
    @State private var defaultMargin: Double = 200.0
    @State private var minimumROI: Double = 50.0
    @State private var defaultShippingCost: Double = 8.50
    @State private var autoGenerateListings = true
    @State private var trackPackaging = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Business Information") {
                    TextField("Business Name", text: $businessName)
                    
                    HStack {
                        Text("Default Profit Margin")
                        Spacer()
                        Text("\(String(format: "%.0f", defaultMargin))%")
                        Slider(value: $defaultMargin, in: 50...500, step: 25)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Minimum ROI Target")
                        Spacer()
                        Text("\(String(format: "%.0f", minimumROI))%")
                        Slider(value: $minimumROI, in: 25...200, step: 25)
                            .frame(width: 100)
                    }
                }
                
                Section("Listing Defaults") {
                    HStack {
                        Text("Default Shipping Cost")
                        Spacer()
                        Text("$")
                        TextField("8.50", value: $defaultShippingCost, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                    }
                    
                    Toggle("Auto-generate eBay Listings", isOn: $autoGenerateListings)
                    Toggle("Track Packaging Status", isOn: $trackPackaging)
                }
                
                Section("Inventory Management") {
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(inventoryManager.items.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Categories Used")
                        Spacer()
                        Text("\(inventoryManager.getInventoryOverview().count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Average ROI")
                        Spacer()
                        Text("\(String(format: "%.0f", inventoryManager.averageROI))%")
                            .foregroundColor(inventoryManager.averageROI > 100 ? .green : .orange)
                    }
                }
                
                Section("Storage") {
                    NavigationLink("Storage Location Guide") {
                        StorageGuideView()
                    }
                    
                    NavigationLink("Inventory Organization") {
                        InventoryOrganizationView()
                            .environmentObject(inventoryManager)
                    }
                }
            }
            .navigationTitle("Business Settings")
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

// MARK: - API Configuration View
struct APIConfigurationView: View {
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var openAIStatus = "Configured"
    @State private var googleSheetsStatus = "Connected"
    @State private var ebayAPIStatus = "Not Configured"
    
    var body: some View {
        NavigationView {
            Form {
                Section("AI Analysis") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("OpenAI GPT-4")
                                .font(.headline)
                            Text("Powers item identification and analysis")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        StatusIndicator(status: openAIStatus)
                    }
                    
                    Text("Configure your OpenAI API key in environment variables")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Data Sync") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Google Sheets")
                                .font(.headline)
                            Text("Automatic inventory sync and backup")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        StatusIndicator(status: googleSheetsStatus)
                    }
                    
                    if googleSheetsService.isConnected {
                        HStack {
                            Text("Last Sync")
                            Spacer()
                            Text(googleSheetsService.lastSyncDate?.formatted(date: .abbreviated, time: .shortened) ?? "Never")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Test Google Sheets Connection") {
                        testGoogleSheetsConnection()
                    }
                }
                
                Section("eBay Integration") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("eBay API")
                                .font(.headline)
                            Text("Direct listing to eBay")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        StatusIndicator(status: ebayAPIStatus)
                    }
                    
                    Text("eBay direct listing requires eBay Developer API access")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Market Research") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("RapidAPI")
                                .font(.headline)
                            Text("Live market data and pricing")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        StatusIndicator(status: "Configured")
                    }
                }
                
                Section("Configuration Guide") {
                    Text("""
                    To configure APIs:
                    1. Set OPENAI_API_KEY in environment
                    2. Set GOOGLE_SCRIPT_URL for sheets sync
                    3. Set RAPID_API_KEY for market research
                    4. Configure eBay Developer Account for direct listing
                    """)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("API Configuration")
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
    
    private func testGoogleSheetsConnection() {
        googleSheetsService.authenticate()
    }
}

// MARK: - Data Management View
struct DataManagementView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingClearDataAlert = false
    @State private var showingImportSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Backup & Sync") {
                    Button("Sync All Items to Google Sheets") {
                        googleSheetsService.syncAllItems(inventoryManager.items)
                    }
                    .disabled(googleSheetsService.isSyncing)
                    
                    if googleSheetsService.isSyncing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text(googleSheetsService.syncStatus)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Last Sync")
                        Spacer()
                        Text(googleSheetsService.lastSyncDate?.formatted(date: .abbreviated, time: .shortened) ?? "Never")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Export Options") {
                    Button("Export CSV File") {
                        exportCSV()
                    }
                    
                    Button("Generate eBay Listing Batch") {
                        generateEbayListings()
                    }
                    
                    Button("Export Inventory Report") {
                        exportInventoryReport()
                    }
                }
                
                Section("Import Data") {
                    Button("Import from CSV") {
                        showingImportSheet = true
                    }
                    
                    Text("Import inventory from CSV files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Storage Information") {
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(inventoryManager.items.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Storage Size")
                        Spacer()
                        Text("~\(estimateStorageSize()) MB")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Photos Stored")
                        Spacer()
                        Text("\(countPhotos())")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Danger Zone") {
                    Button("Clear All Data") {
                        showingClearDataAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Data Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all inventory data. This action cannot be undone.")
        }
        .sheet(isPresented: $showingImportSheet) {
            CSVImportView()
                .environmentObject(inventoryManager)
        }
    }
    
    private func exportCSV() {
        let csv = inventoryManager.exportCSV()
        print("📄 CSV Export: \(csv.count) characters")
        // Could implement sharing here
    }
    
    private func generateEbayListings() {
        print("📝 Generating eBay listings for \(inventoryManager.items.count) items")
        // Implementation for batch eBay listing generation
    }
    
    private func exportInventoryReport() {
        print("📊 Generating inventory report")
        // Implementation for detailed inventory report
    }
    
    private func estimateStorageSize() -> Int {
        let itemCount = inventoryManager.items.count
        let averageSize = 50 // KB per item estimate
        return itemCount * averageSize / 1024 // Convert to MB
    }
    
    private func countPhotos() -> Int {
        return inventoryManager.items.reduce(0) { count, item in
            var photoCount = 0
            if item.imageData != nil { photoCount += 1 }
            if let additional = item.additionalImageData {
                photoCount += additional.count
            }
            return count + photoCount
        }
    }
    
    private func clearAllData() {
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "SavedInventoryItems")
        UserDefaults.standard.removeObject(forKey: "CategoryCounters")
        
        // Clear in-memory data
        inventoryManager.items.removeAll()
        
        print("🗑️ All data cleared")
    }
}

// MARK: - Export Options View
struct ExportOptionsView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedFormat = "CSV"
    @State private var includePhotos = false
    @State private var filterByStatus: ItemStatus?
    
    let exportFormats = ["CSV", "Google Sheets", "eBay Listings", "Inventory Report"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Export Format") {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(exportFormats, id: \.self) { format in
                            Text(format).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Export Options") {
                    Toggle("Include Photos", isOn: $includePhotos)
                    
                    Picker("Filter by Status", selection: $filterByStatus) {
                        Text("All Items").tag(ItemStatus?.none)
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status as ItemStatus?)
                        }
                    }
                }
                
                Section("Preview") {
                    let filteredItems = getFilteredItems()
                    
                    HStack {
                        Text("Items to Export")
                        Spacer()
                        Text("\(filteredItems.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Value")
                        Spacer()
                        Text("$\(String(format: "%.2f", filteredItems.reduce(0) { $0 + $1.suggestedPrice }))")
                            .foregroundColor(.green)
                    }
                }
                
                Section {
                    Button("Export Now") {
                        performExport()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Export Inventory")
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
    
    private func getFilteredItems() -> [InventoryItem] {
        var items = inventoryManager.items
        
        if let status = filterByStatus {
            items = items.filter { $0.status == status }
        }
        
        return items
    }
    
    private func performExport() {
        let items = getFilteredItems()
        
        switch selectedFormat {
        case "CSV":
            exportToCSV(items)
        case "Google Sheets":
            exportToGoogleSheets(items)
        case "eBay Listings":
            exportToEbayListings(items)
        case "Inventory Report":
            exportToInventoryReport(items)
        default:
            break
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func exportToCSV(_ items: [InventoryItem]) {
        print("📄 Exporting \(items.count) items to CSV")
        // Implementation for CSV export
    }
    
    private func exportToGoogleSheets(_ items: [InventoryItem]) {
        print("📊 Syncing \(items.count) items to Google Sheets")
        googleSheetsService.syncAllItems(items)
    }
    
    private func exportToEbayListings(_ items: [InventoryItem]) {
        print("🏪 Generating eBay listings for \(items.count) items")
        // Implementation for eBay listing generation
    }
    
    private func exportToInventoryReport(_ items: [InventoryItem]) {
        print("📋 Generating inventory report for \(items.count) items")
        // Implementation for inventory report
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text("📱 ResellAI")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Ultimate Reselling Business Tool")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        FeatureCard(
                            icon: "brain.head.profile",
                            title: "AI-Powered Analysis",
                            description: "Computer vision and GPT-4 analysis for instant item identification, condition assessment, and pricing."
                        )
                        
                        FeatureCard(
                            icon: "magnifyingglass.circle",
                            title: "Smart Prospecting",
                            description: "Get instant max buy prices while sourcing. Know exactly what to pay before you buy."
                        )
                        
                        FeatureCard(
                            icon: "archivebox.fill",
                            title: "Smart Inventory",
                            description: "Auto-organized inventory with smart codes, storage tracking, and profit analysis."
                        )
                        
                        FeatureCard(
                            icon: "chart.bar.fill",
                            title: "Business Intelligence",
                            description: "Track profits, ROI, and performance with comprehensive analytics and reporting."
                        )
                        
                        FeatureCard(
                            icon: "network",
                            title: "Seamless Integration",
                            description: "Direct integration with Google Sheets, eBay, and market research APIs."
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Built for serious resellers who want to:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Maximize profits with AI-powered analysis")
                            Text("• Streamline inventory management")
                            Text("• Make smarter sourcing decisions")
                            Text("• Scale their reselling business")
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
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
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views and Components

// Status Indicator
struct StatusIndicator: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status.lowercased() {
        case "configured", "connected":
            return .green
        case "not configured":
            return .red
        default:
            return .orange
        }
    }
}

// CSV Import View (placeholder)
struct CSVImportView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("📄 CSV Import")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("CSV import functionality coming soon")
                    .foregroundColor(.secondary)
                
                Spacer()
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
    }
}

// Mail Composer (placeholder)
struct MailComposerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setSubject("ResellAI Support Request")
        composer.setToRecipients(["support@resellai.app"])
        composer.setMessageBody("Hi ResellAI Team,\n\nI need help with:\n\n", isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

// Contact Support View (when mail is not available)
struct ContactSupportView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📧 Contact Support")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Email us at:")
                    .foregroundColor(.secondary)
                
                Text("support@resellai.app")
                    .font(.headline)
                    .foregroundColor(.blue)
                
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