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
                Text("search".localized())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(16)
            
            // Search Field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.4))
                
                TextField("search_placeholder".localized(), text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                    .autocapitalization(.none)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 45)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appOutline(for: colorScheme).opacity(1.0), lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 16)
            
            StatefulView(
                isLoading: viewModel.isLoading,
                isEmpty: filteredSubscriptions.isEmpty && !searchText.isEmpty,
                emptyMessage: "no_results".localized(),
                emptyIcon: "magnifyingglass",
                skeleton: { SearchListSkeleton() }
            ) {
                ScrollView {
                    VStack(spacing: 8) {
                        if !searchText.isEmpty {
                            Text(String(format: "results_found".localized(), filteredSubscriptions.count))
                                .font(.sdCaptionMedium)
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if filteredSubscriptions.isEmpty {
                            EmptyStateView(message: "search_start_hint".localized(), icon: "magnifyingglass")
                        }
                        
                        ForEach(filteredSubscriptions) { sub in
                            SubscriptionCard(
                                subscription: sub,
                                currency: currency,
                                showDate: true,
                                onTap: { onSubscriptionTap(sub.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear { viewModel.loadSubscriptions() }
    }
}

// MARK: - Premium Upgrade Screen
import StoreKit

struct PremiumUpgradeScreen: View {
    let onBack: () -> Void
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedPlan = 0 // 0: Free, 1: Monthly, 2: Yearly
    @State private var showTermsDialog = false
    @State private var showPrivacyDialog = false
    
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
                            Text("premium_hero_title".localized())
                                .font(.system(size: 36, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                                .padding(.top, 20)
                            
                            Text("premium_hero_subtitle".localized())
                                .font(.system(size: 16))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .padding(.horizontal, 20)
                        }
                        
                        // Features
                        VStack(spacing: 16) {
                            premiumFeature(
                                icon: "infinity",
                                title: "feature_unlimited_tracking_title".localized(),
                                desc: featureDesc(for: "unlimited")
                            )
                            
                            premiumFeature(
                                icon: "bolt.circle.fill",
                                title: "feature_auto_capture_title".localized(),
                                desc: featureDesc(for: "auto_capture")
                            )
                            
                            premiumFeature(
                                icon: "chart.bar.fill",
                                title: "feature_analytics_title".localized(),
                                desc: featureDesc(for: "analytics")
                            )
                            
                            premiumFeature(
                                icon: "speaker.slash.fill",
                                title: "feature_ad_free_title".localized(),
                                desc: featureDesc(for: "ad_free")
                            )
                        }
                        .padding(.vertical, 20)
                        
                        // Plans
                        VStack(spacing: 12) {
                            planCard(
                                id: 0,
                                title: "plan_free".localized(),
                                price: "plan_free_price".localized(),
                                period: ""
                            )
                            
                            if authViewModel.iapProducts.isEmpty {
                                PlanCardSkeleton()
                            } else {
                                ForEach(authViewModel.iapProducts, id: \.id) { product in
                                    let isYearly = product.id.contains("yearly")
                                    planCard(
                                        id: isYearly ? 2 : 1,
                                        title: product.displayName,
                                        price: product.displayPrice,
                                        period: isYearly ? "/ \("period_yearly".localized())" : "/ \("period_monthly".localized())",
                                        isPopular: isYearly
                                    )
                                }
                            }
                        }
                        
                        // Bottom Section (Moved inside ScrollView)
                        VStack(spacing: 16) {
                            if authViewModel.isLoading {
                                PremiumButtonSkeleton()
                                    .frame(maxWidth: .infinity)
                                    .allowsHitTesting(false)
                            } else {
                                Button(action: {
                                    // Uygun ürünü bul
                                    let productToPurchase = authViewModel.iapProducts.first { product in
                                        if selectedPlan == 1 {
                                            return product.id.contains("monthly")
                                        } else if selectedPlan == 2 {
                                            return product.id.contains("yearly")
                                        }
                                        return false
                                    }
                                    
                                    if let product = productToPurchase {
                                        authViewModel.purchase(product: product)
                                    }
                                }) {
                                    Text(upgradeButtonText)
                                        .font(.sdBodyBold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                                .foregroundColor(isCurrentPlanSelected ? Color.secondary : Color.primaryBlue)
                                .background(Color.appSurface(for: colorScheme).opacity(0.001))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isCurrentPlanSelected ? Color.appOutline(for: colorScheme).opacity(0.5) : Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                                )
                                .disabled(isCurrentPlanSelected || (selectedPlan != 0 && authViewModel.iapProducts.isEmpty))
                            }
                            
                            // Apple Requirement: Auto-Renewable Disclaimer
                            Text("auto_renewable_disclaimer".localized())
                                .font(.system(size: 10))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme).opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                            
                            HStack(spacing: 16) {
                                Button("restore_purchase".localized()) { authViewModel.restorePurchases() }
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                
                                Button(action: { showTermsDialog = true }) {
                                    Text("terms_of_use_title".localized())
                                        .underline()
                                        .foregroundColor(.primaryBlue)
                                }
                                
                                Button(action: { showPrivacyDialog = true }) {
                                    Text("privacy_policy_title".localized())
                                        .underline()
                                        .foregroundColor(.primaryBlue)
                                }
                            }
                            .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.top, 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
            
            // Loading state is represented by button skeleton above.
        }
        .alert("error".localized(), isPresented: Binding(
            get: { authViewModel.error != nil },
            set: { if !$0 { authViewModel.clearGeneralError() } }
        )) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            if let error = authViewModel.error {
                Text(error)
            }
        }
        .onAppear {
            setupInitialSelection()
            // Ensure products are fetched if they are missing
            if authViewModel.iapProducts.isEmpty {
                Task {
                    await StoreKitManager.shared.fetchProducts()
                }
            }
        }
        .sheet(isPresented: $showTermsDialog) {
            termsSheet
        }
        .sheet(isPresented: $showPrivacyDialog) {
            privacySheet
        }
    }
    
    private var termsSheet: some View {
        NavigationStack {
            ScrollView {
                Text("terms_of_use_content".localized())
                    .padding()
            }
            .navigationTitle("terms_of_use_title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("understood".localized()) {
                        showTermsDialog = false
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private var privacySheet: some View {
        NavigationStack {
            ScrollView {
                Text("privacy_dialog_content".localized())
                    .padding()
            }
            .navigationTitle("privacy_policy_title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("close".localized()) {
                        showPrivacyDialog = false
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.bold)
                }
            }
        }
        .interactiveDismissDisabled() // Prevent accidental dismissal if we want explicit close
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
            
            Text("plans_header".localized())
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
                        Text("most_popular".localized())
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
            // For free users, default selection to Yearly (index 2) so they can click Upgrade
            selectedPlan = 2
        }
    }
    
    private var isCurrentPlanSelected: Bool {
        switch authViewModel.tier {
        case 3:
            return selectedPlan == 2
        case 2:
            return selectedPlan == 1
        default:
            // Free plan is ID 0
            return selectedPlan == 0
        }
    }
    
    private var upgradeButtonText: String {
        if isCurrentPlanSelected {
            return "current_plan".localized()
        }
        
        let currentTier = authViewModel.tier // 1: Free, 2: Monthly, 3: Yearly
        
        if currentTier == 1 {
            return "upgrade_to_premium_btn".localized() // "Premium'a Geç"
        } else if currentTier == 2 {
            if selectedPlan == 2 {
                return "upgrade_plan".localized() // "Premium'u Yükselt"
            }
        } else if currentTier == 3 {
            if selectedPlan == 1 {
                return "downgrade_plan".localized() // "Premium'u Düşür"
            }
        }
        
        return "upgrade_to_premium_btn".localized()
    }
    
    private func featureDesc(for type: String) -> String {
        let isFree = selectedPlan == 0
        switch type {
        case "auto_capture":
            return isFree ? "feature_auto_capture_free_desc".localized() : "feature_auto_capture_premium_desc".localized()
        case "unlimited":
            return isFree ? "feature_unlimited_tracking_free_desc".localized() : "feature_unlimited_tracking_premium_desc".localized()
        case "analytics":
            return isFree ? "feature_analytics_free_desc".localized() : "feature_advanced_analytics_premium_desc".localized()
        case "ad_free":
            return isFree ? "feature_ad_free_free_desc".localized() : "feature_ad_free_desc".localized()
        default:
            return ""
        }
    }
    
    private func featureIsActive(for title: String) -> Bool {
        return selectedPlan > 0
    }
}

// MARK: - Transaction History Screen
struct TransactionHistoryScreen: View {
    let onBack: () -> Void
    
    @StateObject private var viewModel = TransactionsViewModel()
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Üst Başlık
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
                Text("transaction_history".localized())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                // Ortalamayı korumak için boş alan
                Color.clear.frame(width: 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            StatefulView(
                isLoading: viewModel.isLoading,
                isEmpty: viewModel.transactions.isEmpty,
                emptyMessage: "no_transactions".localized(),
                emptyIcon: "list.bullet.rectangle",
                skeleton: { TransactionListSkeleton() }
            ) {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.transactions) { tx in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tx.description ?? "transaction".localized())
                                        .font(.sdBodyMedium)
                                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                                    
                                    Text(DateUtils.formatDate(tx.createdAt))
                                        .font(.sdSmall)
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                
                                Spacer()
                                
                                Text(CurrencyFormatter.formatAmount(tx.amount, currencyCode: tx.currency ?? currency))
                                    .font(.sdBodyBold)
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
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear { viewModel.loadTransactions() }
    }
}
