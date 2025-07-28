//
//  InventoryManager.swift
//  ResellAI
//
//  Smart Inventory Management System
//

import SwiftUI
import Foundation

// MARK: - Smart Inventory Manager with Auto-Coding System
class InventoryManager: ObservableObject {
    @Published var items: [InventoryItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let itemsKey = "SavedInventoryItems"
    private let migrationKey = "DataMigrationV2_Completed"
    private let categoryCountersKey = "CategoryCounters"
    
    // Smart inventory tracking
    @Published var categoryCounters: [String: Int] = [:]
    
    init() {
        performDataMigrationIfNeeded()
        loadCategoryCounters()
        loadItems()
    }
    
    // MARK: - Smart Inventory Code Generation
    
    /// Generates smart inventory code based on category (e.g., "A-001", "B-023")
    func generateInventoryCode(for category: String) -> String {
        let inventoryCategory = mapCategoryToInventoryCategory(category)
        let letter = inventoryCategory.inventoryLetter
        
        // Get current counter for this letter
        let currentCount = categoryCounters[letter] ?? 0
        let nextNumber = currentCount + 1
        
        // Update counter
        categoryCounters[letter] = nextNumber
        saveCategoryCounters()
        
        // Format as "A-001", "B-023", etc.
        return "\(letter)-\(String(format: "%03d", nextNumber))"
    }
    
    /// Maps general category string to our smart InventoryCategory enum
    private func mapCategoryToInventoryCategory(_ category: String) -> InventoryCategory {
        let lowercased = category.lowercased()
        
        // Smart category mapping based on keywords
        if lowercased.contains("shirt") || lowercased.contains("tee") || lowercased.contains("tank") {
            return .tshirts
        } else if lowercased.contains("jacket") || lowercased.contains("coat") || lowercased.contains("hoodie") || lowercased.contains("sweatshirt") {
            return .jackets
        } else if lowercased.contains("jean") || lowercased.contains("denim") {
            return .jeans
        } else if lowercased.contains("work") && lowercased.contains("pant") {
            return .workPants
        } else if lowercased.contains("dress") || lowercased.contains("gown") {
            return .dresses
        } else if lowercased.contains("shoe") || lowercased.contains("sneaker") || lowercased.contains("boot") || lowercased.contains("sandal") {
            return .shoes
        } else if lowercased.contains("accessory") || lowercased.contains("jewelry") || lowercased.contains("watch") || lowercased.contains("bag") || lowercased.contains("belt") {
            return .accessories
        } else if lowercased.contains("electronic") || lowercased.contains("computer") || lowercased.contains("phone") || lowercased.contains("gaming") {
            return .electronics
        } else if lowercased.contains("collectible") || lowercased.contains("vintage") || lowercased.contains("antique") {
            return .collectibles
        } else if lowercased.contains("home") || lowercased.contains("garden") || lowercased.contains("furniture") {
            return .home
        } else if lowercased.contains("book") || lowercased.contains("novel") || lowercased.contains("magazine") {
            return .books
        } else if lowercased.contains("toy") || lowercased.contains("game") || lowercased.contains("puzzle") {
            return .toys
        } else if lowercased.contains("sport") || lowercased.contains("fitness") || lowercased.contains("outdoor") {
            return .sports
        } else {
            return .other
        }
    }
    
    /// Get storage recommendations for a category
    func getStorageRecommendations(for category: String) -> [String] {
        let inventoryCategory = mapCategoryToInventoryCategory(category)
        return inventoryCategory.storageTips
    }
    
    /// Get all items by inventory letter (for organization)
    func getItemsByInventoryLetter(_ letter: String) -> [InventoryItem] {
        return items.filter { $0.inventoryCode.hasPrefix(letter) }
            .sorted { $0.inventoryCode < $1.inventoryCode }
    }
    
    /// Get inventory overview by category
    func getInventoryOverview() -> [(letter: String, category: String, count: Int, items: [InventoryItem])] {
        var overview: [(letter: String, category: String, count: Int, items: [InventoryItem])] = []
        
        for inventoryCategory in InventoryCategory.allCases {
            let letter = inventoryCategory.inventoryLetter
            let categoryItems = getItemsByInventoryLetter(letter)
            
            if !categoryItems.isEmpty || (categoryCounters[letter] ?? 0) > 0 {
                overview.append((
                    letter: letter,
                    category: inventoryCategory.rawValue,
                    count: categoryItems.count,
                    items: categoryItems
                ))
            }
        }
        
        return overview.sorted { $0.letter < $1.letter }
    }
    
    // MARK: - Data Persistence for Category Counters
    private func saveCategoryCounters() {
        do {
            let data = try JSONEncoder().encode(categoryCounters)
            userDefaults.set(data, forKey: categoryCountersKey)
        } catch {
            print("❌ Error saving category counters: \(error)")
        }
    }
    
    private func loadCategoryCounters() {
        guard let data = userDefaults.data(forKey: categoryCountersKey) else {
            print("📱 No saved category counters - starting fresh")
            return
        }
        
        do {
            categoryCounters = try JSONDecoder().decode([String: Int].self, from: data)
            print("📂 Loaded category counters: \(categoryCounters)")
        } catch {
            print("❌ Error loading category counters: \(error)")
            categoryCounters = [:]
        }
    }
    
    // MARK: - Data Migration
    private func performDataMigrationIfNeeded() {
        guard !userDefaults.bool(forKey: migrationKey) else {
            print("✅ Data migration already completed")
            return
        }
        
        print("🔄 Performing data migration...")
        
        // Clear old corrupted data
        userDefaults.removeObject(forKey: itemsKey)
        
        // Mark migration as completed
        userDefaults.set(true, forKey: migrationKey)
        
        print("✅ Data migration completed - fresh start!")
    }
    
    // MARK: - Computed Properties
    var nextItemNumber: Int {
        (items.map { $0.itemNumber }.max() ?? 0) + 1
    }
    
    var itemsToList: Int {
        items.filter { $0.status == .toList }.count
    }
    
    var listedItems: Int {
        items.filter { $0.status == .listed }.count
    }
    
    var soldItems: Int {
        items.filter { $0.status == .sold }.count
    }
    
    var totalInvestment: Double {
        items.reduce(0) { $0 + $1.purchasePrice }
    }
    
    var totalProfit: Double {
        items.filter { $0.status == .sold }.reduce(0) { $0 + $1.profit }
    }
    
    var totalEstimatedValue: Double {
        items.reduce(0) { $0 + $1.suggestedPrice }
    }
    
    var averageROI: Double {
        let soldItems = items.filter { $0.status == .sold && $0.roi > 0 }
        guard !soldItems.isEmpty else { return 0 }
        return soldItems.reduce(0) { $0 + $1.roi } / Double(soldItems.count)
    }
    
    var recentItems: [InventoryItem] {
        items.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    // MARK: - CRUD Operations with Smart Coding
    func addItem(_ item: InventoryItem) -> InventoryItem {
        var updatedItem = item
        
        // Auto-generate inventory code if not already set
        if updatedItem.inventoryCode.isEmpty {
            updatedItem.inventoryCode = generateInventoryCode(for: item.category)
            print("🏷️ Generated inventory code: \(updatedItem.inventoryCode)")
        }
        
        items.append(updatedItem)
        saveItems()
        print("✅ Added item: \(updatedItem.name) [\(updatedItem.inventoryCode)]")
        
        return updatedItem
    }
    
    func updateItem(_ updatedItem: InventoryItem) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
            saveItems()
            print("✅ Updated item: \(updatedItem.name) [\(updatedItem.inventoryCode)]")
        }
    }
    
