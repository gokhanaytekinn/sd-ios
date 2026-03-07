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
                VStack(spacing: 8) {
                    Spacer().frame(height: 20)
                    ForEach(0..<4, id: \.self) { _ in
                        SkeletonCard()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: "hello_user".localized(), authViewModel.userName ?? "guest_user".localized()))
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                
                                Text("dashboard_title".localized())
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        Spacer().frame(height: 20)
                        
                        // Summary Card (replacing Hero Card)
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("total_monthly".localized())
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                
                                Text(CurrencyFormatter.formatAmount(viewModel.stats.totalMonthlyCost, currencyCode: currency))
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(viewModel.subscriptions.count) \("active".localized().lowercased())")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                        .padding(16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 20)
                        
                        // Upcoming Payments
                        HStack {
                            Text("upcoming_payments".localized())
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 12)
                        
                        if viewModel.upcomingSubscriptions.isEmpty {
                            Text("no_upcoming_payments".localized())
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
                        
                        Spacer().frame(height: 20)
                        
                        // Most Expensive
                        HStack {
                            Text("most_expensive".localized())
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            Spacer()
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
                                Text("view_all_subscriptions".localized())
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
                        
                        Spacer().frame(height: 20)
                    }
                }
            }
        }
        .onAppear {
            viewModel.authViewModel = authViewModel
            viewModel.loadDashboard()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshData"))) { _ in
            viewModel.loadDashboard()
        }
    }
}
