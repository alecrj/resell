import SwiftUI
import Vision
import AVFoundation
import MessageUI

// MARK: - Clean Dashboard View
struct DashboardView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @State private var showingPortfolioTracking = false
    @State private var showingBusinessIntelligence = false
    @State private var showingProfitOptimizer = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Clean Header
                    VStack(spacing: 8) {
                        Text("Business Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Your reselling business overview")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Key Metrics
                    CleanMetricsGrid(inventoryManager: inventoryManager)
                    
                    // Quick Actions
                    CleanQuickActions(
                        onPortfolio: { showingPortfolioTracking = true },
                        onIntelligence: { showingBusinessIntelligence = true },
                        onOptimizer: { showingProfitOptimizer = true }
                    )
                    
                    // Performance Summary
                    CleanPerformanceSummary(inventoryManager: inventoryManager)
                    
                    // Recent Activity
                    CleanRecentActivity(inventoryManager: inventoryManager)
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

// MARK: - Clean Metrics Grid
struct CleanMetricsGrid: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            
            MetricCard(
                title: "Total Value",
                value: "$\(String(format: "%.0f", inventoryManager.totalEstimatedValue))",
                color: .blue,
                icon: "dollarsign.circle"
            )
            
            MetricCard(
                title: "Total Profit",
                value: "$\(String(format: "%.0f", inventoryManager.totalProfit))",
                color: .green,
                icon: "chart.line.uptrend.xyaxis"
            )
            
            MetricCard(
                title: "Items",
                value: "\(inventoryManager.items.count)",
                color: .purple,
                icon: "cube.box"
            )
            
            MetricCard(
                title: "Avg ROI",
                value: "\(String(format: "%.0f", inventoryManager.averageROI))%",
                color: .orange,
                icon: "percent"
            )
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
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
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Clean Quick Actions
struct CleanQuickActions: View {
    let onPortfolio: () -> Void
    let onIntelligence: () -> Void
    let onOptimizer: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ActionCard(
                    title: "Portfolio",
                    subtitle: "Track performance",
                    color: .blue,
                    icon: "chart.bar",
                    action: onPortfolio
                )
                
                ActionCard(
                    title: "Intelligence",
                    subtitle: "Market insights",
                    color: .purple,
                    icon: "brain",
                    action: onIntelligence
                )
            }
            
            HStack(spacing: 12) {
                ActionCard(
                    title: "Optimizer",
                    subtitle: "Maximize profit",
                    color: .green,
                    icon: "wand.and.stars",
                    action: onOptimizer
                )
                
                ActionCard(
                    title: "Market Ops",
                    subtitle: "Coming soon",
                    color: .gray,
                    icon: "target",
                    action: {}
                )
            }
        }
    }
}

struct ActionCard: View {
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

// MARK: - Clean Performance Summary
struct CleanPerformanceSummary: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                PerformanceRow(
                    title: "Items Listed",
                    value: "\(inventoryManager.listedItems)",
                    trend: "+12%",
                    isPositive: true
                )
                
                PerformanceRow(
                    title: "Items Sold",
                    value: "\(inventoryManager.soldItems)",
                    trend: "+8%",
                    isPositive: true
                )
                
                PerformanceRow(
                    title: "Success Rate",
                    value: "\(getSuccessRate())%",
                    trend: "+5%",
                    isPositive: true
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func getSuccessRate() -> Int {
        let sold = inventoryManager.soldItems
        let total = inventoryManager.items.count
        return total > 0 ? Int(Double(sold) / Double(total) * 100) : 0
    }
}

struct PerformanceRow: View {
    let title: String
    let value: String
    let trend: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(trend)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isPositive ? .green : .red)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isPositive ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(4)
        }
    }
}

// MARK: - Clean Recent Activity
struct CleanRecentActivity: View {
    let inventoryManager: InventoryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(inventoryManager.recentItems.prefix(5)) { item in
                CleanActivityRow(item: item)
            }
            
            if inventoryManager.items.isEmpty {
                Text("No items yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
}

struct CleanActivityRow: View {
    let item: InventoryItem
    
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
            
            // Item Details
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack {
                    Text(item.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if item.estimatedROI > 100 {
                        Text("High ROI")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(3)
                    }
                }
            }
            
            Spacer()
            
            // Price and Status
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.status.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(item.status.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.status.color.opacity(0.1))
                    .cornerRadius(4)
                
                if item.estimatedProfit > 0 {
                    Text("$\(String(format: "%.0f", item.estimatedProfit))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Future Feature Views (Simplified)
struct PortfolioTrackingView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 12) {
                    Text("Portfolio Tracking")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Advanced portfolio analytics coming soon")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Preview Stats
                VStack(spacing: 8) {
                    HStack {
                        Text("Total Items:")
                        Spacer()
                        Text("\(inventoryManager.items.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Total Value:")
                        Spacer()
                        Text("$\(String(format: "%.0f", inventoryManager.totalEstimatedValue))")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Average ROI:")
                        Spacer()
                        Text("\(String(format: "%.0f", inventoryManager.averageROI))%")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Portfolio")
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
            VStack(spacing: 30) {
                Image(systemName: "brain")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                VStack(spacing: 12) {
                    Text("Business Intelligence")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("AI-powered insights coming soon")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Preview Insights
                VStack(spacing: 12) {
                    InsightRow(title: "Best Category", value: getBestCategory())
                    InsightRow(title: "Top Source", value: getTopSource())
                    InsightRow(title: "Success Rate", value: "\(getSuccessRate())%")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Intelligence")
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
    
    private func getBestCategory() -> String {
        let categories = Dictionary(grouping: inventoryManager.items, by: { $0.category })
        let categoryROI = categories.mapValues { items in
            items.reduce(0) { $0 + $1.estimatedROI } / Double(items.count)
        }
        return categoryROI.max(by: { $0.value < $1.value })?.key ?? "Mixed"
    }
    
    private func getTopSource() -> String {
        let sources = Dictionary(grouping: inventoryManager.items, by: { $0.source })
        return sources.max(by: { $0.value.count < $1.value.count })?.key ?? "Various"
    }
    
    private func getSuccessRate() -> Int {
        let sold = inventoryManager.soldItems
        let total = inventoryManager.items.count
        return total > 0 ? Int(Double(sold) / Double(total) * 100) : 0
    }
}

struct InsightRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
}

struct ProfitOptimizerView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                VStack(spacing: 12) {
                    Text("Profit Optimizer")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Maximize your profit potential")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Current Profit Summary
                VStack(spacing: 12) {
                    HStack {
                        Text("Current Profit:")
                        Spacer()
                        Text("$\(String(format: "%.0f", inventoryManager.totalProfit))")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Potential Profit:")
                        Spacer()
                        Text("$\(String(format: "%.0f", inventoryManager.totalEstimatedValue * 0.3))")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Optimization Score:")
                        Spacer()
                        Text("85%")
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Optimizer")
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
