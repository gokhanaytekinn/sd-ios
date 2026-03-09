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
            
            StatefulView(
                isLoading: viewModel.isLoading,
                isEmpty: viewModel.subscriptions.isEmpty,
                emptyMessage: "dashboard_empty_text".localized(),
                emptyIcon: "plus.circle.fill",
                skeleton: { DashboardSkeleton() }
            ) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Üst Başlık ve Karşılama
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: "hello_user".localized(), authViewModel.userName ?? "guest_user".localized()))
                                    .font(.sdCaption)
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                
                                Text("dashboard_title".localized())
                                    .font(.sdHeadline)
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        Spacer().frame(height: 20)
                        
                        // Özet Kartı - Transparan ve Kenarlıklı (Kullanıcı İsteği)
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("total_monthly".localized())
                                    .font(.sdSmallMedium)
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                
                                Text(CurrencyFormatter.formatAmount(viewModel.stats.totalMonthlyCost, currencyCode: currency))
                                    .font(.sdAmount)
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("\(viewModel.subscriptions.count) \("active".localized().lowercased())")
                                    .font(.sdSmallMedium)
                                    .foregroundColor(authViewModel.isSubscriptionLimitReached ? .errorColor : .primaryBlue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(authViewModel.isSubscriptionLimitReached ? Color.errorColor.opacity(0.1) : Color.primaryBlue.opacity(0.1))
                                    )
                            }
                        }
                        .padding(24)
                        .background(Color.appSurface(for: colorScheme).opacity(0.001))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 28)
                        
                        // Yaklaşan Ödemeler Bölümü
                        HStack {
                            Text("upcoming_payments".localized())
                                .font(.sdSubheadlineSemibold)
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 12)
                        
                        if viewModel.upcomingSubscriptions.isEmpty {
                            Text("no_upcoming_payments".localized())
                                .font(.sdCaption)
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
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
                        
                        Spacer().frame(height: 28)
                        
                        // En Yüksek Ücretli Abonelikler
                        HStack {
                            Text("most_expensive".localized())
                                .font(.sdSubheadlineSemibold)
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 12)
                        
                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.subscriptions.prefix(3))) { sub in
                                SubscriptionCard(
                                    subscription: sub,
                                    currency: currency,
                                    showDate: true,
                                    onTap: { onNavigateToSubscriptionDetail(sub.id) }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 24)
                        
                        // Tüm Abonelikleri Görüntüle Butonu
                        PremiumButton(
                            title: "view_all_subscriptions".localized(),
                            icon: "arrow.right",
                            backgroundColor: Color.appSurface(for: colorScheme).opacity(0.001),
                            action: onNavigateToSubscriptions
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 32)
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
