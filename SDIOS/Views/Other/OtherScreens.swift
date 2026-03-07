import SwiftUI

// MARK: - Search Screen
struct SearchScreen: View {
    let onBack: () -> Void
    let onSubscriptionTap: (String) -> Void
    
    @StateObject private var viewModel = SubscriptionsViewModel()
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    
    var filteredSubscriptions: [Subscription] {
        if searchText.isEmpty {
            return viewModel.allSubscriptions
        }
        return viewModel.allSubscriptions.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.category?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
                Text(NSLocalizedString("search", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(16)
            
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                TextField(NSLocalizedString("search_placeholder", comment: ""), text: $searchText)
                    .autocapitalization(.none)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    }
                }
            }
            .padding(12)
            .background(Color.appSurface(for: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 16)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView().tint(.primaryBlue)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        if filteredSubscriptions.isEmpty {
                            VStack(spacing: 12) {
                                Spacer().frame(height: 60)
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                Text(NSLocalizedString("no_results", comment: ""))
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text(String(format: NSLocalizedString("results_found", comment: ""), filteredSubscriptions.count))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(filteredSubscriptions) { sub in
                                SubscriptionCard(
                                    subscription: sub,
                                    currency: currency,
                                    showDate: true,
                                    onTap: { onSubscriptionTap(sub.id) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear { viewModel.loadSubscriptions() }
    }
}

// MARK: - Premium Upgrade Screen
struct PremiumUpgradeScreen: View {
    let onBack: () -> Void
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedPlan = 0 // 0: Free, 1: Monthly, 2: Yearly
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero Title
                        VStack(spacing: 12) {
                            Text(NSLocalizedString("premium_hero_title", comment: ""))
                                .font(.system(size: 36, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                                .padding(.top, 20)
                            
                            Text(NSLocalizedString("premium_hero_subtitle", comment: ""))
                                .font(.system(size: 16))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .padding(.horizontal, 20)
                        }
                        
                        // Features
                        VStack(spacing: 16) {
                            premiumFeature(
                                icon: "bolt.circle.fill",
                                title: NSLocalizedString("feature_auto_capture_title", comment: ""),
                                desc: featureDesc(for: "auto_capture")
                            )
                            
                            premiumFeature(
                                icon: "infinity",
                                title: NSLocalizedString("feature_unlimited_tracking_title", comment: ""),
                                desc: featureDesc(for: "unlimited")
                            )
                        }
                        .padding(.vertical, 20)
                        
                        // Plans
                        VStack(spacing: 12) {
                            planCard(
                                id: 0,
                                title: NSLocalizedString("plan_free", comment: ""),
                                price: "₺0",
                                period: ""
                            )
                            
                            planCard(
                                id: 1,
                                title: NSLocalizedString("plan_monthly_premium", comment: ""),
                                price: "₺99.99",
                                period: NSLocalizedString("per_month", comment: "")
                            )
                            
                            planCard(
                                id: 2,
                                title: NSLocalizedString("plan_yearly_premium", comment: ""),
                                price: "₺799.99",
                                period: NSLocalizedString("per_year", comment: ""),
                                isPopular: true
                            )
                        }
                        
                        // Bottom Section (Moved inside ScrollView)
                        VStack(spacing: 16) {
                            Button(action: { /* Upgrade action */ }) {
                                Text(upgradeButtonText)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(isCurrentPlanSelected ? Color.gray.opacity(0.3) : Color.primaryBlue)
                                    .cornerRadius(12)
                            }
                            .disabled(isCurrentPlanSelected)
                            
                            HStack(spacing: 20) {
                                Button(NSLocalizedString("restore_purchase", comment: "")) { /* Restore */ }
                                Button(NSLocalizedString("terms_of_use_title", comment: "")) { /* Terms */ }
                                Button(NSLocalizedString("privacy_policy_title", comment: "")) { /* Privacy */ }
                            }
                            .font(.system(size: 12))
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                        }
                        .padding(.top, 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            setupInitialSelection()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                    .frame(width: 44, height: 44)
                    .background(Color.appSurface(for: colorScheme))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(NSLocalizedString("plans_header", comment: ""))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primaryBlue)
                .tracking(1)
            
            Spacer()
            
            // Dummy spacer to balance text
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
    
    private func premiumFeature(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appSurface(for: colorScheme))
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }
            
            Spacer()
            
            Image(systemName: featureIsActive(for: title) ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(featureIsActive(for: title) ? .primaryBlue : Color.appOnSurfaceVariant(for: colorScheme).opacity(0.5))
        }
    }
    
    private func planCard(id: Int, title: String, price: String, period: String, isPopular: Bool = false) -> some View {
        let isSelected = selectedPlan == id
        let isPremiumUser = authViewModel.tier >= 2
        let isFreePlan = id == 0
        
        return Button(action: {
            if isPremiumUser && isFreePlan {
                // Block selecting free plan for premium users
            } else {
                selectedPlan = id
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    Spacer()
                    if isPopular {
                        Text(NSLocalizedString("most_popular", comment: ""))
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primaryBlue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(price)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    if !period.isEmpty {
                        Text(period)
                            .font(.system(size: 16))
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            .padding(.bottom, 4)
                    }
                }
            }
            .padding(20)
            .background(Color.clear) // Transparent background
            .contentShape(Rectangle()) // Make the entire area tappable
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.primaryBlue : Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1) // Line width 1
            )
        }
        .buttonStyle(.plain)
        .opacity(isPremiumUser && isFreePlan ? 0.3 : 1.0) // Visual hint it's non-clickable
    }
    
    // MARK: - Logic Helpers
    
    private func setupInitialSelection() {
        switch authViewModel.tier {
        case 3:
            selectedPlan = 2 // Yearly
        case 2:
            selectedPlan = 1 // Monthly
        default:
            selectedPlan = 0 // Free
        }
    }
    
    private var isCurrentPlanSelected: Bool {
        switch authViewModel.tier {
        case 3:
            return selectedPlan == 2
        case 2:
            return selectedPlan == 1
        default:
            return selectedPlan == 0
        }
    }
    
    private var upgradeButtonText: String {
        if isCurrentPlanSelected {
            return NSLocalizedString("current_plan", comment: "")
        }
        
        let currentTier = authViewModel.tier // 1: Free, 2: Monthly, 3: Yearly
        
        if currentTier == 1 {
            return NSLocalizedString("upgrade_to_premium_btn", comment: "") // "Premium'a Geç"
        } else if currentTier == 2 {
            if selectedPlan == 2 {
                return NSLocalizedString("upgrade_plan", comment: "") // "Premium'u Yükselt"
            }
        } else if currentTier == 3 {
            if selectedPlan == 1 {
                return NSLocalizedString("downgrade_plan", comment: "") // "Premium'u Düşür"
            }
        }
        
        return NSLocalizedString("upgrade_to_premium_btn", comment: "")
    }
    
    private func featureDesc(for type: String) -> String {
        if type == "auto_capture" {
            return selectedPlan == 0 ? NSLocalizedString("feature_auto_capture_free_desc", comment: "") : NSLocalizedString("feature_auto_capture_premium_desc", comment: "")
        } else {
            return selectedPlan == 0 ? NSLocalizedString("feature_unlimited_tracking_free_desc", comment: "") : NSLocalizedString("feature_unlimited_tracking_premium_desc", comment: "")
        }
    }
    
    private func featureIsActive(for title: String) -> Bool {
        return selectedPlan > 0
    }
}

// MARK: - Transaction History Screen
struct TransactionHistoryScreen: View {
    let onBack: () -> Void
    
    @State private var transactions: [TransactionResponse] = []
    @State private var isLoading = true
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
                Text(NSLocalizedString("transaction_history", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(16)
            
            if isLoading {
                Spacer()
                ProgressView().tint(.primaryBlue)
                Spacer()
            } else if transactions.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    Text(NSLocalizedString("no_transactions", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(transactions) { tx in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tx.description ?? NSLocalizedString("transaction", comment: ""))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                                    
                                    Text(DateUtils.formatDate(tx.createdAt))
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                
                                Spacer()
                                
                                Text(CurrencyFormatter.formatAmount(tx.amount, currencyCode: tx.currency ?? currency))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(tx.type == 1 ? .errorColor : .successColor)
                            }
                            .padding(16)
                            .background(Color.appSurface(for: colorScheme))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear { loadTransactions() }
    }
    
    private func loadTransactions() {
        Task {
            isLoading = true
            let result = await SubscriptionRepository.shared.getTransactions()
            if case .success(let page) = result {
                transactions = page.content
            }
            isLoading = false
        }
    }
}
