import SwiftUI

struct DashboardScreen: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notificationsViewModel: NotificationsViewModel
    
    let onNavigateToSubscriptions: () -> Void
    let onNavigateToSubscriptionDetail: (String) -> Void
    let onNavigateToSearch: () -> Void
    let onNavigateToNotifications: () -> Void
    let onNavigateToAnalytics: () -> Void
    
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            StatefulView(
                isLoading: viewModel.isLoading,
                isEmpty: false,
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
                            
                            Spacer()
                            
                            NotificationBellButton(
                                unreadCount: notificationsViewModel.unreadCount,
                                onTap: onNavigateToNotifications
                            )
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
                        
                        Spacer().frame(height: 16)
                        
                        // Analiz Önizleme Kartı (Premium Feature Entry)
                        Button(action: onNavigateToAnalytics) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("analytics_entry_title".localized())
                                        .font(.sdLabelSemibold)
                                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                                    Text("analytics_entry_desc".localized())
                                        .font(.sdCaption)
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chart.pie.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primaryBlue)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                            .padding(20)
                            .background(Color.appSurface(for: colorScheme).opacity(0.001))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 28)
                        
                        // Ücretsiz Denemeler (Carousel) - Yaklaşan Ödemeler'den önce
                        if !viewModel.freeTrialSubscriptions.isEmpty {
                            HStack {
                                Text("free_trials_section_title".localized())
                                    .font(.sdSubheadlineSemibold)
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            Spacer().frame(height: 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.freeTrialSubscriptions) { sub in
                                        DashboardCarouselCard(
                                            subscription: sub,
                                            currency: currency,
                                            variant: .freeTrial
                                        ) {
                                            onNavigateToSubscriptionDetail(sub.id)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            Spacer().frame(height: 28)
                        }
                        
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
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.upcomingSubscriptions) { sub in
                                        DashboardCarouselCard(
                                            subscription: sub,
                                            currency: currency,
                                            variant: .upcoming
                                        ) {
                                            onNavigateToSubscriptionDetail(sub.id)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
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
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(viewModel.subscriptions.prefix(3))) { sub in
                                    DashboardCarouselCard(
                                        subscription: sub,
                                        currency: currency,
                                        variant: .mostExpensive
                                    ) {
                                        onNavigateToSubscriptionDetail(sub.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
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

private struct DashboardCarouselCard: View {
    let subscription: Subscription
    let currency: Int
    let variant: Variant
    let onTap: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    enum Variant {
        case freeTrial
        case upcoming
        case mostExpensive
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.dynamicColor(from: subscription.name).opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: leadingIcon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.dynamicColor(from: subscription.name))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(subscription.name)
                            .font(.sdLabelSemibold)
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                            .lineLimit(1)
                        
                        Text(subtitle)
                            .font(.sdCaption)
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    }
                    
                    Spacer(minLength: 0)
                }
                
                if let endDate = subscription.getNextRenewalDate() {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(line1(nextRenewalDate: endDate))
                            .font(.sdCaption)
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            .lineLimit(1)
                        
                        Text(daysLeftText(until: endDate))
                            .font(.sdSmallMedium)
                            .foregroundColor(.primaryBlue)
                    }
                } else {
                    Text(CurrencyFormatter.formatAmount(subscription.cost, currencyCode: currency))
                        .font(.sdSmallMedium)
                        .foregroundColor(.primaryBlue)
                        .lineLimit(1)
                }
            }
            .padding(16)
            .frame(width: 260, alignment: .leading)
            .background(Color.appSurface(for: colorScheme).opacity(0.001))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var leadingIcon: String {
        switch variant {
        case .freeTrial: return "gift.fill"
        case .upcoming: return "clock.fill"
        case .mostExpensive: return "creditcard.fill"
        }
    }
    
    private var subtitle: String {
        switch variant {
        case .freeTrial:
            return "free_trial".localized()
        case .upcoming:
            return CurrencyFormatter.formatAmount(subscription.cost, currencyCode: currency)
        case .mostExpensive:
            return CurrencyFormatter.formatAmount(subscription.cost, currencyCode: currency)
        }
    }
    
    private func line1(nextRenewalDate: Date) -> String {
        switch variant {
        case .freeTrial:
            return String(format: "trial_ends".localized(), formattedDate(nextRenewalDate))
        case .upcoming:
            return billingDateText(nextRenewalDate: nextRenewalDate)
        case .mostExpensive:
            return billingDateText(nextRenewalDate: nextRenewalDate)
        }
    }
    
    private func billingDateText(nextRenewalDate: Date) -> String {
        if subscription.billingCycle == .monthly,
           let billingDay = subscription.billingDay {
            return DateUtils.formatMonthlyRenewal(day: billingDay, language: LanguagePreferences.shared.selectedLanguage)
        }
        
        if subscription.billingCycle == .yearly,
           let billingDay = subscription.billingDay,
           let billingMonth = subscription.billingMonth {
            return DateUtils.formatYearlyRenewal(day: billingDay, month: billingMonth, language: LanguagePreferences.shared.selectedLanguage)
        }
        
        return DateUtils.formatDate(nextRenewalDate)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LanguagePreferences.shared.selectedLanguage)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func daysLeftText(until date: Date) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        if days <= 0 { return "today".localized() }
        if days == 1 { return "tomorrow".localized() }
        return "\(days) \("days_left".localized())"
    }
}
