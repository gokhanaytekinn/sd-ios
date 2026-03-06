import SwiftUI
import Combine
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
    
    private let repository = AuthRepository.shared
    private let languagePreferences = LanguagePreferences.shared
    private let premiumPreferences = PremiumPreferences.shared
    
    init() {
        restoreSession()
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
                premiumPreferences.isPremium = user.tier == 2
                syncLanguageIfNeeded()
            case .failure:
                isLoading = false
                isAuthenticated = false
            }
        }
    }
    
    func login(email: String, password: String, onSuccess: @escaping () -> Void) {
        guard validateLogin(email: email, password: password) else { return }
        
        Task {
            isLoading = true
            error = nil
            let result = await repository.login(email: email, password: password)
            switch result {
            case .success(let response):
                isLoading = false
                isAuthenticated = true
                userName = response.user?.name
                userEmail = response.user?.email
                notificationsEnabled = response.user?.notificationsEnabled ?? true
                language = response.user?.language ?? "tr"
                tier = response.user?.tier ?? 1
                syncLanguageIfNeeded()
                onSuccess()
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }
    
    func register(name: String, email: String, password: String, confirmPassword: String, onSuccess: @escaping () -> Void) {
        guard validateRegister(name: name, email: email, password: password, confirmPassword: confirmPassword) else { return }
        
        Task {
            isLoading = true
            error = nil
            let localLanguage = languagePreferences.selectedLanguage
            let result = await repository.register(email: email, password: password, name: name, language: localLanguage)
            switch result {
            case .success(let response):
                isLoading = false
                isAuthenticated = true
                userName = response.user?.name
                userEmail = response.user?.email
                notificationsEnabled = response.user?.notificationsEnabled ?? true
                language = response.user?.language ?? localLanguage
                tier = response.user?.tier ?? 1
                onSuccess()
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }

    func loginWithGoogle(idToken: String, onSuccess: @escaping () -> Void) {
        Task {
            isLoading = true
            error = nil
            let result = await repository.loginWithGoogle(idToken: idToken)
            switch result {
            case .success(let response):
                isLoading = false
                isAuthenticated = true
                userName = response.user?.name
                userEmail = response.user?.email
                notificationsEnabled = response.user?.notificationsEnabled ?? true
                language = response.user?.language ?? "tr"
                tier = response.user?.tier ?? 1
                syncLanguageIfNeeded()
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
            if let error = error {
                self?.error = error.localizedDescription
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.error = "Failed to get ID Token"
                return
            }

            self?.loginWithGoogle(idToken: idToken, onSuccess: onSuccess)
        }
    }

    
    func forgotPassword(email: String, onSuccess: @escaping () -> Void) {
        guard !email.isEmpty else {
            emailError = NSLocalizedString("error_email_required", comment: "")
            return
        }
        
        Task {
            isLoading = true
            error = nil
            let result = await repository.forgotPassword(email: email)
            switch result {
            case .success:
                isLoading = false
                resetEmail = email
                onSuccess()
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }
    
    func verifyCode(code: String, onSuccess: @escaping () -> Void) {
        guard let email = resetEmail, code.count == 6 else { return }
        
        Task {
            isLoading = true
            error = nil
            let result = await repository.verifyCode(email: email, code: code)
            switch result {
            case .success:
                isLoading = false
                isResetCodeVerified = true
                onSuccess()
            case .failure(let err):
                isLoading = false
                error = err.localizedDescription
            }
        }
    }
    
    func resetPassword(code: String, newPassword: String, onSuccess: @escaping () -> Void) {
        guard let email = resetEmail else { return }
        
        Task {
            isLoading = true
            error = nil
            let result = await repository.resetPassword(email: email, code: code, newPassword: newPassword)
            switch result {
            case .success:
                isLoading = false
                resetEmail = nil
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
    
    func deleteAccount() {
        Task {
            isLoading = true
            error = nil
            let result = await repository.deleteAccount()
            switch result {
            case .success:
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