    func deleteItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
        print("🗑️ Deleted item: \(item.name) [\(item.inventoryCode)]")
    }
    
    func deleteItems(at offsets: IndexSet, from filteredItems: [InventoryItem]) {
        for offset in offsets {
            let itemToDelete = filteredItems[offset]
            deleteItem(itemToDelete)
        }
    }
    
    // MARK: - Data Persistence with Error Handling
    private func saveItems() {
        do {
            let data = try JSONEncoder().encode(items)
            userDefaults.set(data, forKey: itemsKey)
            print("💾 Saved \(items.count) items to UserDefaults")
        } catch {
            print("❌ Error saving items: \(error)")
        }
    }
    
    private func loadItems() {
        guard let data = userDefaults.data(forKey: itemsKey) else {
            print("📱 No saved items found - starting fresh")
            return
        }
        
        do {
            items = try JSONDecoder().decode([InventoryItem].self, from: data)
            print("📂 Loaded \(items.count) items from UserDefaults")
            
            // Rebuild category counters from existing items
            rebuildCategoryCounters()
        } catch {
            print("❌ Error loading items: \(error)")
            print("🔄 Clearing corrupted data and starting fresh")
            userDefaults.removeObject(forKey: itemsKey)
            items = []
        }
    }
    
    /// Rebuilds category counters from existing inventory codes
    private func rebuildCategoryCounters() {
        var maxCounters: [String: Int] = [:]
        
        for item in items {
            if !item.inventoryCode.isEmpty {
                let components = item.inventoryCode.split(separator: "-")
                if components.count == 2,
                   let letter = components.first,
                   let number = Int(components.last!) {
                    let letterStr = String(letter)
                    maxCounters[letterStr] = max(maxCounters[letterStr] ?? 0, number)
                }
            }
        }
        
        // Update category counters to be higher than existing items
        for (letter, maxNumber) in maxCounters {
            categoryCounters[letter] = maxNumber
        }
        
        saveCategoryCounters()
        print("🔄 Rebuilt category counters: \(categoryCounters)")
    }
    
    // MARK: - Export Functions
    func exportCSV() -> String {
        var csv = "Item#,InventoryCode,Name,Source,Cost,Suggested$,Status,Profit,ROI%,Date,Title,Description,Keywords,Condition,Category,Brand,Size,Barcode,StorageLocation\n"
        
        for item in items {
            let row = [
                "\(item.itemNumber)",
                csvEscape(item.inventoryCode),
                csvEscape(item.name),
                csvEscape(item.source),
                "\(item.purchasePrice)",
                "\(item.suggestedPrice)",
                csvEscape(item.status.rawValue),
                "\(item.estimatedProfit)",
                "\(item.estimatedROI)",
                formatDate(item.dateAdded),
                csvEscape(item.title),
                csvEscape(item.description),
                csvEscape(item.keywords.joined(separator: "; ")),
                csvEscape(item.condition),
                csvEscape(item.category),
                csvEscape(item.brand),
                csvEscape(item.size),
                csvEscape(item.barcode ?? ""),
                csvEscape(item.storageLocation)
            ]
            csv += row.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    private func csvEscape(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Statistics and Analytics
    func getStatistics() -> InventoryStatistics {
        let totalItems = items.count
        let listedCount = listedItems
        let soldCount = soldItems
        let investment = totalInvestment
        let profit = totalProfit
        let avgROI = averageROI
        
        return InventoryStatistics(
            totalItems: totalItems,
            listedItems: listedCount,
            soldItems: soldCount,
            totalInvestment: investment,
            totalProfit: profit,
            averageROI: avgROI,
            estimatedValue: totalEstimatedValue
        )
    }
    
    // MARK: - Category Analytics
    func getCategoryBreakdown() -> [String: Int] {
        let categories = Dictionary(grouping: items, by: { $0.category })
        return categories.mapValues { $0.count }
    }
    
    func getBestPerformingBrands() -> [String: Double] {
        let brands = Dictionary(grouping: items.filter { !$0.brand.isEmpty }, by: { $0.brand })
        return brands.mapValues { items in
            items.reduce(0) { $0 + $1.estimatedROI } / Double(items.count)
        }
    }
    
    // MARK: - Smart Search and Filtering
    func findItem(byInventoryCode code: String) -> InventoryItem? {
        return items.first { $0.inventoryCode.lowercased() == code.lowercased() }
    }
    
    func getItemsNeedingPhotos() -> [InventoryItem] {
        return items.filter { $0.status == .photographed && $0.imageData == nil }
    }
    
    func getItemsReadyToList() -> [InventoryItem] {
        return items.filter { $0.status == .toList }
    }
    
    func getPackagedItems() -> [InventoryItem] {
        return items.filter { $0.isPackaged }
    }
    
    // MARK: - Storage Management
    func updateStorageLocation(for item: InventoryItem, location: String, binNumber: String = "") {
        var updatedItem = item
        updatedItem.storageLocation = location
        updatedItem.binNumber = binNumber
        updateItem(updatedItem)
    }
    
    func markAsPackaged(_ item: InventoryItem) {
        var updatedItem = item
        updatedItem.isPackaged = true
        updatedItem.packagedDate = Date()
        updateItem(updatedItem)
    }
    
    func markAsUnpackaged(_ item: InventoryItem) {
        var updatedItem = item
        updatedItem.isPackaged = false
        updatedItem.packagedDate = nil
        updateItem(updatedItem)
    }
}
