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
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.4))
                
                TextField(NSLocalizedString("search_placeholder", comment: ""), text: $searchText)
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
                            Text(String(format: NSLocalizedString("results_found", comment: ""), filteredSubscriptions.count))
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
                            
                            if authViewModel.iapProducts.isEmpty {
                                PlanCardSkeleton()
                            } else {
                                ForEach(authViewModel.iapProducts, id: \.id) { product in
                                    let isYearly = product.id.contains("yearly")
                                    planCard(
                                        id: isYearly ? 2 : 1,
                                        title: product.displayName,
                                        price: product.displayPrice,
                                        period: isYearly ? "/ \(NSLocalizedString("period_yearly", comment: ""))" : "/ \(NSLocalizedString("period_monthly", comment: ""))",
                                        isPopular: isYearly
                                    )
                                }
                            }
                        }
                        
                        // Bottom Section (Moved inside ScrollView)
                        VStack(spacing: 16) {
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
                                Text(authViewModel.isLoading ? "loading".localized() : upgradeButtonText)
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
                            .disabled(isCurrentPlanSelected || authViewModel.isLoading || (selectedPlan != 0 && authViewModel.iapProducts.isEmpty))
                            
                            HStack(spacing: 20) {
                                Button("restore_purchase".localized()) { authViewModel.restorePurchases() }
                                Button("terms_of_use_title".localized()) { showTermsDialog = true }
                                Button("privacy_policy_title".localized()) { showPrivacyDialog = true }
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
            
            if authViewModel.isLoading {
                Color.appBackground(for: colorScheme).opacity(0.8).ignoresSafeArea()
                VStack(spacing: 16) {
                    PlanCardSkeleton()
                    Text("loading".localized())
                        .font(.sdBodyBold)
                        .foregroundColor(.primaryBlue)
                }
                .transition(.opacity)
            }
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
                Text(NSLocalizedString("transaction_history", comment: ""))
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
                                    Text(tx.description ?? NSLocalizedString("transaction", comment: ""))
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
