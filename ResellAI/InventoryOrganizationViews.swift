import SwiftUI
import PhotosUI

// MARK: - Smart Inventory Organization Views

// MARK: - Main Inventory Organization View
struct InventoryOrganizationView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @State private var selectedCategory: String?
    @State private var showingStorageGuide = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("📦 SMART INVENTORY")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Auto-organized • Easy to find • Ready to ship")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Quick Stats
                    InventoryQuickStats(inventoryManager: inventoryManager)
                    
                    // Category Organization Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(inventoryManager.getInventoryOverview(), id: \.letter) { overview in
                            CategoryCard(
                                letter: overview.letter,
                                category: overview.category,
                                itemCount: overview.count,
                                items: overview.items
                            ) {
                                selectedCategory = overview.letter
                            }
                        }
                    }
                    
                    // Storage Management Actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📦 STORAGE MANAGEMENT")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 15) {
                            ActionButton(
                                title: "📚 Storage Guide",
                                description: "How to organize items",
                                color: .green
                            ) {
                                showingStorageGuide = true
                            }
                            
                            ActionButton(
                                title: "📋 Ready to Ship",
                                description: "\(inventoryManager.getPackagedItems().count) items",
                                color: .orange
                            ) {
                                // Show packaged items
                            }
                        }
                        
                        HStack(spacing: 15) {
                            ActionButton(
                                title: "🏷️ Missing Photos",
                                description: "\(inventoryManager.getItemsNeedingPhotos().count) items",
                                color: .red
                            ) {
                                // Show items needing photos
                            }
                            
                            ActionButton(
                                title: "🚀 Ready to List",
                                description: "\(inventoryManager.getItemsReadyToList().count) items",
                                color: .blue
                            ) {
                                // Show items ready to list
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingStorageGuide) {
            StorageGuideView()
        }
        .sheet(item: Binding<CategorySelection?>(
            get: {
                guard let category = selectedCategory else { return nil }
                return CategorySelection(letter: category)
            },
            set: { _ in selectedCategory = nil }
        )) { selection in
            CategoryDetailView(categoryLetter: selection.letter)
                .environmentObject(inventoryManager)
        }
    }
}

// Helper struct for sheet presentation
struct CategorySelection: Identifiable {
    let id = UUID()
    let letter: String
}

// MARK: - Inventory Quick Stats
struct InventoryQuickStats: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        HStack {
            StatCard(
                title: "Total Items",
                value: "\(inventoryManager.items.count)",
                color: .blue
            )
            
            StatCard(
                title: "Categories",
                value: "\(inventoryManager.getInventoryOverview().count)",
                color: .green
            )
            
