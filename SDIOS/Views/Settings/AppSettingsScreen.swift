import SwiftUI

struct AppSettingsScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    let onNavigateToHelpCenter: () -> Void
    let onNavigateToPrivacyPolicy: () -> Void
    let onNavigateToPremium: () -> Void
    let onLogout: () -> Void
    
    @AppStorage("selectedCurrency") private var selectedCurrency: Int = 1
    @State private var showLanguageDialog = false
    @State private var showCurrencyDialog = false
    @State private var showDeleteAccountDialog = false
    @State private var notificationsEnabled: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    Text("settings".localized())
                        .font(.sdHeadline)
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    Spacer().frame(height: 24)
                    
                    // Account Section
                    sectionHeader("account".localized())
                    
                    VStack(spacing: 8) {
                        // Profile Card
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryBlue.opacity(0.1))
                                    .frame(width: 48, height: 48)
                                
                                Text((authViewModel.userName ?? "?").prefix(1).uppercased())
                                    .font(.sdSubheadlineSemibold)
                                    .foregroundColor(.primaryBlue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(authViewModel.userName ?? "guest_user".localized())
                                    .font(.sdBodyBold)
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                
                                Text(authViewModel.userEmail ?? "not_logged_in".localized())
                                    .font(.sdSmall)
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.clear)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                        )
                        
                        // Membership
                        SettingsNavigationItem(
                            icon: "star.fill",
                            title: "membership_type".localized(),
                            subtitle: authViewModel.tier >= 2 ? "premium_plan".localized() : "free_plan".localized(),
                            iconColor: .warningColor,
                            onTap: onNavigateToPremium
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 24)
                    
                    // Application Section
                    sectionHeader("application".localized())
                    
                    VStack(spacing: 8) {
                        SettingsToggleItem(
                            icon: "bell.fill",
                            title: "notifications".localized(),
                            isOn: $notificationsEnabled,
                            iconColor: .primaryBlue
                        )
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            authViewModel.updateNotificationSettings(enabled: newValue)
                        }
                        
                        SettingsNavigationItem(
                            icon: "dollarsign.circle.fill",
                            title: "currency".localized(),
                            subtitle: CurrencyPreferences.currencies.first(where: { $0.id == selectedCurrency })?.name,
                            iconColor: .successColor,
                            onTap: { showCurrencyDialog = true }
                        )
                        
                        SettingsToggleItem(
                            icon: "moon.fill",
                            title: "dark_mode".localized(),
                            isOn: $themeManager.isDarkMode,
                            iconColor: Color(hex: "6366F1")
                        )
                        
                        SettingsNavigationItem(
                            icon: "globe",
                            title: "language".localized(),
                            subtitle: LanguagePreferences.supportedLanguages.first(where: { $0.code == LanguagePreferences.shared.selectedLanguage })?.name,
                            iconColor: .primaryBlue,
                            onTap: { showLanguageDialog = true }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 24)
                    
                    // Support Section
                    sectionHeader("support".localized())
                    
                    VStack(spacing: 8) {
                        SettingsNavigationItem(
                            icon: "questionmark.circle.fill",
                            title: "help_center".localized(),
                            iconColor: .primaryBlue,
                            onTap: onNavigateToHelpCenter
                        )
                        
                        SettingsNavigationItem(
                            icon: "shield.fill",
                            title: "privacy_policy".localized(),
                            iconColor: .successColor,
                            onTap: onNavigateToPrivacyPolicy
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 24)
                    
                    // Logout & Delete
                    VStack(spacing: 8) {
                        SettingsNavigationItem(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "logout".localized(),
                            iconColor: .warningColor,
                            textColor: .warningColor,
                            onTap: {
                                authViewModel.logout()
                                onLogout()
                            }
                        )
                        
                        SettingsNavigationItem(
                            icon: "trash.fill",
                            title: "delete_account".localized(),
                            iconColor: .errorColor,
                            textColor: .errorColor,
                            onTap: { showDeleteAccountDialog = true }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 24)
                    
                    // Version
                    #if DEBUG
                    Text(String(format: "version".localized(), Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0") + " (debug)")
                        .font(.sdSmall)
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .center)
                    #else
                    Text(String(format: "version".localized(), Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0") + " (release)")
                        .font(.sdSmall)
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .center)
                    #endif
                    
                    Spacer().frame(height: 20)
                }
            }
        }
        .onAppear {
            notificationsEnabled = authViewModel.notificationsEnabled
        }
        .sheet(isPresented: $showLanguageDialog) {
            languageSheet
        }
        .sheet(isPresented: $showCurrencyDialog) {
            currencySheet
        }
        .alert("delete_account_confirm_title".localized(), isPresented: $showDeleteAccountDialog) {
            Button("cancel".localized(), role: .cancel) {}
            Button("delete".localized(), role: .destructive) {
                authViewModel.deleteAccount()
                onLogout()
            }
        } message: {
            Text("delete_account_confirm_desc".localized())
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.sdLabelSemibold)
            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            .tracking(1)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
    }
    
    private var languageSheet: some View {
        NavigationStack {
            List(LanguagePreferences.supportedLanguages) { lang in
                Button(action: {
                    LanguagePreferences.shared.selectedLanguage = lang.code
                    showLanguageDialog = false
                }) {
                    HStack {
                        Text(lang.flag)
                        Text(lang.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if LanguagePreferences.shared.selectedLanguage == lang.code {
                            Image(systemName: "checkmark")
                                .foregroundColor(.primaryBlue)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .navigationTitle("select_language".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("close".localized()) {
                        showLanguageDialog = false
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private var currencySheet: some View {
        NavigationStack {
            List(CurrencyPreferences.currencies) { curr in
                Button(action: {
                    selectedCurrency = curr.id
                    showCurrencyDialog = false
                }) {
                    HStack {
                        Text(curr.symbol)
                            .font(.sdSubheadlineSemibold)
                            .frame(width: 28)
                        Text("\(curr.code) - \(curr.name)")
                            .font(.sdBody)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedCurrency == curr.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.primaryBlue)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .navigationTitle("select_currency".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("close".localized()) {
                        showCurrencyDialog = false
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
