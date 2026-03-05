import SwiftUI

struct DashboardScreen: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let onNavigateToSubscriptions: () -> Void
    let onNavigateToSubscriptionDetail: (String) -> Void
    let onNavigateToSearch: () -> Void
    
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(.primaryBlue)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: NSLocalizedString("hello_user", comment: ""), authViewModel.userName ?? NSLocalizedString("guest_user", comment: "")))
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                
                                Text(NSLocalizedString("dashboard_title", comment: ""))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                            }
                            
                            Spacer()
                            
                            Button(action: onNavigateToSearch) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                    .frame(width: 42, height: 42)
                                    .background(Color.appSurface(for: colorScheme))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        Spacer().frame(height: 20)
                        
                        // Hero Card - Total Monthly
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("total_monthly", comment: ""))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            
                            Text(CurrencyFormatter.formatAmount(viewModel.stats.totalMonthlyCost, currencyCode: currency))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primaryBlue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(Color.appSurface(for: colorScheme))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 24)
                        
                        // Upcoming Payments
                        HStack {
                            Text(NSLocalizedString("upcoming_payments", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 12)
                        
                        if viewModel.upcomingSubscriptions.isEmpty {
                            Text(NSLocalizedString("no_upcoming_payments", comment: ""))
                                .font(.system(size: 14))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .padding(.horizontal, 24)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(viewModel.upcomingSubscriptions) { sub in
                                    SubscriptionCard(
                                        subscription: sub,
                                        currency: currency,
                                        showCountdown: true,
                                        onTap: { onNavigateToSubscriptionDetail(sub.id) }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer().frame(height: 24)
                        
                        // Most Expensive
                        HStack {
                            Text(NSLocalizedString("most_expensive", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            Spacer()
                            Button(action: onNavigateToSubscriptions) {
                                Text(NSLocalizedString("view_all", comment: ""))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 12)
                        
                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.subscriptions.prefix(5))) { sub in
                                SubscriptionCard(
                                    subscription: sub,
                                    currency: currency,
                                    showDate: true,
                                    onTap: { onNavigateToSubscriptionDetail(sub.id) }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 16)
                        
                        // View All Subscriptions Button
                        Button(action: onNavigateToSubscriptions) {
                            HStack {
                                Text(NSLocalizedString("view_all_subscriptions", comment: ""))
                                    .font(.system(size: 16, weight: .bold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.primaryBlue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadDashboard()
        }
    }
}
