import SwiftUI
import Vision
import AVFoundation
import MessageUI

// MARK: - Dashboard View with Business Intelligence
struct DashboardView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @State private var showingPortfolioTracking = false
    @State private var showingBusinessIntelligence = false
    @State private var showingProfitOptimizer = false
    @State private var selectedTimeframe = "This Month"
    
    let timeframes = ["This Week", "This Month", "Last 3 Months", "This Year", "All Time"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🚀 BUSINESS COMMAND CENTER")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Path to eBay Empire")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    // Empire Metrics Row
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        EmpireStatCard(
                            title: "Empire Value",
                            value: "$\(String(format: "%.0f", inventoryManager.totalEstimatedValue))",
                            color: .blue,
                            icon: "crown.fill"
                        )
                        
                        EmpireStatCard(
                            title: "Profit Power",
                            value: "$\(String(format: "%.0f", inventoryManager.totalProfit))",
                            color: .green,
                            icon: "bolt.fill"
                        )
                        
                        EmpireStatCard(
                            title: "ROI Mastery",
                            value: "\(String(format: "%.0f", inventoryManager.averageROI))%",
                            color: .purple,
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        
                        EmpireStatCard(
                            title: "Items Sold",
                            value: "\(inventoryManager.soldItems)",
                            color: .orange,
                            icon: "star.fill"
                        )
                    }
                    
                    // Action Center
                    VStack(alignment: .leading, spacing: 15) {
                        Text("⚡ EMPIRE ACCELERATORS")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            
                            DashboardActionButton(
                                title: "🧠 Business Intelligence",
                                description: "AI insights for growth",
                                color: .purple
                            ) {
                                showingBusinessIntelligence = true
                            }
                            
                            DashboardActionButton(
                                title: "💰 Profit Optimizer",
                                description: "Maximize every sale",
                                color: .green
                            ) {
                                showingProfitOptimizer = true
                            }
                            
                            DashboardActionButton(
                                title: "📈 Portfolio Tracking",
                                description: "Monitor your empire",
                                color: .blue
                            ) {
                                showingPortfolioTracking = true
                            }
                            
                            DashboardActionButton(
                                title: "🎯 Market Opportunities",
                                description: "Hot profit opportunities",
                                color: .red
                            ) {
                                // TODO: Show market opportunities
                            }
                        }
                    }
                    
                    // Quick Insights Panel
                    QuickInsightsPanel(inventoryManager: inventoryManager)
                    
                    // Performance Trends
                    PerformanceTrendsView(inventoryManager: inventoryManager)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔥 RECENT EMPIRE ACTIVITY")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(inventoryManager.recentItems.prefix(5)) { item in
                            RecentItemCard(item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPortfolioTracking) {
            PortfolioTrackingView()
                .environmentObject(inventoryManager)
        }
        .sheet(isPresented: $showingBusinessIntelligence) {
            BusinessIntelligenceView()
                .environmentObject(inventoryManager)
        }
        .sheet(isPresented: $showingProfitOptimizer) {
            ProfitOptimizerView()
                .environmentObject(inventoryManager)
        }
    }
}

// MARK: - Business Intelligence Components
struct EmpireStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 100)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DashboardActionButton: View {
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

struct QuickInsightsPanel: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("⚡ QUICK INSIGHTS")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                InsightCard(
                    title: "Best Category",
                    value: getBestCategory(),
                    color: .green
                )
                
                InsightCard(
                    title: "Avg. Time to Sell",
                    value: "12 days",
                    color: .blue
                )
                
                InsightCard(
                    title: "Success Rate",
                    value: "\(getSuccessRate())%",
                    color: .purple
                )
                
                InsightCard(
                    title: "Next Goal",
                    value: "$\(getNextGoal())",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func getBestCategory() -> String {
        let categories = Dictionary(grouping: inventoryManager.items, by: { $0.category })
        let categoryROI = categories.mapValues { items in
            items.reduce(0) { $0 + $1.estimatedROI } / Double(items.count)
        }
        return categoryROI.max(by: { $0.value < $1.value })?.key ?? "Mixed"
    }
    
    private func getSuccessRate() -> Int {
        let sold = inventoryManager.soldItems
        let total = inventoryManager.items.count
        return total > 0 ? Int(Double(sold) / Double(total) * 100) : 0
    }
    
    private func getNextGoal() -> String {
        let current = Int(inventoryManager.totalEstimatedValue)
        let nextMilestone = ((current / 1000) + 1) * 1000
        return String(nextMilestone)
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title3)
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

struct PerformanceTrendsView: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("📊 PERFORMANCE TRENDS")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TrendRow(
                    title: "Monthly Revenue",
                    value: "$\(String(format: "%.0f", getMonthlyRevenue()))",
                    trend: "+12%",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Avg. ROI",
                    value: "\(String(format: "%.0f", inventoryManager.averageROI))%",
                    trend: "+8%",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Items Listed",
                    value: "\(inventoryManager.listedItems)",
                    trend: "+5%",
                    isPositive: true
                )
                
                TrendRow(
                    title: "Inventory Value",
                    value: "$\(String(format: "%.0f", inventoryManager.totalEstimatedValue))",
                    trend: "+15%",
                    isPositive: true
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func getMonthlyRevenue() -> Double {
        return inventoryManager.totalProfit * 1.2
    }
}

struct TrendRow: View {
    let title: String
    let value: String
    let trend: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
            
            Text(trend)
                .font(.caption)
                .foregroundColor(isPositive ? .green : .red)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isPositive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .cornerRadius(6)
        }
    }
}

struct RecentItemCard: View {
    let item: InventoryItem
    
    var body: some View {
        HStack {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(item.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if item.estimatedROI > 100 {
                        Text("🔥 Hot Deal")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.status.color.opacity(0.2))
                    .foregroundColor(item.status.color)
                    .cornerRadius(8)
                
                if item.estimatedProfit > 0 {
                    Text("$\(String(format: "%.0f", item.estimatedProfit))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Additional Empire Views
struct PortfolioTrackingView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("📈 EMPIRE PORTFOLIO TRACKING")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("Advanced portfolio tracking coming soon!")
                        .foregroundColor(.secondary)
                    
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

struct BusinessIntelligenceView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🧠 BUSINESS INTELLIGENCE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("AI-powered business insights coming soon!")
                        .foregroundColor(.secondary)
                    
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

struct ProfitOptimizerView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("💰 PROFIT OPTIMIZER")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Profit optimization engine coming soon!")
                        .foregroundColor(.secondary)
                    
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
