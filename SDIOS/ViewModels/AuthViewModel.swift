import SwiftUI
import Combine
import StoreKit
import GoogleSignIn

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var nameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    @Published var isAuthenticated = false
    @Published var userName: String? { didSet { nameError = nil } }
    @Published var userEmail: String? { didSet { emailError = nil } }
    @Published var notificationsEnabled = true
    @Published var language: String? = "tr"
    @Published var resetEmail: String?
    @Published var isResetCodeVerified = false
    @Published var tier: Int = 1
    @Published var subscriptionCount: Int = 0
    
    var isSubscriptionLimitReached: Bool {
        tier == 1 && subscriptionCount >= 5
    }
    
    private var lastDeviceToken: String?
    
    // MARK: - Use Cases (İş Mantığı Katmanları)
    // ViewModel, repository ile doğrudan konuşmak yerine bu Use-Case'leri kullanır.
    private let loginUseCase: LoginUseCaseProtocol
    private let registerUseCase: RegisterUseCaseProtocol
    private let googleLoginUseCase: GoogleLoginUseCaseProtocol
    private let forgotPasswordUseCase: ForgotPasswordUseCaseProtocol
    private let verifyCodeUseCase: VerifyCodeUseCaseProtocol
    private let resetPasswordUseCase: ResetPasswordUseCaseProtocol
    private let deleteAccountUseCase: DeleteAccountUseCaseProtocol
    
    // MARK: - Legacy Repositories & Managers
    // Gelecekte bunlar da ilgili Use-Case veya Service katmanlarına taşınabilir.
    private let repository: AuthRepositoryProtocol
    private let purchaseRepository = PurchaseRepository.shared
    private let languagePreferences = LanguagePreferences.shared
    private let premiumPreferences = PremiumPreferences.shared
    private let storeKitManager = StoreKitManager.shared
    
    @Published var iapProducts: [Product] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    /// ViewModel Başlatıcısı (Dependency Injection destekli)
    init(
        repository: AuthRepositoryProtocol? = nil,
        loginUseCase: LoginUseCaseProtocol? = nil,
        registerUseCase: RegisterUseCaseProtocol? = nil,
        googleLoginUseCase: GoogleLoginUseCaseProtocol? = nil,
        forgotPasswordUseCase: ForgotPasswordUseCaseProtocol? = nil,
        verifyCodeUseCase: VerifyCodeUseCaseProtocol? = nil,
        resetPasswordUseCase: ResetPasswordUseCaseProtocol? = nil,
        deleteAccountUseCase: DeleteAccountUseCaseProtocol? = nil
    ) {
        self.repository = repository ?? AuthRepository.shared
        self.loginUseCase = loginUseCase ?? LoginUseCase()
        self.registerUseCase = registerUseCase ?? RegisterUseCase()
        self.googleLoginUseCase = googleLoginUseCase ?? GoogleLoginUseCase()
        self.forgotPasswordUseCase = forgotPasswordUseCase ?? ForgotPasswordUseCase()
        self.verifyCodeUseCase = verifyCodeUseCase ?? VerifyCodeUseCase()
        self.resetPasswordUseCase = resetPasswordUseCase ?? ResetPasswordUseCase()
        self.deleteAccountUseCase = deleteAccountUseCase ?? DeleteAccountUseCase()
        
        restoreSession()
        setupStoreKitManager()
    }
    
    private func setupStoreKitManager() {
        storeKitManager.$products
            .assign(to: &$iapProducts)
    }
    
    func restoreSession() {
        guard repository.isLoggedIn else { return }
        
        Task {
            isLoading = true
            let result = await repository.getCurrentUser()
            switch result {
            case .success(let user):
                isLoading = false
                isAuthenticated = true
                userName = user.name
                userEmail = user.email
                notificationsEnabled = user.notificationsEnabled ?? true
                language = user.language ?? "tr"
                tier = user.tier ?? 1
                premiumPreferences.isPremium = (user.tier ?? 1) >= 2
                syncLanguageIfNeeded()
                
                // Re-register push token if we have one
                if let token = lastDeviceToken {
                    updatePushToken(token: token)
                }
            case .failure:
                isLoading = false
                isAuthenticated = false
            }
        }
    }
    
    /// Kullanıcı giriş işlemi
    /// - Parameters:
    ///   - email: Kullanıcı e-postası
    ///   - password: Kullanıcı şifresi
    ///   - onSuccess: Başarılı giriş sonrası çalışacak callback
    func login(email: String, password: String, onSuccess: @escaping () -> Void) {
        // 1. Önce verileri doğrula (Validation)
        guard validateLogin(email: email, password: password) else { return }
        
        Task {
            isLoading = true
            error = nil
            
            // 2. İş mantığını Use-Case üzerinden yürüt
            let result = await loginUseCase.execute(email: email, password: password)
            
            switch result {
            case .success(let response):
                // 3. UI State'i güncelle
                isLoading = false
                isAuthenticated = true
                userName = response.user?.name
                userEmail = response.user?.email
                notificationsEnabled = response.user?.notificationsEnabled ?? true
                language = response.user?.language ?? "tr"
                tier = response.user?.tier ?? 1
                premiumPreferences.isPremium = (response.user?.tier ?? 1) >= 2
                syncLanguageIfNeeded()
                
                // Push token'ı güncelle (varsa)
                if let token = lastDeviceToken {
                    updatePushToken(token: token)
                }
                onSuccess()
            case .failure(let err):
                // Hata durumunda mesajı göster
                isLoading = false
                error = err.localizedDescription
            }
        }
    }
    
    /// Yeni kullanıcı kayıt işlemi
    /// - Parameters:
    ///   - name: İsim
    ///   - email: E-posta
    ///   - password: Şifre
    ///   - confirmPassword: Şifre tekrarı
    ///   - onSuccess: Başarılı kayıt sonrası çalışacak callback
    func register(name: String, email: String, password: String, confirmPassword: String, onSuccess: @escaping () -> Void) {
        // 1. Veri doğruluğunu kontrol et
        guard validateRegister(name: name, email: email, password: password, confirmPassword: confirmPassword) else { return }
        
        Task {
            isLoading = true
            error = nil
            let localLanguage = languagePreferences.selectedLanguage
            
            // 2. Kayıt iş mantığını Use-Case üzerinden yürüt
            let result = await registerUseCase.execute(name: name, email: email, password: password, language: localLanguage)
            
            switch result {
            case .success(let response):
                // 3. UI State ve oturum bilgilerini güncelle
                isLoading = false
                isAuthenticated = true
                userName = response.user?.name
                userEmail = response.user?.email
                notificationsEnabled = response.user?.notificationsEnabled ?? true
                language = response.user?.language ?? localLanguage
                tier = response.user?.tier ?? 1
                premiumPreferences.isPremium = (response.user?.tier ?? 1) >= 2
                onSuccess()
            case .failure(let err):
                // Hata mesajını kullanıcıya yansıt
                isLoading = false
                error = err.localizedDescription
            }
        }
    }

    /// Google ID Token kullanarak backend'de oturum açma
    /// - Parameters:
    ///   - idToken: Google'dan gelen token
    ///   - onSuccess: Başarılı sonuç callback'i
    func loginWithGoogle(idToken: String, onSuccess: @escaping () -> Void) {
        Task {
            isLoading = true
            error = nil
            
            // İş mantığını Use-Case üzerinden yürüt
            let result = await googleLoginUseCase.execute(idToken: idToken)
            
            switch result {
            case .success(let response):
                // UI ve oturum durumunu güncelle
                isLoading = false
                isAuthenticated = true
                userName = response.user?.name
                userEmail = response.user?.email
                notificationsEnabled = response.user?.notificationsEnabled ?? true
                language = response.user?.language ?? "tr"
                tier = response.user?.tier ?? 1
                premiumPreferences.isPremium = (response.user?.tier ?? 1) >= 2
                syncLanguageIfNeeded()
                
                // Push token senkronizasyonu
                if let token = lastDeviceToken {
                    updatePushToken(token: token)
                }
                onSuccess()
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }


    func signInWithGoogle(onSuccess: @escaping () -> Void) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            return
        }

        // Load the iOS Client ID from the plist file provided by Google Cloud Console
        let plistName = "client_511347263387-geasdab34clq1b778vu5i6m2l0m4anlr.apps.googleusercontent.com"
        guard let plistPath = Bundle.main.path(forResource: plistName, ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath),
              let clientID = plistDict["CLIENT_ID"] as? String else {
            self.error = "Google configuration not found"
            return
        }

        // The serverClientId is the Web Client ID from Google Cloud Console (same as Android)
        let serverClientId = "511347263387-cv901jhvhfoap5ibn4rndu7irlgspkn7.apps.googleusercontent.com"
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID, serverClientID: serverClientId)

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self.error = "Failed to get ID Token"
                    return
                }

                self.loginWithGoogle(idToken: idToken, onSuccess: onSuccess)
            }
        }
    }

    
    /// Şifre sıfırlama talebi gönderir
    /// - Parameters:
    ///   - email: E-posta adresi
    ///   - onSuccess: Talep başarılı olduğunda çalışır
    func forgotPassword(email: String, onSuccess: @escaping () -> Void) {
        // E-posta boş olamaz kontrolü
        guard !email.isEmpty else {
            emailError = NSLocalizedString("error_email_required", comment: "")
            return
        }
        
        Task {
            isLoading = true
            error = nil
            
            // ForgotPassword Use-Case çağrısı
            let result = await forgotPasswordUseCase.execute(email: email)
            
            switch result {
            case .success:
                isLoading = false
                resetEmail = email // Hangi e-posta için sıfırlama yapıldığını hatırla
                onSuccess()
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }
    
    /// Şifre sıfırlama kodunu doğrular
    /// - Parameters:
    ///   - code: 6 haneli kod
    ///   - onSuccess: Doğrulama başarılı olduğunda çalışır
    func verifyCode(code: String, onSuccess: @escaping () -> Void) {
        // Basit validasyon: e-posta biliniyor olmalı ve kod 6 haneli olmalı
        guard let email = resetEmail, code.count == 6 else { return }
        
        Task {
            isLoading = true
            error = nil
            
            // VerifyCode Use-Case çağrısı
            let result = await verifyCodeUseCase.execute(email: email, code: code)
            
            switch result {
            case .success:
                isLoading = false
                isResetCodeVerified = true // UI'da şifre belirleme ekranına geçişi sağlar
                onSuccess()
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }
    
    /// Yeni şifreyi kaydeder
    /// - Parameters:
    ///   - code: Doğrulanmış kod
    ///   - newPassword: Yeni belirlenen şifre
    ///   - onSuccess: İşlem başarılı olduğunda çalışır
    func resetPassword(code: String, newPassword: String, onSuccess: @escaping () -> Void) {
        guard let email = resetEmail else { return }
        
        Task {
            isLoading = true
            error = nil
            
            // ResetPassword Use-Case çağrısı
            let result = await resetPasswordUseCase.execute(email: email, code: code, newPassword: newPassword)
            
            switch result {
            case .success:
                isLoading = false
                resetEmail = nil // Temizlik
                isResetCodeVerified = false
                onSuccess()
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }
    
    func updateNotificationSettings(enabled: Bool) {
        Task {
            let language = languagePreferences.selectedLanguage
            let _ = await repository.updateNotificationSettings(enabled: enabled, language: language)
            notificationsEnabled = enabled
            self.language = language
        }
    }
    
    func updatePushToken(token: String) {
        self.lastDeviceToken = token
        Task {
            let _ = await repository.updatePushToken(token: token, platform: "ios")
        }
    }
    
    func logout() {
        repository.logout()
        premiumPreferences.isPremium = false
        isAuthenticated = false
        userName = nil
        userEmail = nil
        error = nil
        isLoading = false
        tier = 1
    }
    
    /// Kullanıcı hesabını tamamen siler
    func deleteAccount() {
        Task {
            isLoading = true
            error = nil
            
            // DeleteAccount Use-Case çağrısı
            let result = await deleteAccountUseCase.execute()
            
            switch result {
            case .success:
                // Yerel oturum verilerini temizle
                premiumPreferences.isPremium = false
                isAuthenticated = false
                userName = nil
                userEmail = nil
                isLoading = false
                tier = 1
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }
    
    func purchase(product: Product) {
        Task {
            isLoading = true
            error = nil
            do {
                if let transaction = try await storeKitManager.purchase(product) {
                    // Sync with backend
                    let result = await purchaseRepository.verifyPurchase(
                        PurchaseRequest(purchaseToken: String(transaction.id), productId: product.id)
                    )
                    
                    switch result {
                    case .success(let user):
                        self.tier = user.tier ?? 2
                        self.premiumPreferences.isPremium = true
                        isLoading = false
                    case .failure(let err):
                        isLoading = false
                        error = err.localizedDescription
                    }
                } else {
                    isLoading = false
                }
            } catch {
                isLoading = false
                self.error = error.localizedDescription
            }
        }
    }
    
    func restorePurchases() {
        Task {
            isLoading = true
            error = nil
            do {
                try await storeKitManager.restorePurchases()
                // Fetch user again to sync tier
                let _ = await repository.getCurrentUser()
                restoreSession() // Refresh state
                isLoading = false
            } catch {
                isLoading = false
                self.error = error.localizedDescription
            }
        }
    }
    
    func clearError() {
        error = nil
        nameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
    }
    
    func clearGeneralError() {
        error = nil
    }
    
    func clearNameError() { nameError = nil }
    func clearEmailError() { emailError = nil }
    func clearPasswordError() { passwordError = nil }
    func clearConfirmPasswordError() { confirmPasswordError = nil }
    
    // MARK: - Validation
    private func validateLogin(email: String, password: String) -> Bool {
        clearError()
        var isValid = true
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = NSLocalizedString("error_email_required", comment: "")
            isValid = false
        }
        
        if password.isEmpty {
            passwordError = NSLocalizedString("error_password_required", comment: "")
            isValid = false
        }
        
        return isValid
    }
    
    private func validateRegister(name: String, email: String, password: String, confirmPassword: String) -> Bool {
        clearError()
        var isValid = true
        
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = NSLocalizedString("error_name_required", comment: "")
            isValid = false
        }
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = NSLocalizedString("error_email_required", comment: "")
            isValid = false
        } else if !isValidEmail(email) {
            emailError = NSLocalizedString("error_email_invalid", comment: "")
            isValid = false
        }
        
        if password.isEmpty {
            passwordError = NSLocalizedString("error_password_required", comment: "")
            isValid = false
        } else if password.count < 6 {
            passwordError = NSLocalizedString("error_password_short", comment: "")
            isValid = false
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordError = NSLocalizedString("error_password_required", comment: "")
            isValid = false
        } else if password != confirmPassword {
            confirmPasswordError = NSLocalizedString("error_passwords_do_not_match", comment: "")
            isValid = false
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    private func syncLanguageIfNeeded() {
        let localLanguage = languagePreferences.selectedLanguage
        if localLanguage != language {
            Task {
                let _ = await repository.updateNotificationSettings(enabled: notificationsEnabled, language: localLanguage)
                language = localLanguage
            }
        }
    }
}
