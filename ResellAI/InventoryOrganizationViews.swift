import SwiftUI
import PhotosUI

// MARK: - Clean Inventory Organization Views

// MARK: - Main Clean Inventory Organization View
struct InventoryOrganizationView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @State private var selectedCategory: String?
    @State private var showingStorageGuide = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Clean Header
                    VStack(spacing: 8) {
                        Text("Storage Organization")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Smart inventory management")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Quick Storage Stats
                    CleanStorageStats(inventoryManager: inventoryManager)
                    
                    // Category Grid
                    CleanCategoryGrid(
                        inventoryManager: inventoryManager,
                        onCategorySelected: { selectedCategory = $0 }
                    )
                    
                    // Storage Actions
                    CleanStorageActions(onStorageGuide: { showingStorageGuide = true })
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

// MARK: - Clean Storage Stats
struct CleanStorageStats: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        HStack {
            StorageStat(
                title: "Total Items",
                value: "\(inventoryManager.items.count)",
                color: .blue
            )
            
            StorageStat(
                title: "Categories",
                value: "\(inventoryManager.getInventoryOverview().count)",
                color: .green
            )
            
            StorageStat(
                title: "Packaged",
                value: "\(inventoryManager.getPackagedItems().count)",
                color: .orange
            )
        }
    }
}

struct StorageStat: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
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
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Clean Category Grid
struct CleanCategoryGrid: View {
    let inventoryManager: InventoryManager
    let onCategorySelected: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(inventoryManager.getInventoryOverview(), id: \.letter) { overview in
                    CleanCategoryCard(
                        letter: overview.letter,
                        category: overview.category,
                        itemCount: overview.count,
                        items: overview.items
                    ) {
                        onCategorySelected(overview.letter)
                    }
                }
            }
        }
    }
}

// MARK: - Clean Category Card
struct CleanCategoryCard: View {
    let letter: String
    let category: String
    let itemCount: Int
    let items: [InventoryItem]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                // Category Letter
                ZStack {
                    Circle()
                        .fill(getColorForLetter(letter))
                        .frame(width: 40, height: 40)
                    
                    Text(letter)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(category)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text("\(itemCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Item Preview
                if !items.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(items.prefix(3), id: \.id) { item in
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 16, height: 16)
                                    .cornerRadius(3)
                            } else {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 16, height: 16)
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
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
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

// MARK: - Clean Storage Actions
struct CleanStorageActions: View {
    let onStorageGuide: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Storage Management")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                StorageActionButton(
                    title: "Storage Guide",
                    subtitle: "How to organize",
                    color: .green,
                    icon: "book",
                    action: onStorageGuide
                )
                
                StorageActionButton(
                    title: "Coming Soon",
                    subtitle: "More features",
                    color: .gray,
                    icon: "plus",
                    action: {}
                )
            }
        }
    }
}

