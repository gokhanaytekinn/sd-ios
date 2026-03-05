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
                ProgressView()
                    .tint(.primaryBlue)
            } else {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text(NSLocalizedString("subscriptions", comment: ""))
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
                            Text(NSLocalizedString("total_monthly", comment: ""))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            
                            Text(CurrencyFormatter.formatAmount(viewModel.stats.totalMonthlyCost, currencyCode: currency))
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(viewModel.activeSubscriptions.count) \(NSLocalizedString("active", comment: "").lowercased())")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primaryBlue)
                        }
                    }
                    .padding(16)
                    .background(Color.appSurface(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    // Subscription Limit (Free Plan)
                    if authViewModel.tier == 1 {
                        Spacer().frame(height: 12)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("\(viewModel.activeSubscriptions.count)/5 \(NSLocalizedString("subscriptions", comment: ""))")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                Spacer()
                                Text(NSLocalizedString("free_plan", comment: ""))
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
                                        .frame(width: geo.size.width * min(CGFloat(viewModel.activeSubscriptions.count) / 5.0, 1.0), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer().frame(height: 16)
                    
                    // Tabs
                    HStack(spacing: 0) {
                        tabButton(NSLocalizedString("active", comment: ""), tag: 0, count: viewModel.activeSubscriptions.count)
                        tabButton(NSLocalizedString("suspicious", comment: ""), tag: 1, count: viewModel.suspiciousSubscriptions.count)
                        tabButton(NSLocalizedString("cancelled", comment: ""), tag: 2, count: viewModel.cancelledSubscriptions.count)
                    }
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
    }
    
    private var currentTabSubscriptions: [Subscription] {
        switch selectedTab {
        case 0: return viewModel.activeSubscriptions
        case 1: return viewModel.suspiciousSubscriptions
        case 2: return viewModel.cancelledSubscriptions
        default: return []
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            
            let text: String
            switch selectedTab {
            case 0:
                text = NSLocalizedString("no_active_subscriptions", comment: "")
            case 1:
                text = NSLocalizedString("no_suspicious_subscriptions", comment: "")
            default:
                text = NSLocalizedString("no_cancelled_subscriptions", comment: "")
            }
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func tabButton(_ title: String, tag: Int, count: Int) -> some View {
        Button(action: { selectedTab = tag }) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: selectedTab == tag ? .bold : .medium))
                    
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(selectedTab == tag ? Color.primaryBlue.opacity(0.2) : Color.appSurfaceVariant(for: colorScheme))
                            .cornerRadius(8)
                    }
                }
                .foregroundColor(selectedTab == tag ? .primaryBlue : Color.appOnSurfaceVariant(for: colorScheme))
                
                Rectangle()
                    .fill(selectedTab == tag ? Color.primaryBlue : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
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
