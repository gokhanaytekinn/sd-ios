import SwiftUI

struct SubscriptionsListScreen: View {
    @StateObject private var viewModel = SubscriptionsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let onNavigateToAddSubscription: () -> Void
    let onNavigateToSubscriptionDetail: (String) -> Void
    
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack(spacing: 8) {
                    Spacer().frame(height: 100)
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
                    
                    // Subscription Limit (Free Plan)
                    if authViewModel.tier == 1 {
                        Spacer().frame(height: 12)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("\(viewModel.allSubscriptions.count)/5 \("subscriptions".localized())")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
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
                                        .fill(Color.primaryBlue)
                                        .frame(width: geo.size.width * min(CGFloat(viewModel.allSubscriptions.count) / 5.0, 1.0), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer().frame(height: 16)
                    
                    // Tabs
                    HStack(spacing: 0) {
                        tabButton("active".localized(), tag: 0)
                        tabButton("pending_approve".localized(), tag: 1)
                        tabButton("cancelled".localized(), tag: 2)
                    }
                    .background(Color.appSurface(for: colorScheme))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 12)
                    
                    // Pending Invitations
                    if !viewModel.invitations.isEmpty && selectedTab == 0 {
                        VStack(spacing: 8) {
                            ForEach(viewModel.invitations) { invitation in
                                invitationCard(invitation)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 12)
                    }
                    
                    // Subscription List
                    ScrollView {
                        VStack(spacing: 8) {
                            let subs = currentTabSubscriptions
                            if subs.isEmpty {
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
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadSubscriptions()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshData"))) { _ in
            viewModel.loadSubscriptions()
        }
    }
    
    private var currentTabSubscriptions: [Subscription] {
        switch selectedTab {
        case 0: return viewModel.activeSubscriptions
        case 1: return viewModel.suspiciousSubscriptions
        case 2: return viewModel.cancelledSubscriptions
        default: return []
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
                .foregroundColor(selectedTab == tag ? .black : Color.appOnSurfaceVariant(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == tag ? Color.successColor : Color.clear)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func invitationCard(_ invitation: SubscriptionInvitation) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(invitation.subscriptionName ?? "")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Text(invitation.ownerEmail ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: { viewModel.rejectInvitation(id: invitation.id) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.errorColor)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(Color.errorColor, lineWidth: 1))
                }
                
                Button(action: { viewModel.acceptInvitation(id: invitation.id) }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.successColor)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(Color.successColor, lineWidth: 1))
                }
            }
        }
        .padding(12)
        .background(Color.primaryBlue.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
