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
                TextField(NSLocalizedString("search_subscriptions_placeholder", comment: ""), text: $searchText)
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
                                Text(NSLocalizedString("no_results_found", comment: ""))
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("\(filteredSubscriptions.count) \(NSLocalizedString("results", comment: ""))")
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
                Text(NSLocalizedString("upgrade_to_premium", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(16)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Premium header
                    VStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.warningColor)
                        
                        Text(NSLocalizedString("go_premium", comment: ""))
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        Text(NSLocalizedString("premium_desc", comment: ""))
                            .font(.system(size: 16))
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                    
                    // Features
                    VStack(spacing: 12) {
                        premiumFeature(icon: "infinity", title: NSLocalizedString("premium_feature_1", comment: ""), desc: NSLocalizedString("premium_feature_1_desc", comment: ""))
                        premiumFeature(icon: "chart.bar.fill", title: NSLocalizedString("premium_feature_2", comment: ""), desc: NSLocalizedString("premium_feature_2_desc", comment: ""))
                        premiumFeature(icon: "bell.badge.fill", title: NSLocalizedString("premium_feature_3", comment: ""), desc: NSLocalizedString("premium_feature_3_desc", comment: ""))
                        premiumFeature(icon: "person.2.fill", title: NSLocalizedString("premium_feature_4", comment: ""), desc: NSLocalizedString("premium_feature_4_desc", comment: ""))
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
    
    private func premiumFeature(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.primaryBlue)
                .frame(width: 36, height: 36)
                .background(Color.primaryBlue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }
            
            Spacer()
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
                Text(NSLocalizedString("transaction_history_title", comment: ""))
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
