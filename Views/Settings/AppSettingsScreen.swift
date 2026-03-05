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
                    Text(NSLocalizedString("settings", comment: ""))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    Spacer().frame(height: 24)
                    
                    // Account Section
                    sectionHeader(NSLocalizedString("account", comment: ""))
                    
                    VStack(spacing: 8) {
                        // Profile Card
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryBlue.opacity(0.1))
                                    .frame(width: 48, height: 48)
                                
                                Text((authViewModel.userName ?? "?").prefix(1).uppercased())
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primaryBlue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(authViewModel.userName ?? NSLocalizedString("guest_user", comment: ""))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                
                                Text(authViewModel.userEmail ?? NSLocalizedString("not_logged_in", comment: ""))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.appSurface(for: colorScheme))
                        .cornerRadius(12)
                        
                        // Membership
                        SettingsNavigationItem(
                            icon: "star.fill",
                            title: NSLocalizedString("membership_type", comment: ""),
                            subtitle: authViewModel.tier == 2 ? NSLocalizedString("premium_plan", comment: "") : NSLocalizedString("free_plan", comment: ""),
                            iconColor: .warningColor,
                            onTap: onNavigateToPremium
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 24)
                    
                    // Application Section
                    sectionHeader(NSLocalizedString("application", comment: ""))
                    
                    VStack(spacing: 8) {
                        SettingsToggleItem(
                            icon: "bell.fill",
                            title: NSLocalizedString("notifications", comment: ""),
                            isOn: $notificationsEnabled,
                            iconColor: .primaryBlue
                        )
                        .onChange(of: notificationsEnabled) { newValue in
                            authViewModel.updateNotificationSettings(enabled: newValue)
                        }
                        
                        SettingsNavigationItem(
                            icon: "dollarsign.circle.fill",
                            title: NSLocalizedString("currency", comment: ""),
                            subtitle: CurrencyPreferences.currencies.first(where: { $0.id == selectedCurrency })?.name,
                            iconColor: .successColor,
                            onTap: { showCurrencyDialog = true }
                        )
                        
                        SettingsToggleItem(
                            icon: "moon.fill",
                            title: NSLocalizedString("dark_mode", comment: ""),
                            isOn: $themeManager.isDarkMode,
                            iconColor: Color(hex: "6366F1")
                        )
                        
                        SettingsNavigationItem(
                            icon: "globe",
                            title: NSLocalizedString("language", comment: ""),
                            subtitle: LanguagePreferences.supportedLanguages.first(where: { $0.code == LanguagePreferences.shared.selectedLanguage })?.name,
                            iconColor: .primaryBlue,
                            onTap: { showLanguageDialog = true }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 24)
                    
                    // Support Section
                    sectionHeader(NSLocalizedString("support", comment: ""))
                    
                    VStack(spacing: 8) {
                        SettingsNavigationItem(
                            icon: "questionmark.circle.fill",
                            title: NSLocalizedString("help_center", comment: ""),
                            iconColor: .primaryBlue,
                            onTap: onNavigateToHelpCenter
                        )
                        
                        SettingsNavigationItem(
                            icon: "shield.fill",
                            title: NSLocalizedString("privacy_policy", comment: ""),
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
                            title: NSLocalizedString("logout", comment: ""),
                            iconColor: .warningColor,
                            textColor: .warningColor,
                            onTap: {
                                authViewModel.logout()
                                onLogout()
                            }
                        )
                        
                        SettingsNavigationItem(
                            icon: "trash.fill",
                            title: NSLocalizedString("delete_account", comment: ""),
                            iconColor: .errorColor,
                            textColor: .errorColor,
                            onTap: { showDeleteAccountDialog = true }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 24)
                    
                    // Version
                    Text(String(format: NSLocalizedString("version", comment: ""), "1.0.0"))
                        .font(.system(size: 12))
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer().frame(height: 100)
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
        .alert(NSLocalizedString("delete_account_confirm_title", comment: ""), isPresented: $showDeleteAccountDialog) {
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                authViewModel.deleteAccount()
                onLogout()
            }
        } message: {
            Text(NSLocalizedString("delete_account_confirm_desc", comment: ""))
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
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
            .navigationTitle(NSLocalizedString("select_language", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("close", comment: "")) {
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
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 28)
                        Text("\(curr.code) - \(curr.name)")
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
            .navigationTitle(NSLocalizedString("select_currency", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("close", comment: "")) {
                        showCurrencyDialog = false
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