            StatCard(
                title: "Ready to Ship",
                value: "\(inventoryManager.getPackagedItems().count)",
                color: .orange
            )
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let letter: String
    let category: String
    let itemCount: Int
    let items: [InventoryItem]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Category Letter Badge
                ZStack {
                    Circle()
                        .fill(getColorForLetter(letter))
                        .frame(width: 50, height: 50)
                    
                    Text(letter)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(category)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text("\(itemCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Recent items preview
                if !items.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(items.prefix(3), id: \.id) { item in
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20)
                                    .cornerRadius(4)
                            } else {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        if items.count > 3 {
                            Text("+\(items.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.05))
                    .stroke(getColorForLetter(letter).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getColorForLetter(_ letter: String) -> Color {
        switch letter {
        case "A": return .red
        case "B": return .orange
        case "C": return .blue
        case "D": return .green
        case "E": return .purple
        case "F": return .pink
        case "G": return .mint
        case "H": return .cyan
        case "I": return .indigo
        case "J": return .brown
        case "K": return .yellow
        case "L": return .teal
        case "M": return .primary
        default: return .gray
        }
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let categoryLetter: String
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingStorageUpdate = false
    @State private var selectedItems: Set<UUID> = []
    
    var categoryItems: [InventoryItem] {
        inventoryManager.getItemsByInventoryLetter(categoryLetter)
    }
    
    var categoryInfo: InventoryCategory? {
        InventoryCategory.allCases.first { $0.inventoryLetter == categoryLetter }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Category Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(getColorForLetter(categoryLetter))
                            .frame(width: 80, height: 80)
                        
                        Text(categoryLetter)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text(categoryInfo?.rawValue ?? "Unknown Category")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(categoryItems.count) items")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Storage Tips
                if let category = categoryInfo {
                    StorageTipsCard(category: category)
                }
                
                // Items List
                List {
                    ForEach(categoryItems) { item in
                        CategoryItemRow(item: item) { updatedItem in
                            inventoryManager.updateItem(updatedItem)
                        }
                    }
                }
                
                // Bulk Actions
                if !selectedItems.isEmpty {
                    HStack(spacing: 15) {
                        Button("📦 Mark as Packaged") {
                            // Bulk package items
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Button("📍 Update Storage") {
                            showingStorageUpdate = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Category \(categoryLetter)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingStorageUpdate) {
            StorageUpdateView(categoryLetter: categoryLetter, selectedItems: selectedItems)
                .environmentObject(inventoryManager)
        }
    }
    
    private func getColorForLetter(_ letter: String) -> Color {
        switch letter {
        case "A": return .red
        case "B": return .orange
        case "C": return .blue
        case "D": return .green
        case "E": return .purple
        case "F": return .pink
        case "G": return .mint
        case "H": return .cyan
        case "I": return .indigo
        case "J": return .brown
        case "K": return .yellow
        case "L": return .teal
        case "M": return .primary
        default: return .gray
        }
    }
}

// MARK: - Storage Tips Card
struct StorageTipsCard: View {
    let category: InventoryCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📦 Storage Tips")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(category.storageTips, id: \.self) { tip in
                HStack {
                    Text("•")
                        .foregroundColor(.blue)
                    Text(tip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Category Item Row
struct CategoryItemRow: View {
    let item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            // Item Image
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Item Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.inventoryCode)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(item.condition)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    if item.isPackaged {
                        Text("📦 Packaged")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    if !item.storageLocation.isEmpty {
                        Text("📍 \(item.storageLocation)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Status and Price
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.0f", item.suggestedPrice))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(8)
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

// MARK: - Storage Guide View
struct StorageGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("📚 SMART STORAGE GUIDE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Maximize organization and protect your inventory")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(InventoryCategory.allCases, id: \.self) { category in
                        CategoryStorageGuide(category: category)
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

// MARK: - Category Storage Guide
struct CategoryStorageGuide: View {
    let category: InventoryCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(getColorForCategory(category))
                        .frame(width: 40, height: 40)
                    
                    Text(category.inventoryLetter)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text(category.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            ForEach(category.storageTips, id: \.self) { tip in
                HStack(alignment: .top) {
                    Text("•")
                        .foregroundColor(getColorForCategory(category))
                        .fontWeight(.bold)
                    Text(tip)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(getColorForCategory(category).opacity(0.1))
        .cornerRadius(12)
    }
    
    private func getColorForCategory(_ category: InventoryCategory) -> Color {
        switch category.inventoryLetter {
        case "A": return .red
        case "B": return .orange
        case "C": return .blue
        case "D": return .green
        case "E": return .purple
        case "F": return .pink
        case "G": return .mint
        case "H": return .cyan
        case "I": return .indigo
        case "J": return .brown
        case "K": return .yellow
        case "L": return .teal
        case "M": return .primary
        default: return .gray
        }
    }
}

// MARK: - Storage Update View
struct StorageUpdateView: View {
    let categoryLetter: String
    let selectedItems: Set<UUID>
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    @State private var storageLocation = ""
    @State private var binNumber = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Update Storage Location") {
                    TextField("Storage Location (e.g., Closet A, Shelf 2)", text: $storageLocation)
                    TextField("Bin Number (optional)", text: $binNumber)
                }
                
                Section("Selected Items") {
                    Text("\(selectedItems.count) items selected")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Update Storage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        updateStorage()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(storageLocation.isEmpty)
                }
            }
        }
    }
    
    private func updateStorage() {
        for itemId in selectedItems {
            if let item = inventoryManager.items.first(where: { $0.id == itemId }) {
                inventoryManager.updateStorageLocation(
                    for: item,
                    location: storageLocation,
                    binNumber: binNumber
                )
            }
        }
    }
}

// MARK: - Supporting Components
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct ActionButton: View {
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - Smart Inventory List View with Editing
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
    @State private var showingItemEditor = false
    @State private var itemToEdit: InventoryItem?
    
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
                       item.inventoryCode.localizedCaseInsensitiveContains(searchText) ||
                       item.brand.localizedCaseInsensitiveContains(searchText)
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
                
                // Filter Status Bar
                if filteredItems.count != inventoryManager.items.count || filterStatus != nil {
                    HStack {
                        if let status = filterStatus {
                            Text("Filtered by: \(status.rawValue)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Text("Showing \(filteredItems.count) of \(inventoryManager.items.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if filterStatus != nil {
                            Button("Clear Filter") {
                                filterStatus = nil
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                }
                
                List {
                    ForEach(filteredItems) { item in
                        InventoryItemRowView(item: item) { updatedItem in
                            inventoryManager.updateItem(updatedItem)
                            googleSheetsService.updateItem(updatedItem)
                        } onAutoList: { item in
                            selectedItem = item
                            showingAutoListing = true
                        } onEdit: { item in
                            itemToEdit = item
                            showingItemEditor = true
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Smart Inventory (\(filteredItems.count))")
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
        .sheet(isPresented: $showingItemEditor) {
            if let item = itemToEdit {
                InventoryItemEditorView(item: item) { updatedItem in
                    inventoryManager.updateItem(updatedItem)
                    googleSheetsService.updateItem(updatedItem)
                    showingItemEditor = false
                    itemToEdit = nil
                }
                .environmentObject(inventoryManager)
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

// MARK: - Inventory Item Row with Edit Button
struct InventoryItemRowView: View {
    let item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    let onAutoList: (InventoryItem) -> Void
    let onEdit: (InventoryItem) -> Void
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            // Item Image
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 65, height: 65)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 65, height: 65)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                // Smart Inventory Code Display
                HStack {
                    Text(item.inventoryCode.isEmpty ? "No Code" : item.inventoryCode)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(item.inventoryCode.isEmpty ? .red : .blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.inventoryCode.isEmpty ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Item Number
                    Text("#\(item.itemNumber)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Item Name and Brand
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if !item.brand.isEmpty {
                        Text(item.brand)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                // Purchase Info and Storage
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
                
                // Profit Display
                if item.estimatedProfit > 0 {
                    HStack {
                        Text("Est. Profit: $\(String(format: "%.2f", item.estimatedProfit))")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("(\(String(format: "%.0f", item.estimatedROI))% ROI)")
                            .font(.caption)
                            .foregroundColor(item.estimatedROI > 100 ? .green : item.estimatedROI > 50 ? .orange : .red)
                    }
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(alignment: .trailing, spacing: 8) {
                // Status Badge
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(12)
                
                // Suggested Price
                Text("$\(String(format: "%.2f", item.suggestedPrice))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                // Action Buttons Row
                HStack(spacing: 8) {
                    // Edit Button
                    Button(action: {
                        onEdit(item)
                    }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    // Auto-List Button
                    Button(action: {
                        onAutoList(item)
                    }) {
                        Image(systemName: "wand.and.stars")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
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

// MARK: - Complete Inventory Item Editor
struct InventoryItemEditorView: View {
    @State var item: InventoryItem
    let onSave: (InventoryItem) -> Void
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    // Edit states
    @State private var editingImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var editingName = ""
    @State private var editingBrand = ""
    @State private var editingTitle = ""
    @State private var editingDescription = ""
    @State private var editingKeywords = ""
    @State private var editingCondition = ""
    @State private var editingSize = ""
    @State private var editingColorway = ""
    @State private var editingPurchasePrice: Double = 0
    @State private var editingSuggestedPrice: Double = 0
    @State private var editingSource = ""
    @State private var editingStorageLocation = ""
    @State private var editingBinNumber = ""
    @State private var editingStatus: ItemStatus = .analyzed
    @State private var editingNotes = ""
    
    let sources = ["Thrift Store", "Goodwill Bins", "Estate Sale", "Yard Sale", "Facebook Marketplace", "OfferUp", "Auction", "Other"]
    let conditions = ["Like New", "Excellent", "Very Good", "Good", "Fair", "Poor"]
    
    var body: some View {
        NavigationView {
            Form {
                // Photos Section
                Section("📸 Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // Existing photos
                            ForEach(0..<editingImages.count, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: editingImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                    
                                    Button(action: {
                                        editingImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.white, in: Circle())
                                    }
                                    .offset(x: 5, y: -5)
                                }
                            }
                            
                            // Add Photo Buttons
                            Button(action: {
                                showingCamera = true
                            }) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                    Text("Camera")
                                        .font(.caption)
                                }
                                .frame(width: 80, height: 80)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                VStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Library")
                                        .font(.caption)
                                }
                                .frame(width: 80, height: 80)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("\(editingImages.count)/8 photos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Basic Information
                Section("📋 Basic Information") {
                    HStack {
                        Text("Inventory Code")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(item.inventoryCode.isEmpty ? "Auto-assigned" : item.inventoryCode)
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    
                    TextField("Item Name", text: $editingName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Brand", text: $editingBrand)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Condition", selection: $editingCondition) {
                        ForEach(conditions, id: \.self) { condition in
                            Text(condition).tag(condition)
                        }
                    }
                    
                    HStack {
                        Text("Size")
                        TextField("Size", text: $editingSize)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Colorway")
                        TextField("Color/Style", text: $editingColorway)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // Pricing Information
                Section("💰 Pricing") {
                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        Text("$")
                        TextField("0.00", value: $editingPurchasePrice, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Suggested Price")
                        Spacer()
                        Text("$")
                        TextField("0.00", value: $editingSuggestedPrice, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    // Profit Calculation
                    if editingPurchasePrice > 0 && editingSuggestedPrice > 0 {
                        let estimatedFees = editingSuggestedPrice * 0.1325 + 8.50 + 0.30
                        let estimatedProfit = editingSuggestedPrice - editingPurchasePrice - estimatedFees
                        let estimatedROI = (estimatedProfit / editingPurchasePrice) * 100
                        
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
                
                // Source and Status
                Section("📦 Source & Status") {
                    Picker("Source", selection: $editingSource) {
                        ForEach(sources, id: \.self) { source in
                            Text(source).tag(source)
                        }
                    }
                    
                    Picker("Status", selection: $editingStatus) {
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                // Storage Location
                Section("📍 Storage") {
                    TextField("Storage Location", text: $editingStorageLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Bin Number", text: $editingBinNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("Packaged for Shipping", isOn: Binding(
                        get: { item.isPackaged },
                        set: { item.isPackaged = $0 }
                    ))
                }
                
                // Listing Information
                Section("🏷️ Listing Details") {
                    TextField("eBay Title", text: $editingTitle, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...3)
                    
                    TextField("Description", text: $editingDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(4...8)
                    
                    TextField("Keywords (comma separated)", text: $editingKeywords, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                // Notes
                Section("📝 Notes") {
                    TextField("Additional Notes", text: $editingNotes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            loadItemData()
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { photos in
                editingImages.append(contentsOf: photos)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoLibraryPicker { photos in
                editingImages.append(contentsOf: photos)
            }
        }
    }
    
    private func loadItemData() {
        // Load existing data into editing states
        editingName = item.name
        editingBrand = item.brand
        editingTitle = item.title
        editingDescription = item.description
        editingKeywords = item.keywords.joined(separator: ", ")
        editingCondition = item.condition
        editingSize = item.size
        editingColorway = item.colorway
        editingPurchasePrice = item.purchasePrice
        editingSuggestedPrice = item.suggestedPrice
        editingSource = item.source
        editingStorageLocation = item.storageLocation
        editingBinNumber = item.binNumber
        editingStatus = item.status
        editingNotes = item.marketNotes ?? ""
        
        // Load existing images
        if let imageData = item.imageData, let image = UIImage(data: imageData) {
            editingImages.append(image)
        }
        
        if let additionalImageData = item.additionalImageData {
            for data in additionalImageData {
                if let image = UIImage(data: data) {
                    editingImages.append(image)
                }
            }
        }
    }
    
    private func saveChanges() {
        // Convert images to data
        let imageData = editingImages.first?.jpegData(compressionQuality: 0.8)
        let additionalImageData = editingImages.dropFirst().compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // Create updated item
        var updatedItem = item
        updatedItem.name = editingName
        updatedItem.brand = editingBrand
        updatedItem.title = editingTitle
        updatedItem.description = editingDescription
        updatedItem.keywords = editingKeywords.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        updatedItem.condition = editingCondition
        updatedItem.size = editingSize
        updatedItem.colorway = editingColorway
        updatedItem.purchasePrice = editingPurchasePrice
        updatedItem.suggestedPrice = editingSuggestedPrice
        updatedItem.source = editingSource
        updatedItem.storageLocation = editingStorageLocation
        updatedItem.binNumber = editingBinNumber
        updatedItem.status = editingStatus
        updatedItem.marketNotes = editingNotes
        updatedItem.imageData = imageData
        updatedItem.additionalImageData = additionalImageData.isEmpty ? nil : additionalImageData
        
        onSave(updatedItem)
    }
}

// MARK: - Item Detail View with Photo Gallery
struct ItemDetailView: View {
    @State var item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditor = false
    @State private var currentImageIndex = 0
    
    var allImages: [UIImage] {
        var images: [UIImage] = []
        
        if let imageData = item.imageData, let image = UIImage(data: imageData) {
            images.append(image)
        }
        
        if let additionalImageData = item.additionalImageData {
            for data in additionalImageData {
                if let image = UIImage(data: data) {
                    images.append(image)
                }
            }
        }
        
        return images
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Gallery
                    if !allImages.isEmpty {
                        VStack(spacing: 10) {
                            TabView(selection: $currentImageIndex) {
                                ForEach(0..<allImages.count, id: \.self) { index in
                                    Image(uiImage: allImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 300)
                                        .cornerRadius(12)
                                        .shadow(radius: 5)
                                        .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                            .frame(height: 320)
                            
                            Text("Image \(currentImageIndex + 1) of \(allImages.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Item Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.inventoryCode)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                                
                                Text(item.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if !item.brand.isEmpty {
                                    Text(item.brand)
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(String(format: "%.2f", item.suggestedPrice))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text(item.status.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(item.status.color.opacity(0.2))
                                    .foregroundColor(item.status.color)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Details Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        
                        DetailCard(title: "Condition", value: item.condition, icon: "checkmark.seal", color: .green)
                        DetailCard(title: "Category", value: item.category, icon: "tag", color: .blue)
                        DetailCard(title: "Source", value: item.source, icon: "location", color: .orange)
                        DetailCard(title: "Purchase Price", value: "$\(String(format: "%.2f", item.purchasePrice))", icon: "dollarsign.circle", color: .red)
                        
                        if !item.size.isEmpty {
                            DetailCard(title: "Size", value: item.size, icon: "ruler", color: .purple)
                        }
                        
                        if !item.colorway.isEmpty {
                            DetailCard(title: "Colorway", value: item.colorway, icon: "paintpalette", color: .pink)
                        }
                        
                        if !item.storageLocation.isEmpty {
                            DetailCard(title: "Storage", value: item.storageLocation, icon: "archivebox", color: .brown)
                        }
                        
                        if item.estimatedProfit > 0 {
                            DetailCard(title: "Est. Profit", value: "$\(String(format: "%.2f", item.estimatedProfit))", icon: "chart.line.uptrend.xyaxis", color: .green)
                        }
                    }
                    
                    // Description
                    if !item.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(item.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Keywords
                    if !item.keywords.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Keywords")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 80))
                            ], spacing: 8) {
                                ForEach(item.keywords, id: \.self) { keyword in
                                    Text(keyword)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingEditor = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Item")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                markAsPackaged()
                            }) {
                                HStack {
                                    Image(systemName: item.isPackaged ? "checkmark" : "shippingbox")
                                    Text(item.isPackaged ? "Packaged" : "Mark Packaged")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(item.isPackaged ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                updateStatus()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.circle")
                                    Text("Next Status")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            InventoryItemEditorView(item: item, onSave: onUpdate)
        }
    }
    
    private func markAsPackaged() {
        item.isPackaged.toggle()
        if item.isPackaged {
            item.packagedDate = Date()
        } else {
            item.packagedDate = nil
        }
        onUpdate(item)
    }
    
    private func updateStatus() {
        let allCases = ItemStatus.allCases
        if let currentIndex = allCases.firstIndex(of: item.status) {
            let nextIndex = (currentIndex + 1) % allCases.count
            item.status = allCases[nextIndex]
            onUpdate(item)
        }
    }
}

// MARK: - Detail Card Component
struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Search Bar View
struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search by name, code, brand, or source...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}
