import SwiftUI
import AuthenticationServices

// MARK: - Skeleton Tools
struct SkeletonModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.3 : 0.7)
            .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    func skeleton() -> some View {
        self.modifier(SkeletonModifier())
    }
    
    func withErrorDialog(errorMessage: Binding<String?>, onDismiss: @escaping () -> Void = {}) -> some View {
        self.modifier(SDErrorDialog(errorMessage: errorMessage, onDismiss: onDismiss))
    }
}

struct SkeletonCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 12)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
        )
        .skeleton()
    }
}

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
                                .font(.sdBodyBold)
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            if isJoint || (subscription.participants?.count ?? 0) > 0 {
                                Image(systemName: "person.2.fill")
                                    .font(.sdSmallBold)
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                        
                        Text(categoryText)
                            .font(.sdSmall)
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    }
                    
                    Spacer()
                    
                    // Cost & Date
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(CurrencyFormatter.formatAmount(subscription.cost, currencyCode: subscription.currency))
                            .font(.sdBodyBold)
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        if showDate {
                            if subscription.billingCycle == .monthly, 
                               let billingDay = subscription.billingDay {
                                Text(DateUtils.formatMonthlyRenewal(day: billingDay, language: LanguagePreferences.shared.selectedLanguage))
                                    .font(.sdSmall)
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            } else if subscription.billingCycle == .yearly,
                                      let billingDay = subscription.billingDay,
                                      let billingMonth = subscription.billingMonth {
                                Text(DateUtils.formatYearlyRenewal(day: billingDay, month: billingMonth, language: LanguagePreferences.shared.selectedLanguage))
                                    .font(.sdSmall)
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            } else if let nextDate = subscription.getNextRenewalDate() {
                                Text(DateUtils.formatDate(nextDate))
                                    .font(.sdSmall)
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                        } else if showCountdown, let nextDate = subscription.getNextRenewalDate() {
                            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextDate)).day ?? -1
                            Text(daysText(days))
                                .font(.sdSmallMedium)
                                .foregroundColor(days <= 3 && days >= 0 ? .errorColor : Color.appOnSurfaceVariant(for: colorScheme))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .background(Color.appSurface(for: colorScheme).opacity(0.001))
            }
        }
        .buttonStyle(.plain)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var brandIcon: some View {
        if let info = getBrandIconInfo(subscription.name) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(info.color.opacity(0.3), lineWidth: 1)
                    .frame(width: 36, height: 36)
                BrandIconView(name: info.icon, color: info.color)
                    .frame(width: 20, height: 20)
            }
        } else {
            let brandColor = getBrandColor(subscription.name)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(brandColor.opacity(0.3), lineWidth: 1)
                    .frame(width: 36, height: 36)
                Text(subscription.name.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(brandColor)
            }
        }
    }
    
    private func getBrandIconInfo(_ name: String) -> (icon: String, color: Color)? {
        let lowered = name.lowercased()
        let orderedBrandMap: [(key: String, info: (String, Color))] = [
            ("hbo max", ("hbomax", Color(hex: "5A2E81"))),
            ("netflix", ("netflix", Color(hex: "E50914"))),
            ("spotify", ("spotify", Color(hex: "1DB954"))),
            ("youtube", ("youtube", Color(hex: "FF0000"))),
            ("google", ("google", Color(hex: "4285F4"))),
            ("amazon", ("amazon", Color(hex: "00A8E1"))),
            ("cursor", ("cursor", Color.primary)),
            ("claude", ("claude", Color(hex: "E56038"))),
        ]
        return orderedBrandMap.first(where: { lowered.contains($0.key) })?.info
    }
    
    private var categoryText: String {
        let localizedCategory = (subscription.category ?? "category_other").localized()
        let cycleText = billingCycleDescription(for: subscription)
        
        let category = subscription.category ?? "category_other"
        if category == "Other" || category == "Diğer" || category == "category_other" {
            return cycleText
        }
        return "\(localizedCategory) • \(cycleText)"
    }

    private func billingCycleDescription(for sub: Subscription) -> String {
        let isTurkish = LanguagePreferences.shared.selectedLanguage.lowercased().hasPrefix("tr")
        switch sub.billingCycle {
        case .daily:
            return isTurkish ? "Her gün" : "Every day"
        case .weekly:
            if let day = sub.billingDay {
                return isTurkish ? "Haftanın \(day).günü" : "Day \(day) of week"
            }
            return "billing_weekly_label".localized()
        case .monthly:
            return "billing_monthly_label".localized()
        case .yearly:
            return "billing_yearly_label".localized()
        case .quarterly:
            return "period_monthly".localized()
        }
    }
    
    private func daysText(_ days: Int) -> String {
        switch days {
        case 0: return "today".localized()
        case 1: return "tomorrow".localized()
        default: return "\(days) \("days_left".localized())"
        }
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

// MARK: - Error Dialog
struct ErrorDialog: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.sdSubheadline)
                .foregroundColor(.errorColor)
            
            Text("error".localized())
                .font(.sdSubheadlineSemibold)
            
            Text(message)
                .font(.sdCaption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: onDismiss) {
                Text("close".localized())
                    .font(.sdBodyBold)
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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    Text("loading".localized())
                        .font(.sdSubheadline)
                        .foregroundColor(.primaryBlue)
                } else {
                    Text(title)
                        .font(.sdBodyBold)
                        .foregroundColor(isEnabled ? .primaryBlue : .primaryBlue.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(Color.appSurface(for: colorScheme).opacity(0.001))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEnabled ? Color.appOutline(for: colorScheme).opacity(1) : Color.appOutline(for: colorScheme).opacity(0.5), lineWidth: 1)
            )
        }
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - SD Outlined TextField
struct SDOutlinedTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var trailingIcon: String? = nil
    var leadingIcon: String? = nil
    var onTrailingIconTap: (() -> Void)? = nil
    
    // Focus management
    var focusBinding: FocusState<String?>.Binding? = nil
    var focusValue: String? = nil
    
    @State private var showPassword = false
    @FocusState private var internalFocus: String?
    
    @Environment(\.colorScheme) var colorScheme
    
    private var isFocused: Bool {
        if let binding = focusBinding {
            return binding.wrappedValue == focusValue
        }
        return internalFocus == focusValue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.sdCaptionMedium)
                .foregroundColor(Color.appOnBackground(for: colorScheme))
            
            HStack(spacing: 12) {
                if let icon = leadingIcon {
                    Image(systemName: icon)
                        .font(.sdSubheadline)
                        .foregroundColor(isFocused ? .primaryBlue : Color.appOnBackground(for: colorScheme).opacity(0.4))
                        .frame(width: 24)
                }

                Group {
                    if isSecure && !showPassword {
                        if let focusBinding = focusBinding {
                            SecureField(placeholder, text: $text)
                                .focused(focusBinding, equals: focusValue)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.none)
                                .onSubmit { onTrailingIconTap?() }
                        } else {
                            SecureField(placeholder, text: $text)
                                .focused($internalFocus, equals: focusValue)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.none)
                                .onSubmit { onTrailingIconTap?() }
                        }
                    } else {
                        if let focusBinding = focusBinding {
                            TextField(placeholder, text: $text)
                                .keyboardType(keyboardType)
                                .focused(focusBinding, equals: focusValue)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.none)
                                .onSubmit { onTrailingIconTap?() }
                        } else {
                            TextField(placeholder, text: $text)
                                .keyboardType(keyboardType)
                                .focused($internalFocus, equals: focusValue)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.none)
                                .onSubmit { onTrailingIconTap?() }
                        }
                    }
                }
                
                if isSecure {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.5))
                    }
                } else if let icon = trailingIcon {
                    Button(action: { onTrailingIconTap?() }) {
                        Image(systemName: icon)
                            .font(.sdSubheadlineSemibold)
                            .foregroundColor(.primaryBlue)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 45)
            .background(Color.appSurface(for: colorScheme).opacity(0.001)) // Transparent background for taps
            .contentShape(Rectangle())
            .onTapGesture {
                if let binding = focusBinding {
                    binding.wrappedValue = focusValue
                } else {
                    internalFocus = focusValue
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        errorMessage != nil ? Color.errorColor :
                            isFocused ? .primaryBlue :
                            Color.appOnBackground(for: colorScheme).opacity(0.2),
                        lineWidth: isFocused || errorMessage != nil ? 2 : 1
                    )
            )
            .autocapitalization(.none)
            
            if let error = errorMessage {
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
                .font(.sdSubheadline)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.sdBody)
                .foregroundColor(Color.appOnBackground(for: colorScheme))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.primaryBlue)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.001)) // Use nearly transparent black instead of clear for better hit testing
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
        )
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
                    .font(.sdSubheadline)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.sdBody)
                        .foregroundColor(textColor ?? Color.appOnBackground(for: colorScheme))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.sdSmall)
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.sdSmallSemibold)
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.black.opacity(0.001)) // Use nearly transparent black instead of clear
            .contentShape(Rectangle())
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Google Sign In Button
struct GoogleSignInButton: View {
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "g.circle.fill")
                    .font(.sdSubheadline)
                
                Text("sign_in_with_google".localized())
                    .font(.sdBodyBold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(Color.appSurface(for: colorScheme).opacity(0.001))
            .foregroundColor(Color.appOnBackground(for: colorScheme))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
            )
}
    }
}

