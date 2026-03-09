import SwiftUI

struct SubscriptionsListScreen: View {
    @StateObject private var viewModel = SubscriptionsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let onNavigateToAddSubscription: () -> Void
    let onNavigateToSubscriptionDetail: (String) -> Void
    
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @State private var selectedTab = 0
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack(spacing: 8) {
                    Spacer().frame(height: 20)
                    ForEach(0..<6, id: \.self) { _ in
                        SkeletonCard()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("subscriptions".localized())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer().frame(height: 16)
                    
                    // Summary Card
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
                            Text("\(viewModel.activeSubscriptions.count) \("active".localized().lowercased())")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(authViewModel.isSubscriptionLimitReached ? .errorColor : .primaryBlue)
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
                    
                    // Subscription Limit (Free Plan)
                    if authViewModel.tier == 1 {
                        Spacer().frame(height: 12)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("\(viewModel.allSubscriptions.count)/5 \("subscriptions".localized())")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(authViewModel.isSubscriptionLimitReached ? .errorColor : Color.appOnSurfaceVariant(for: colorScheme))
                                Spacer()
                                Text("free_plan".localized())
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.primaryBlue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.primaryBlue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.appSurfaceVariant(for: colorScheme))
                                        .frame(height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(authViewModel.isSubscriptionLimitReached ? .errorColor : Color.primaryBlue)
                                        .frame(width: geo.size.width * min(CGFloat(viewModel.allSubscriptions.count) / 5.0, 1.0), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    // Tabs
                    HStack(spacing: 0) {
                        tabButton("active".localized(), tag: 0)
                        tabButton("pending_approve".localized(), tag: 1)
                        tabButton("cancelled".localized(), tag: 2)
                    }
                    .background(Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 16)
                    
                    // Search Bar
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
                    .background(Color.appSurface(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 12)
                    
                    // Subscription List
                    ScrollView {
                        VStack(spacing: 8) {
                            if selectedTab == 1 && !viewModel.invitations.isEmpty {
                                HStack {
                                    Text(String(format: "pending_invitations".localized(), viewModel.invitations.count))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primaryBlue)
                                    Spacer()
                                }
                                .padding(.top, 12)
                                .padding(.bottom, 4)
                                
                                ForEach(viewModel.invitations) { invitation in
                                    invitationCard(invitation)
                                }
                                
                                Spacer().frame(height: 12)
                            }

                            let subs = currentTabSubscriptions
                            if subs.isEmpty && (selectedTab != 1 || viewModel.invitations.isEmpty) {
                                emptyState
                            } else {
                                ForEach(subs) { sub in
                                    SubscriptionCard(
                                        subscription: sub,
                                        currency: currency,
                                        showDate: true,
                                        isJoint: (sub.participants?.count ?? 0) > 0,
                                        onTap: { onNavigateToSubscriptionDetail(sub.id) }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            viewModel.authViewModel = authViewModel
            viewModel.loadSubscriptions()
        }
        .alert("limit_reached_title".localized(), isPresented: $viewModel.showingLimitAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text("limit_reached_message".localized())
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshData"))) { _ in
            viewModel.loadSubscriptions()
        }
    }
    
    private var currentTabSubscriptions: [Subscription] {
        let baseSubscriptions: [Subscription]
        switch selectedTab {
        case 0: baseSubscriptions = viewModel.activeSubscriptions
        case 1: baseSubscriptions = viewModel.suspiciousSubscriptions
        case 2: baseSubscriptions = viewModel.cancelledSubscriptions
        default: baseSubscriptions = []
        }
        
        if searchText.isEmpty {
            return baseSubscriptions
        } else {
            return baseSubscriptions.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.category?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    private var emptyStateText: String {
        switch selectedTab {
        case 0: return "no_active_subscriptions".localized()
        case 1: return "no_suspicious_subscriptions".localized()
        default: return "no_cancelled_subscriptions".localized()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            
            Text(emptyStateText)
                .font(.system(size: 16))
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func tabButton(_ title: String, tag: Int) -> some View {
        Button(action: { selectedTab = tag }) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedTab == tag ? .white : Color.appOnSurfaceVariant(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == tag ? Color.primaryBlue : Color.appSurface(for: colorScheme).opacity(0.001))
                .cornerRadius(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func invitationCard(_ invitation: SubscriptionInvitation) -> some View {
        VStack(spacing: 12) {
            HStack {
                // Icon (Brand)
                brandIcon(invitation.subscriptionName ?? "")
                
                Spacer().frame(width: 16)
                
                // Name & Info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(invitation.subscriptionName ?? "")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.primaryBlue)
                    }
                    
                    Text("\( "joint_subscription".localized()) • \(billingCycleText(invitation.billingCycle ?? 1))")
                        .font(.system(size: 12))
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                }
                
                Spacer()
                
                // Price
                Text(CurrencyFormatter.formatAmount(invitation.amount ?? 0.0, currencyCode: invitation.currency ?? 1))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
            }
            .padding(.top, 4)
            
            HStack(spacing: 12) {
                Spacer()
                
                Button(action: { viewModel.rejectInvitation(id: invitation.id) }) {
                    Text("reject".localized())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
                        )
                }
                
                Button(action: { viewModel.acceptInvitation(id: invitation.id) }) {
                    Text("accept".localized())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primaryBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.appSurface(for: colorScheme).opacity(0.001))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(Color.appSurface(for: colorScheme).opacity(0.001))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
        )
    }
    
    private func billingCycleText(_ cycle: Int) -> String {
        switch cycle {
        case 1: return "billing_monthly_label".localized()
        case 2: return "billing_yearly_label".localized()
        case 3: return "billing_weekly_label".localized()
        default: return "billing_monthly_label".localized()
        }
    }
    
    @ViewBuilder
    private func brandIcon(_ name: String) -> some View {
        let map: [String: (icon: String, color: Color)] = [
            "netflix":  ("netflix",  Color(hex: "E50914")),
            "spotify":  ("spotify",  Color(hex: "1DB954")),
            "youtube":  ("youtube",  Color(hex: "FF0000")),
            "google":   ("google",   Color(hex: "4285F4")),
            "amazon":   ("amazon",   Color(hex: "00A8E1")),
            "hbo max":  ("hbomax",   Color(hex: "5A2E81")),
            "cursor":   ("cursor",   Color.primary),
            "claude":   ("claude",   Color(hex: "E56038")),
        ]
        if let info = map[name.lowercased()] {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(info.color.opacity(0.3), lineWidth: 1)
                    .frame(width: 36, height: 36)
                BrandIconView(name: info.icon, color: info.color)
                    .frame(width: 20, height: 20)
            }
        } else {
            let brandColor = getBrandColor(name)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(brandColor.opacity(0.3), lineWidth: 1)
                    .frame(width: 36, height: 36)
                Text(name.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(brandColor)
            }
        }
    }
    
    private func getBrandColor(_ name: String) -> Color {
        let lowered = name.lowercased()
        if lowered.contains("netflix") { return .netflixRed }
        if lowered.contains("spotify") { return .spotifyGreen }
        if lowered.contains("adobe")   { return .adobeRed }
        if lowered.contains("amazon")  { return Color(hex: "00A8E1") }
        return Color.dynamicColor(from: name)
    }
}
