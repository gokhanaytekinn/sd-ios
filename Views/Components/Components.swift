import SwiftUI

// MARK: - Subscription Card
struct SubscriptionCard: View {
    let subscription: Subscription
    var currency: Int = 1
    var showDate: Bool = false
    var showCountdown: Bool = false
    var isJoint: Bool = false
    var onTap: () -> Void = {}
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack {
                    // Icon
                    brandIcon
                    
                    Spacer().frame(width: 16)
                    
                    // Name & Category
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(subscription.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            if isJoint || (subscription.participants?.count ?? 0) > 0 {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                        
                        Text(categoryText)
                            .font(.system(size: 12))
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    }
                    
                    Spacer()
                    
                    // Cost & Date
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(CurrencyFormatter.formatAmount(subscription.cost, currencyCode: currency))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        if showDate, let nextDate = subscription.getNextRenewalDate() {
                            Text(DateUtils.formatDate(nextDate))
                                .font(.system(size: 12))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                        } else if showCountdown, let nextDate = subscription.getNextRenewalDate() {
                            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextDate)).day ?? -1
                            Text(daysText(days))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(days <= 3 && days >= 0 ? .errorColor : Color.appOnSurfaceVariant(for: colorScheme))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appOutline(for: colorScheme).opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var brandIcon: some View {
        let brandColor = getBrandColor(subscription.name)
        return ZStack {
            Circle()
                .fill(brandColor.opacity(0.1))
                .frame(width: 36, height: 36)
            
            Text(subscription.name.prefix(1).uppercased())
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(brandColor)
        }
    }
    
    private var categoryText: String {
        let localizedCategory = NSLocalizedString(subscription.category ?? "category_other", comment: "")
        let cycleText: String
        switch subscription.billingCycle {
        case .monthly: cycleText = NSLocalizedString("billing_monthly_label", comment: "")
        case .yearly: cycleText = NSLocalizedString("billing_yearly_label", comment: "")
        case .weekly: cycleText = NSLocalizedString("billing_weekly_label", comment: "")
        case .quarterly: cycleText = NSLocalizedString("period_monthly", comment: "")
        }
        
        let category = subscription.category ?? "category_other"
        if category == "Other" || category == "Diğer" || category == "category_other" {
            return cycleText
        }
        return "\(localizedCategory) • \(cycleText)"
    }
    
    private func daysText(_ days: Int) -> String {
        switch days {
        case 0: return NSLocalizedString("today", comment: "")
        case 1: return NSLocalizedString("tomorrow", comment: "")
        default: return "\(days) \(NSLocalizedString("days_left", comment: ""))"
        }
    }
    
    private func getBrandColor(_ name: String) -> Color {
        let lowered = name.lowercased()
        if lowered.contains("netflix") { return .netflixRed }
        if lowered.contains("spotify") { return .spotifyGreen }
        if lowered.contains("adobe") { return .adobeRed }
        return .primaryBlue
    }
}

// MARK: - Error Dialog
struct ErrorDialog: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.errorColor)
            
            Text(NSLocalizedString("error", comment: ""))
                .font(.system(size: 18, weight: .bold))
            
            Text(message)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: onDismiss) {
                Text(NSLocalizedString("close", comment: ""))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primaryBlue)
            }
        }
        .padding(24)
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

// MARK: - SD Button
struct SDButton: View {
    let title: String
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isEnabled ? Color.primaryBlue : Color.primaryBlue.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 4, y: 2)
        }
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - SD Outlined TextField
struct SDOutlinedTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var error: String?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    @State private var showPassword = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
            
            HStack {
                if isSecure && !showPassword {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
                
                if isSecure {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        error != nil ? Color.errorColor :
                            Color.appOnBackground(for: colorScheme).opacity(0.2),
                        lineWidth: 1
                    )
            )
            .autocapitalization(.none)
            
            if let error = error {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.errorColor)
            }
        }
    }
}

// MARK: - Settings Toggle Item
struct SettingsToggleItem: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let iconColor: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.primaryBlue)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.appSurface(for: colorScheme))
        .cornerRadius(12)
    }
}

// MARK: - Settings Navigation Item
struct SettingsNavigationItem: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let iconColor: Color
    var textColor: Color? = nil
    let onTap: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(textColor ?? Color.appOnBackground(for: colorScheme))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.appSurface(for: colorScheme))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
