import SwiftUI

// MARK: - Navigation Route
enum AppRoute: Hashable {
    case onboarding
    case login
    case register
    case forgotPassword
    case verificationCode
    case resetPassword(code: String)
    case main
    case subscriptionDetail(id: String)
    case addSubscription
    case editSubscription(id: String)
    case search
    case helpCenter
    case privacyPolicy
    case premiumUpgrade
    case transactionHistory
}

// MARK: - Main Tab
enum MainTab: Int, CaseIterable {
    case dashboard = 0
    case subscriptions = 1
    case upcoming = 2
    case settings = 3
    
    var title: String {
        switch self {
        case .dashboard: return "dashboard_title".localized()
        case .subscriptions: return "subscriptions".localized()
        case .upcoming: return "nav_upcoming".localized()
        case .settings: return "settings_title".localized()
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .subscriptions: return "creditcard.fill"
        case .upcoming: return "clock.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var languagePref = LanguagePreferences.shared
    
    @State private var navigationPath: [AppRoute] = []
    @State private var selectedTab: MainTab = .dashboard
    @State private var showingLimitAlert = false
    @State private var isBannerLoaded = true
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if authViewModel.isLoading && !authViewModel.isAuthenticated {
                // Splash / Loading
                DashboardSkeleton()
            } else if !authViewModel.isAuthenticated {
                // Auth Flow
                NavigationStack(path: $navigationPath) {
                    let hasSeenOnboarding = PremiumPreferences.shared.hasSeenOnboarding
                    
                    if !hasSeenOnboarding {
                        OnboardingScreen {
                            PremiumPreferences.shared.hasSeenOnboarding = true
                            navigationPath.append(.login)
                        }
                        .navigationBarHidden(true)
                        .navigationDestination(for: AppRoute.self) { route in
                            authDestination(route)
                                .navigationBarHidden(true)
                        }
                    } else {
                        LoginScreen(
                            onLoginSuccess: {
                                // Auth state change will automatically switch to main
                            },
                            onNavigateToRegister: {
                                navigationPath.append(.register)
                            },
                            onNavigateToForgotPassword: {
                                navigationPath.append(.forgotPassword)
                            }
                        )
                        .navigationBarHidden(true)
                        .navigationDestination(for: AppRoute.self) { route in
                            authDestination(route)
                                .navigationBarHidden(true)
                        }
                    }
                }
            } else {
                // Main App
                mainTabView
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { oldValue, isAuth in
            if isAuth {
                // Clear auth navigation path so main tab view starts clean
                navigationPath = []
            }
        }
    }
    
    // MARK: - Auth Destination
    @ViewBuilder
    private func authDestination(_ route: AppRoute) -> some View {
        switch route {
        case .login:
            LoginScreen(
                onLoginSuccess: {},
                onNavigateToRegister: { navigationPath.append(.register) },
                onNavigateToForgotPassword: { navigationPath.append(.forgotPassword) }
            )
        case .register:
            RegisterScreen(
                onRegisterSuccess: {},
                onNavigateToLogin: { navigationPath.removeLast() }
            )
        case .forgotPassword:
            ForgotPasswordScreen(
                onCodeSent: { navigationPath.append(.verificationCode) },
                onBackToLogin: { navigationPath.removeLast() }
            )
        case .verificationCode:
            VerificationCodeScreen(
                onVerified: { navigationPath.append(.resetPassword(code: "")) },
                onBack: { navigationPath.removeLast() }
            )
        case .resetPassword(let code):
            ResetPasswordScreen(
                verificationCode: code,
                onPasswordReset: { navigationPath = [] },
                onBack: { navigationPath.removeLast() }
            )
        default:
            EmptyView()
        }
    }
    
    // MARK: - Main Tab View
    private var mainTabView: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                NavigationStack(path: $navigationPath) {
                    Group {
                        switch selectedTab {
                        case .dashboard:
                            DashboardScreen(
                                onNavigateToSubscriptions: { selectedTab = .subscriptions },
                                onNavigateToSubscriptionDetail: { id in navigationPath.append(.subscriptionDetail(id: id)) },
                                onNavigateToSearch: { navigationPath.append(.search) }
                            )
                        case .subscriptions:
                            SubscriptionsListScreen(
                                onNavigateToAddSubscription: {
                                    if authViewModel.isSubscriptionLimitReached {
                                        showingLimitAlert = true
                                    } else {
                                        navigationPath.append(.addSubscription)
                                    }
                                },
                                onNavigateToSubscriptionDetail: { id in navigationPath.append(.subscriptionDetail(id: id)) }
                            )
                        case .upcoming:
                            UpcomingSubscriptionsScreen(
                                onNavigateToSubscriptionDetail: { id in navigationPath.append(.subscriptionDetail(id: id)) }
                            )
                        case .settings:
                            AppSettingsScreen(
                                onNavigateToHelpCenter: { navigationPath.append(.helpCenter) },
                                onNavigateToPrivacyPolicy: { navigationPath.append(.privacyPolicy) },
                                onNavigateToPremium: { navigationPath.append(.premiumUpgrade) },
                                onLogout: {}
                            )
                        }
                    }
                    .navigationBarHidden(true)
                    .navigationDestination(for: AppRoute.self) { route in
                        mainDestination(route)
                            .navigationBarHidden(true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom area container
                VStack(spacing: 0) {
                    bottomNavBar
                    
                    // Banner Ad for non-premium users
                    if authViewModel.tier == 1 {
                        BannerAdView(isLoaded: $isBannerLoaded)
                            .frame(height: isBannerLoaded ? 60 : 0) // Hide when not loaded
                            .clipped()
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .environment(\.locale, .init(identifier: languagePref.selectedLanguage))
        .id(languagePref.selectedLanguage) // Force view refresh on language change
        .alert("limit_reached_title".localized(), isPresented: $showingLimitAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text("limit_reached_message".localized())
        }
        .onChange(of: navigationPath) { oldValue, newValue in
            if newValue.isEmpty {
                NotificationCenter.default.post(name: NSNotification.Name("RefreshData"), object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DidRequestNavigation"))) { notification in
            if let destination = notification.object as? String {
                handleNavigation(to: destination)
            }
        }
        .onAppear {
            if let pending = DeepLinkManager.shared.consume() {
                handleNavigation(to: pending)
            }
        }
        .onReceive(DeepLinkManager.shared.$pendingRoute) { route in
            if let route = route {
                handleNavigation(to: DeepLinkManager.shared.consume() ?? route)
            }
        }
    }
    
    private func handleNavigation(to destination: String) {
        if destination == "add_subscription" {
            if authViewModel.isSubscriptionLimitReached {
                showingLimitAlert = true
            } else {
                navigationPath = [.addSubscription]
            }
        }
    }
    
    // MARK: - Main Destination
    @ViewBuilder
    private func mainDestination(_ route: AppRoute) -> some View {
        switch route {
        case .subscriptionDetail(let id):
            SubscriptionDetailsScreen(
                subscriptionId: id,
                onBack: { navigationPath.removeLast() },
                onEdit: { sub in
                    navigationPath.removeLast()
                    navigationPath.append(.editSubscription(id: sub.id))
                }
            )
        case .addSubscription:
            AddSubscriptionScreen(
                onSaved: {
                    navigationPath.removeLast()
                    
                    // Show interstitial ad every 3rd addition for non-premium users
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        AdMobManager.shared.incrementSubscriptionCount(from: rootVC, isPremium: authViewModel.tier >= 2)
                    }
                },
                onBack: { navigationPath.removeLast() }
            )
        case .editSubscription(let id):
            editSubscriptionScreen(id: id)
        case .search:
            SearchScreen(
                onBack: { navigationPath.removeLast() },
                onSubscriptionTap: { id in navigationPath.append(.subscriptionDetail(id: id)) }
            )
        case .helpCenter:
            HelpCenterScreen(onBack: { navigationPath.removeLast() })
        case .privacyPolicy:
            PrivacyPolicyScreen(onBack: { navigationPath.removeLast() })
        case .premiumUpgrade:
            PremiumUpgradeScreen(onBack: { navigationPath.removeLast() })
        case .transactionHistory:
            TransactionHistoryScreen(onBack: { navigationPath.removeLast() })
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func editSubscriptionScreen(id: String) -> some View {
        // The edit screen needs to load the subscription first
        EditSubscriptionWrapper(
            subscriptionId: id,
            onSaved: { navigationPath.removeLast() },
            onBack: { navigationPath.removeLast() }
        )
    }
    
    // MARK: - Bottom Navigation Bar
    private var bottomNavBar: some View {
        HStack(spacing: 0) {
            // First 2 Tabs
            ForEach(0..<2) { index in
                if let tab = MainTab(rawValue: index) {
                    tabButton(tab)
                }
            }
            
            // Center Add Button
            centerAddButton
            
            // Last 2 Tabs
            ForEach(2..<4) { index in
                if let tab = MainTab(rawValue: index) {
                    tabButton(tab)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            ZStack {
                Capsule()
                    .fill(Color.appSurface(for: colorScheme))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.1),
                                .clear,
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func tabButton(_ tab: MainTab) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
                navigationPath = []
            }
        }) {
            VStack(spacing: 2) {
                Image(systemName: selectedTab == tab ? tab.icon : tab.icon.replacingOccurrences(of: ".fill", with: ""))
                    .font(.system(size: 18))
                    .foregroundColor(selectedTab == tab ? .primaryBlue : Color.appOnSurfaceVariant(for: colorScheme))
                
                Text(tab.title)
                    .font(selectedTab == tab ? .sdLabelSmall : .sdLabel)
                    .foregroundColor(selectedTab == tab ? .primaryBlue : Color.appOnSurfaceVariant(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
    
    private var centerAddButton: some View {
        Button(action: {
            if authViewModel.isSubscriptionLimitReached {
                showingLimitAlert = true
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    navigationPath = [.addSubscription]
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.appSurface(for: colorScheme).opacity(0.001))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(Color.primaryBlue, lineWidth: 1)
                    )
                
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primaryBlue)
            }
            .padding(.horizontal, 12)
        }
        .buttonStyle(.plain)
        .offset(y: 0)
    }
}

// MARK: - Edit Subscription Wrapper
struct EditSubscriptionWrapper: View {
    let subscriptionId: String
    let onSaved: () -> Void
    let onBack: () -> Void
    
    @State private var subscription: Subscription?
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            VStack(spacing: 0) {
                // Mocking Top Bar
                HStack {
                    Circle().fill(Color.gray.opacity(0.1)).frame(width: 24, height: 24)
                    Spacer()
                    Rectangle().fill(Color.gray.opacity(0.1)).frame(width: 150, height: 20)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 24, height: 24)
                }
                .padding(16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(0..<6, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)).frame(width: 100, height: 16)
                                RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)).frame(height: 56)
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .onAppear { loadSubscription() }
        } else if let sub = subscription {
            AddSubscriptionScreen(
                editSubscription: sub,
                onSaved: onSaved,
                onBack: onBack
            )
        } else {
            Text("Not found")
        }
    }
    
    private func loadSubscription() {
        Task {
            let result = await SubscriptionRepository.shared.getSubscription(id: subscriptionId)
            if case .success(let sub) = result {
                subscription = sub
            }
            isLoading = false
        }
    }
}
