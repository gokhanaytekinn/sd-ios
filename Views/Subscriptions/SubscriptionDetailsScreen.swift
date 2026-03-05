import SwiftUI

struct SubscriptionDetailsScreen: View {
    let subscriptionId: String
    let onBack: () -> Void
    let onEdit: (Subscription) -> Void
    
    @StateObject private var viewModel = SubscriptionsViewModel()
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    @State private var subscription: Subscription?
    @State private var showDeleteDialog = false
    @State private var showCancelDialog = false
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
                Text(NSLocalizedString("subscription_details", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                
                if let sub = subscription {
                    Button(action: { onEdit(sub) }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(.primaryBlue)
                    }
                } else {
                    Color.clear.frame(width: 24, height: 24)
                }
            }
            .padding(16)
            
            if isLoading {
                Spacer()
                ProgressView().tint(.primaryBlue)
                Spacer()
            } else if let sub = subscription {
                ScrollView {
                    VStack(spacing: 16) {
                        // Main Card
                        VStack(spacing: 16) {
                            // Icon & Name
                            ZStack {
                                Circle()
                                    .fill(Color.primaryBlue.opacity(0.1))
                                    .frame(width: 64, height: 64)
                                
                                Text(sub.name.prefix(1).uppercased())
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primaryBlue)
                            }
                            
                            Text(sub.name)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            Text(CurrencyFormatter.formatAmount(sub.cost, currencyCode: currency))
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.primaryBlue)
                            
                            // Billing Info
                            HStack(spacing: 24) {
                                infoBlock(
                                    title: NSLocalizedString("billing_cycle", comment: ""),
                                    value: billingCycleText(sub.billingCycle)
                                )
                                
                                infoBlock(
                                    title: NSLocalizedString("category", comment: ""),
                                    value: NSLocalizedString(sub.category ?? "category_other", comment: "")
                                )
                            }
                            
                            if let nextDate = sub.getNextRenewalDate() {
                                let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextDate)).day ?? 0
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primaryBlue)
                                    
                                    Text(String(format: NSLocalizedString("days_left_for_renewal", comment: ""), days))
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.primaryBlue.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color.appSurface(for: colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        
                        // Reminder
                        HStack(spacing: 12) {
                            Image(systemName: sub.reminderEnabled ? "bell.fill" : "bell.slash.fill")
                                .foregroundColor(sub.reminderEnabled ? .primaryBlue : Color.appOnSurfaceVariant(for: colorScheme))
                            
                            Text(sub.reminderEnabled ?
                                 NSLocalizedString("set_reminder", comment: "") :
                                 NSLocalizedString("turn_off_reminder", comment: ""))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.appSurface(for: colorScheme))
                        .cornerRadius(12)
                        
                        // Participants
                        if let participants = sub.participants, !participants.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("participants", comment: ""))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                
                                ForEach(participants) { p in
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(.primaryBlue)
                                        
                                        VStack(alignment: .leading) {
                                            Text(p.name ?? p.email)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                                            Text(p.status)
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.appSurface(for: colorScheme))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Actions
                        VStack(spacing: 8) {
                            if sub.status == 3 {
                                Button(action: {
                                    viewModel.reactivateSubscription(id: sub.id)
                                    onBack()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text(NSLocalizedString("reactivate_subscription", comment: ""))
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.successColor)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.successColor, lineWidth: 1.5)
                                    )
                                }
                            } else {
                                Button(action: { showCancelDialog = true }) {
                                    HStack {
                                        Image(systemName: "xmark.circle")
                                        Text(NSLocalizedString("cancel_subscription_btn", comment: ""))
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.warningColor)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.warningColor, lineWidth: 1.5)
                                    )
                                }
                            }
                            
                            Button(action: { showDeleteDialog = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text(NSLocalizedString("delete_subscription", comment: ""))
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.errorColor)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.errorColor, lineWidth: 1.5)
                                )
                            }
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                Spacer()
                Text(NSLocalizedString("subscription_id_not_found", comment: ""))
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                Spacer()
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear { loadSubscription() }
        .alert(NSLocalizedString("cancel_subscription", comment: ""), isPresented: $showCancelDialog) {
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("confirm", comment: ""), role: .destructive) {
                viewModel.cancelSubscription(id: subscriptionId)
                onBack()
            }
        }
        .alert(NSLocalizedString("delete_subscription", comment: ""), isPresented: $showDeleteDialog) {
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                viewModel.deleteSubscription(id: subscriptionId)
                onBack()
            }
        } message: {
            Text(NSLocalizedString("delete_subscription_confirm_desc", comment: ""))
        }
    }
    
    private func loadSubscription() {
        Task {
            isLoading = true
            let result = await SubscriptionRepository.shared.getSubscription(id: subscriptionId)
            if case .success(let sub) = result {
                subscription = sub
            }
            isLoading = false
        }
    }
    
    private func infoBlock(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
        }
    }
    
    private func billingCycleText(_ cycle: BillingCycle) -> String {
        switch cycle {
        case .monthly: return NSLocalizedString("billing_monthly_label", comment: "")
        case .yearly: return NSLocalizedString("billing_yearly_label", comment: "")
        case .weekly: return NSLocalizedString("billing_weekly_label", comment: "")
        case .quarterly: return NSLocalizedString("period_monthly", comment: "")
        }
    }
}
