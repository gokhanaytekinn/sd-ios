import SwiftUI
import Charts

struct AnalyticsScreen: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let onBack: () -> Void
    let onNavigateToPremium: () -> Void
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                    }
                    
                    Spacer()
                    
                    Text("analytics_title".localized())
                        .font(.sdHeadline)
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    Spacer()
                    
                    // Empty space to balance back button
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Summary Card
                        summaryCard
                        
                        // Category Breakdown (Charts)
                        categoryBreakdownChart
                        
                        // Spending Trends
                        spendingTrendChart
                        
                        // Insights
                        insightsSection
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(24)
                    .blur(radius: viewModel.isPremium ? 0 : 8)
                    .disabled(!viewModel.isPremium)
                }
            }
            
            // Premium Overlay
            if !viewModel.isPremium {
                premiumLockOverlay
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    ProgressView()
                }
            }
        }
        .onAppear {
            viewModel.authViewModel = authViewModel
            viewModel.loadAnalytics()
        }
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("monthly_total".localized())
                .font(.sdCaption)
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            
            if let summary = viewModel.summary {
                Text(CurrencyFormatter.formatAmount(summary.totalMonthlyCost, currencyCode: summary.currency))
                    .font(.sdAmount)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                HStack {
                    Text("yearly_estimated".localized())
                        .font(.sdLabel)
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    
                    Text(CurrencyFormatter.formatAmount(summary.totalYearlyCost, currencyCode: summary.currency))
                        .font(.sdLabelSemibold)
                        .foregroundColor(.primaryBlue)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface(for: colorScheme))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
        )
    }
    
    // MARK: - Category Breakdown
    private var categoryBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("category_distribution".localized())
                .font(.sdSubheadlineSemibold)
                .foregroundColor(Color.appOnBackground(for: colorScheme))
            
            if let summary = viewModel.summary, !summary.categoryBreakdown.isEmpty {
                Chart {
                    ForEach(summary.categoryBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                        SectorMark(
                            angle: .value("Amount", amount),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(by: .value("Category", category))
                    }
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, spacing: 16)
            } else {
                Text("no_data_available".localized())
                    .font(.sdCaption)
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }
        }
        .padding(24)
        .background(Color.appSurface(for: colorScheme))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
        )
    }
    
    // MARK: - Spending Trend
    private var spendingTrendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("spending_trends".localized())
                .font(.sdSubheadlineSemibold)
                .foregroundColor(Color.appOnBackground(for: colorScheme))
            
            if !viewModel.trends.isEmpty {
                Chart {
                    ForEach(viewModel.trends) { trend in
                        BarMark(
                            x: .value("Month", trend.month),
                            y: .value("Cost", trend.totalCost)
                        )
                        .foregroundStyle(Color.primaryBlue.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 180)
            } else {
                Text("no_data_available".localized())
                    .font(.sdCaption)
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }
        }
        .padding(24)
        .background(Color.appSurface(for: colorScheme))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
        )
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("smart_insights".localized())
                    .font(.sdSubheadlineSemibold)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.insights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.primaryBlue)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(insight)
                            .font(.sdLabel)
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if insight != viewModel.insights.last {
                        Divider()
                    }
                }
            }
        }
        .padding(24)
        .background(Color.appSurface(for: colorScheme))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
        )
    }
    
    // MARK: - Premium Lock Overlay
    private var premiumLockOverlay: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.primaryBlue)
            }
            
            VStack(spacing: 8) {
                Text("premium_analytics_locked".localized())
                    .font(.sdSubheadlineSemibold)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Text("premium_analytics_desc".localized())
                    .font(.sdCaption)
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onNavigateToPremium) {
                Text("unlock_with_premium".localized())
                    .font(.sdBodyBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.primaryBlue)
                    .cornerRadius(16)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground(for: colorScheme).opacity(0.4))
    }
}