// MARK: - Apple Sign In Button
struct AppleSignInButton: View {
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            action()
        } onCompletion: { result in
            // Logic handled in ViewModel via coordinator
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(maxWidth: .infinity)
        .frame(height: 45)
        .cornerRadius(12)
    }
}

// MARK: - SDErrorDialog
struct SDErrorDialog: ViewModifier {
    @Binding var errorMessage: String?
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { if !$0 { onDismiss() } }
            )) {
                Alert(
                    title: Text(NSLocalizedString("error", comment: "")),
                    message: Text(errorMessage ?? ""),
                    dismissButton: .default(Text(NSLocalizedString("ok", comment: ""))) {
                        onDismiss()
                    }
                )
            }
    }
}
// MARK: - Glass Card (Modern Cam Efektli Kart)
struct GlassCard<Content: View>: View {
    let content: Content
    var gradientColors: [Color] = [.primaryBlue.opacity(0.6), .primaryBlue.opacity(0.1)]
    
    @Environment(\.colorScheme) var colorScheme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    // Hafif Cam Efekti
                    BlurView(style: colorScheme == .dark ? .systemThinMaterialDark : .systemThinMaterialLight)
                    
                    // İç Gradyan Aydınlatma
                    LinearGradient(
                        colors: [.white.opacity(0.05), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(24)
            .overlay(
                // Gradyan Bordür (Premium Görünüm)
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .clear, .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Premium Button (Gelişmiş Etkileşimli Buton)
struct PremiumButton: View {
    let title: String
    var icon: String? = nil
    var backgroundColor: Color = .primaryBlue
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    Text("loading".localized())
                        .font(.sdSubheadline)
                        .foregroundColor(.white)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(title)
                        .font(.sdBodyBold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isEnabled ? backgroundColor : backgroundColor.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Dashboard Skeleton
