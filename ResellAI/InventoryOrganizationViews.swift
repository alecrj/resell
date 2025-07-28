import SwiftUI

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

// MARK: - Item Detail View (Simple version for inventory management)
struct ItemDetailView: View {
    @State var item: InventoryItem
    let onUpdate: (InventoryItem) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    HStack {
                        Text("Inventory Code")
                        Spacer()
                        Text(item.inventoryCode)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(item.name)
                    }
                    
                    HStack {
                        Text("Category")
                        Spacer()
                        Text(item.category)
                    }
                    
                    HStack {
                        Text("Condition")
                        Spacer()
                        Text(item.condition)
                    }
                }
                
                Section("Storage") {
                    TextField("Storage Location", text: $item.storageLocation)
                    TextField("Bin Number", text: $item.binNumber)
                    
                    Toggle("Packaged for Shipping", isOn: $item.isPackaged)
                }
                
                Section("Status") {
                    Picker("Status", selection: $item.status) {
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onUpdate(item)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
