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
    @State private var errorMessage: String?
    @State private var participantToRemove: InvitationParticipant?
    @State private var showParticipantRemoveDialog = false
    
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
                SubscriptionDetailsSkeleton()
            } else if let sub = subscription {
                ScrollView {
                    VStack(spacing: 20) {
                        // Icon
                        brandIconDetailed(name: sub.name)
                            .padding(.top, 20)
                        
                        // Name & Price
                        VStack(spacing: 8) {
                            Text(sub.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(CurrencyFormatter.formatAmount(sub.cost, currencyCode: sub.currency))
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundColor(.primaryBlue)
                                
                                Text("/ \(billingCycleText(sub.billingCycle))")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                        }
                        
                        // Free Trial Label
                        if sub.isFreeTrial == true {
                            HStack(spacing: 8) {
                                Image(systemName: "gift.fill")
                                Text("free_trial".localized())
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "4CAF50"))
                            .cornerRadius(20)
                        }
                        
                        // Reminder Label
                        if sub.reminderEnabled {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.fill")
                                Text("reminder_on".localized())
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.clear)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appOutline(for: colorScheme), lineWidth: 1))
                        }
                        
                        // Summary Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                // Removed redundant category icon
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sub.name)
                                        .font(.system(size: 16, weight: .bold))
                                    Text("\((sub.category ?? "category_other").localized()) • \(billingCycleText(sub.billingCycle))")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(CurrencyFormatter.formatAmount(sub.cost, currencyCode: sub.currency))
                                        .font(.system(size: 16, weight: .bold))
                                    if let nextDate = sub.getNextRenewalDate() {
                                        if sub.billingCycle == .monthly,
                                           let billingDay = sub.billingDay {
                                            Text(DateUtils.formatMonthlyRenewal(day: billingDay, language: LanguagePreferences.shared.selectedLanguage))
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                        } else {
                                            Text(nextDate, format: .dateTime.day().month().year())
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                        }
                                    }
                                }
                            }
                            
                            if let nextDate = sub.getNextRenewalDate() {
                                let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextDate)).day ?? 0
                                let totalDays = sub.billingCycle == .monthly ? 30.0 : 365.0
                                let progress = max(0.0, min(1.0, 1.0 - (Double(days) / totalDays)))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String(format: "days_left_for_renewal".localized(), days))
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
                        .background(Color.clear)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appOutline(for: colorScheme), lineWidth: 1))
                        
                        // Info Grid
                        HStack(spacing: 16) {
                            gridBlock(title: "subscription_price".localized(), value: CurrencyFormatter.formatAmount(sub.cost, currencyCode: sub.currency))
                            gridBlock(title: "renewal_cycle".localized(), value: nextRenewalDayMonth(sub))
                        }
                        
                        // Actions Group
                        HStack(spacing: 12) {
                            actionButton(icon: sub.reminderEnabled ? "bell.slash" : "bell", 
                                       title: sub.reminderEnabled ? "turn_off".localized() : "set_reminder".localized(), 
                                       color: Color.appOnSurfaceVariant(for: colorScheme), 
                                       action: toggleReminder)
                            
                            actionButton(icon: "pencil", title: "edit_plan".localized(), color: Color.appOnBackground(for: colorScheme)) {
                                onEdit(sub)
                            }
                        }
                        
                        // Primary Action (Cancel or Reactivate)
                        if sub.status != 3 {
                            Button(action: { showCancelDialog = true }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("cancel_subscription_btn".localized())
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.errorColor)
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                                .background(Color.appSurface(for: colorScheme).opacity(0.001))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                                )
                            }
                        } else {
                            Button(action: reactivateSubscription) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("reactivate_subscription".localized())
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "4CAF50"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                                .background(Color.appSurface(for: colorScheme).opacity(0.001))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Delete Button
                        Button(action: { showDeleteDialog = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                Text("delete_subscription".localized())
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.errorColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color.appSurface(for: colorScheme).opacity(0.001))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                            )
                        }
                        
                        // Participants Section
                        if let participants = sub.participants, !participants.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                    Text("participants".localized())
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                                }
                                .padding(.top, 8)
                                
                                VStack(spacing: 8) {
                                    ForEach(participants) { participant in
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.appSurface(for: colorScheme))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                                )
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                if let name = participant.name {
                                                    Text(name)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                                                }
                                                Text(participant.email)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                            }
                                            
                                            Spacer()
                                            
                                            StatusIcon(status: participant.status)
                                            
                                            if sub.isOwner {
                                                Button(action: {
                                                    participantToRemove = participant
                                                    showParticipantRemoveDialog = true
                                                }) {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.errorColor)
                                                        .padding(8)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.clear)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(1.0), lineWidth: 1))
                                    }
                                }
                            }
                        }
                        
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                Spacer()
                Text("subscription_id_not_found".localized())
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                Spacer()
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear { loadSubscription() }
        .alert("cancel_subscription".localized(), isPresented: $showCancelDialog) {
            Button("cancel".localized(), role: .cancel) {}
            Button("confirm".localized(), role: .destructive) {
                cancelSubscription()
            }
        }
        .alert("delete_subscription".localized(), isPresented: $showDeleteDialog) {
            Button("cancel".localized(), role: .cancel) {}
            Button("delete".localized(), role: .destructive) {
                deleteSubscription()
            }
        } message: {
            Text("delete_subscription_confirm_desc".localized())
        }
        .alert("remove_participant_title".localized(), isPresented: $showParticipantRemoveDialog) {
            Button("cancel".localized(), role: .cancel) { participantToRemove = nil }
            Button("remove".localized(), role: .destructive) {
                if let participant = participantToRemove {
                    removeParticipant(email: participant.email)
                }
            }
        } message: {
            if let participant = participantToRemove {
                Text(String(format: "remove_participant_confirm".localized(), participant.name ?? participant.email))
            }
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
    
    private func toggleReminder() {
        guard let sub = subscription else { return }
        Task {
            let updatedSub = Subscription(
                id: sub.id,
                name: sub.name,
                cost: sub.cost,
                currency: sub.currency,
                billingCycle: sub.billingCycle,
                billingDay: sub.billingDay,
                billingMonth: sub.billingMonth,
                category: sub.category,
                icon: sub.icon,
                status: sub.status,
                isSuspicious: sub.isSuspicious,
                tier: sub.tier,
                reminderEnabled: !sub.reminderEnabled,
                jointEmails: sub.jointEmails,
                isOwner: sub.isOwner,
                isFreeTrial: sub.isFreeTrial,
                participants: sub.participants
            )
            
            let request = SubscriptionUpdateRequest(
                name: updatedSub.name,
                icon: updatedSub.icon,
                category: updatedSub.category,
                tier: updatedSub.tier,
                amount: updatedSub.cost,
                currency: updatedSub.currency,
                billingCycle: updatedSub.billingCycle.rawValue,
                billingDay: updatedSub.billingDay,
                billingMonth: updatedSub.billingMonth,
                reminderEnabled: updatedSub.reminderEnabled,
                isFreeTrial: updatedSub.isFreeTrial,
                jointEmails: updatedSub.jointEmails
            )
            
            let result = await SubscriptionRepository.shared.updateSubscription(id: sub.id, request)
            if case .success(let newSub) = result {
                self.subscription = newSub
            }
        }
    }
    
    private func cancelSubscription() {
        Task {
            let result = await SubscriptionRepository.shared.cancelSubscription(id: subscriptionId)
            if case .success = result {
                onBack()
            }
        }
    }
    
    private func reactivateSubscription() {
        Task {
            isLoading = true
            let result = await SubscriptionRepository.shared.reactivateSubscription(id: subscriptionId)
            if case .success = result {
                // Success: Reload the subscription to get updated status and cleared end date
                loadSubscription()
            } else if case .failure(let err) = result {
                self.errorMessage = err.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func deleteSubscription() {
        Task {
            let result = await SubscriptionRepository.shared.deleteSubscription(id: subscriptionId)
            if case .success = result {
                onBack()
            }
        }
    }
    
    private func removeParticipant(email: String) {
        Task {
            isLoading = true
            let result = await SubscriptionRepository.shared.removeParticipant(subscriptionId: subscriptionId, email: email)
            if case .success = result {
                loadSubscription()
            } else if case .failure(let err) = result {
                self.errorMessage = err.localizedDescription
            }
            isLoading = false
            participantToRemove = nil
        }
    }
    
    struct StatusIcon: View {
        let status: String
        
        var body: some View {
            let config = statusConfig
            Image(systemName: config.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(config.color)
        }
        
        private var statusConfig: (icon: String, color: Color) {
            switch status {
            case "ACCEPTED":
                return ("checkmark.circle.fill", .green)
            case "REJECTED":
                return ("xmark.circle.fill", .red)
            default:
                return ("clock.fill", .gray)
            }
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
        .background(Color.clear)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme), lineWidth: 1))
    }
    
    private func actionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(Color.appSurface(for: colorScheme).opacity(0.001))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
            )
        }
    }
    
    private func nextRenewalDayMonth(_ sub: Subscription) -> String {
        if sub.billingCycle == .monthly,
           let billingDay = sub.billingDay {
            return DateUtils.formatMonthlyRenewal(day: billingDay, language: LanguagePreferences.shared.selectedLanguage)
        }
        
        guard let nextDate = sub.getNextRenewalDate() else { return "-" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LanguagePreferences.shared.selectedLanguage)
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: nextDate)
    }
    
    private func billingCycleText(_ cycle: BillingCycle) -> String {
        switch cycle {
        case .monthly: return "billing_monthly_label".localized()
        case .yearly: return "billing_yearly_label".localized()
        case .weekly: return "billing_weekly_label".localized()
        case .quarterly: return "period_monthly".localized()
        }
    }
    
    @ViewBuilder
    private func brandIconDetailed(name: String) -> some View {
        if let info = getBrandIconInfo(name) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(info.color.opacity(0.5), lineWidth: 1)
                    .background(Color.clear)
                    .frame(width: 120, height: 120)
                BrandIconView(name: info.icon, color: info.color)
                    .frame(width: 60, height: 60)
            }
        } else {
            let brandColor = getBrandColor(name)
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(brandColor.opacity(0.5), lineWidth: 1)
                    .background(Color.clear)
                    .frame(width: 120, height: 120)
                Text(name.prefix(1).uppercased())
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(brandColor)
            }
        }
    }
    
    private func getBrandIconInfo(_ name: String) -> (icon: String, color: Color)? {
        let map: [String: (String, Color)] = [
            "netflix":  ("netflix",  Color(hex: "E50914")),
            "spotify":  ("spotify",  Color(hex: "1DB954")),
            "youtube":  ("youtube",  Color(hex: "FF0000")),
            "google":   ("google",   Color(hex: "4285F4")),
            "amazon":   ("amazon",   Color(hex: "00A8E1")),
            "hbo max":  ("hbomax",   Color(hex: "5A2E81")),
            "cursor":   ("cursor",   Color.primary),
            "claude":   ("claude",   Color(hex: "E56038")),
        ]
        return map[name.lowercased()]
    }
    
    private func getBrandColor(_ name: String) -> Color {
        let lowered = name.lowercased()
        if lowered.contains("netflix") { return .netflixRed }
        if lowered.contains("spotify") { return .spotifyGreen }
        if lowered.contains("adobe")   { return .adobeRed }
        if lowered.contains("youtube") { return Color(hex: "FF0000") }
        if lowered.contains("amazon")  { return Color(hex: "00A8E1") }
        return Color.dynamicColor(from: name)
    }
}
