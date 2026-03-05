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
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
            }
            .padding(16)
            
            if isLoading {
                Spacer()
                ProgressView().tint(.primaryBlue)
                Spacer()
            } else if let sub = subscription {
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appSurface(for: colorScheme))
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                            
                            Text(sub.name.prefix(1).uppercased())
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.primaryBlue)
                        }
                        .padding(.top, 20)
                        
                        // Name & Price
                        VStack(spacing: 8) {
                            Text(sub.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(CurrencyFormatter.formatAmount(sub.cost, currencyCode: currency))
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundColor(.primaryBlue)
                                
                                Text("/ \(billingCycleText(sub.billingCycle))")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                        }
                        
                        // Reminder Toggle Button
                        Button(action: { 
                            // Toggle logic (simplified)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: sub.reminderEnabled ? "bell.fill" : "bell.slash.fill")
                                Text(NSLocalizedString("reminder", comment: ""))
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "5B37B7"))
                            .cornerRadius(20)
                        }
                        
                        // Summary Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "sun.max.fill") // Placeholder for category icon
                                        .foregroundColor(.orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sub.name)
                                        .font(.system(size: 16, weight: .bold))
                                    Text("\(NSLocalizedString(sub.category ?? "category_other", comment: "")) • \(billingCycleText(sub.billingCycle))")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(CurrencyFormatter.formatAmount(sub.cost, currencyCode: currency))
                                        .font(.system(size: 16, weight: .bold))
                                    if let nextDate = sub.getNextRenewalDate() {
                                        Text(nextDate, format: .dateTime.day().month().year())
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                    }
                                }
                            }
                            
                            if let nextDate = sub.getNextRenewalDate() {
                                let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextDate)).day ?? 0
                                let totalDays = sub.billingCycle == .monthly ? 30.0 : 365.0
                                let progress = max(0.0, min(1.0, 1.0 - (Double(days) / totalDays)))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String(format: NSLocalizedString("days_left_for_renewal", comment: ""), days))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                                    
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.appOutline(for: colorScheme).opacity(0.2))
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.primaryBlue)
                                                .frame(width: geo.size.width * progress)
                                        }
                                    }
                                    .frame(height: 6)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.appSurface(for: colorScheme).opacity(0.5))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appOutline(for: colorScheme).opacity(0.2), lineWidth: 1))
                        
                        // Info Grid
                        HStack(spacing: 16) {
                            gridBlock(title: NSLocalizedString("subscription_price", comment: ""), value: CurrencyFormatter.formatAmount(sub.cost, currencyCode: currency))
                            gridBlock(title: NSLocalizedString("renewal_cycle", comment: ""), value: nextRenewalDayMonth(sub))
                        }
                        
                        // Actions Group
                        HStack(spacing: 12) {
                            actionButton(icon: "bell.slash", title: NSLocalizedString("turn_off", comment: ""), color: Color.appOnSurfaceVariant(for: colorScheme)) {
                                // Action
                            }
                            actionButton(icon: "pencil", title: NSLocalizedString("edit_plan", comment: ""), color: Color.appOnBackground(for: colorScheme)) {
                                onEdit(sub)
                            }
                        }
                        
                        // Cancel Button
                        Button(action: { showCancelDialog = true }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text(NSLocalizedString("cancel_subscription_btn", comment: ""))
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.errorColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.errorColor.opacity(0.5), lineWidth: 1))
                        }
                        
                        // Delete Button
                        Button(action: { showDeleteDialog = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                Text(NSLocalizedString("delete_subscription", comment: ""))
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.errorColor)
                        }
                        .padding(.top, 8)
                        
                        Spacer().frame(height: 40)
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
    
    private func gridBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface(for: colorScheme).opacity(0.5))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(0.2), lineWidth: 1))
    }
    
    private func actionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.appSurface(for: colorScheme))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
        }
    }
    
    private func nextRenewalDayMonth(_ sub: Subscription) -> String {
        guard let nextDate = sub.getNextRenewalDate() else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: nextDate)
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