struct StorageActionButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                    Spacer()
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
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
                            .frame(width: 60, height: 60)
                        
                        Text(categoryLetter)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text(categoryInfo?.rawValue ?? "Unknown Category")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(categoryItems.count) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Storage Tips
                if let category = categoryInfo {
                    CleanStorageTipsCard(category: category)
                }
                
                // Items List
                List {
                    ForEach(categoryItems) { item in
                        CleanCategoryItemRow(item: item) { updatedItem in
                            inventoryManager.updateItem(updatedItem)
                        }
                    }
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

// MARK: - Clean Storage Tips Card
struct CleanStorageTipsCard: View {
    let category: InventoryCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Storage Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(category.storageTips.prefix(3), id: \.self) { tip in
                HStack(alignment: .top) {
                    Text("•")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                    Text(tip)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Clean Category Item Row
struct CleanCategoryItemRow: View {
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
                    .fill(Color.gray.opacity(0.2))
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
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack {
                    Text(item.condition)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(3)
                    
                    if item.isPackaged {
                        Text("Packaged")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    if !item.storageLocation.isEmpty {
                        Text(item.storageLocation)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Price and Status
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.0f", item.suggestedPrice))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(item.status.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.status.color.opacity(0.1))
                    .foregroundColor(item.status.color)
                    .cornerRadius(6)
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

// MARK: - Clean Storage Guide View
struct StorageGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Storage Guide")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Organize your inventory for maximum efficiency")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(InventoryCategory.allCases.prefix(6), id: \.self) { category in
                        CleanCategoryStorageGuide(category: category)
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
    }
}

// MARK: - Clean Category Storage Guide
struct CleanCategoryStorageGuide: View {
    let category: InventoryCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(getColorForCategory(category))
                        .frame(width: 30, height: 30)
                    
                    Text(category.inventoryLetter)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text(category.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            ForEach(category.storageTips.prefix(3), id: \.self) { tip in
                HStack(alignment: .top) {
                    Text("•")
                        .foregroundColor(getColorForCategory(category))
                        .fontWeight(.bold)
                    Text(tip)
                        .font(.subheadline)
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

// MARK: - Clean Smart Inventory List View
struct SmartInventoryListView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var googleSheetsService: GoogleSheetsService
    @State private var searchText = ""
    @State private var filterStatus: ItemStatus?
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
                // Clean Search Bar
                HStack {
                    CleanSearchBar(text: $searchText)
                    
                    Button(action: {
                        showingBarcodeLookup = true
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Filter Bar
                if filteredItems.count != inventoryManager.items.count || filterStatus != nil {
                    HStack {
                        if let status = filterStatus {
                            Text("Filter: \(status.rawValue)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Text("\(filteredItems.count) of \(inventoryManager.items.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if filterStatus != nil {
                            Button("Clear") {
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
                
                // Items List
                List {
                    ForEach(filteredItems) { item in
                        CleanInventoryItemRow(item: item) { updatedItem in
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
            .navigationTitle("Inventory (\(filteredItems.count))")
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
                        Button("Export CSV") {
                            exportToCSV()
                        }
                        Button("Sync Sheets") {
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
        print("CSV Export generated")
    }
    
    private func lookupItemByBarcode(barcode: String) {
        if let item = inventoryManager.findItem(byInventoryCode: barcode) {
            selectedItem = item
            showingAutoListing = true
        }
    }
}

// MARK: - Clean Search Bar
struct CleanSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search items...", text: $text)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Clean Inventory Item Row
struct CleanInventoryItemRow: View {
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
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Item Details
            VStack(alignment: .leading, spacing: 4) {
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
                    
                    Text("#\(item.itemNumber)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    if !item.brand.isEmpty {
                        Text(item.brand)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                HStack {
                    Text("\(item.source) • $\(String(format: "%.0f", item.purchasePrice))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !item.storageLocation.isEmpty {
                        Text(item.storageLocation)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Price and Actions
            VStack(alignment: .trailing, spacing: 6) {
                Text(item.status.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.status.color.opacity(0.1))
                    .foregroundColor(item.status.color)
                    .cornerRadius(8)
                
                Text("$\(String(format: "%.0f", item.suggestedPrice))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                HStack(spacing: 6) {
                    Button(action: {
                        onEdit(item)
                    }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Button(action: {
                        onAutoList(item)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
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

// MARK: - Item Detail View (Simplified)
struct ItemDetailView: View {
    @State var item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditor = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Item Preview
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                }
                
                // Item Info
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
                            Text("$\(String(format: "%.0f", item.suggestedPrice))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text(item.status.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(item.status.color.opacity(0.1))
                                .foregroundColor(item.status.color)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Actions
                VStack(spacing: 12) {
                    Button("Edit Item") {
                        showingEditor = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    HStack(spacing: 12) {
                        Button(item.isPackaged ? "Packaged" : "Mark Packaged") {
                            markAsPackaged()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(item.isPackaged ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Update Status") {
                            updateStatus()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
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

// MARK: - Inventory Item Editor (Simplified)
struct InventoryItemEditorView: View {
    @State var item: InventoryItem
    let onSave: (InventoryItem) -> Void
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $item.name)
                    TextField("Brand", text: $item.brand)
                    TextField("Size", text: $item.size)
                    TextField("Color", text: $item.colorway)
                }
                
                Section("Pricing") {
                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        TextField("0.00", value: $item.purchasePrice, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Suggested Price")
                        Spacer()
                        TextField("0.00", value: $item.suggestedPrice, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Storage") {
                    TextField("Storage Location", text: $item.storageLocation)
                    TextField("Bin Number", text: $item.binNumber)
                    Toggle("Packaged", isOn: $item.isPackaged)
                }
                
                Section("Status") {
                    Picker("Status", selection: $item.status) {
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
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
                        onSave(item)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
