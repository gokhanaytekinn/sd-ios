import Foundation

class AuthRepository {
    static let shared = AuthRepository()
    
    private let api = ApiService.shared
    private let tokenManager = TokenManager.shared
    
    private init() {}
    
    func login(email: String, password: String) async -> Result<ApiAuthResponse, Error> {
        do {
            let response = try await api.login(LoginRequest(email: email, password: password))
            if let token = response.token {
                tokenManager.saveToken(token)
            }
            if let email = response.user?.email {
                tokenManager.saveUserEmail(email)
            }
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func register(email: String, password: String, name: String?, language: String?) async -> Result<ApiAuthResponse, Error> {
        do {
            let response = try await api.register(RegisterRequest(email: email, password: password, name: name, language: language))
            if let token = response.token {
                tokenManager.saveToken(token)
            }
            if let email = response.user?.email {
                tokenManager.saveUserEmail(email)
            }
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func loginWithGoogle(idToken: String) async -> Result<ApiAuthResponse, Error> {
        do {
            let response = try await api.loginWithGoogle(GoogleAuthRequest(idToken: idToken))
            if let token = response.token {
                tokenManager.saveToken(token)
            }
            if let email = response.user?.email {
                tokenManager.saveUserEmail(email)
            }
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    

    
    func getCurrentUser() async -> Result<UserResponse, Error> {
        do {
            let response = try await api.getCurrentUser()
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func logout() {
        tokenManager.clearToken()
    }
    
    func forgotPassword(email: String) async -> Result<Void, Error> {
        do {
            try await api.forgotPassword(ForgotPasswordRequest(email: email))
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func verifyCode(email: String, code: String) async -> Result<Void, Error> {
        do {
            try await api.verifyCode(VerifyCodeRequest(email: email, code: code))
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func resetPassword(email: String, code: String, newPassword: String) async -> Result<Void, Error> {
        do {
            try await api.resetPassword(ResetPasswordRequest(email: email, code: code, newPassword: newPassword))
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func deleteAccount() async -> Result<Void, Error> {
        do {
            try await api.deleteAccount()
            tokenManager.clearToken()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateNotificationSettings(enabled: Bool, language: String?) async -> Result<Void, Error> {
        do {
            try await api.updateNotificationSettings(NotificationSettingsRequest(enabled: enabled, language: language))
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func updatePushToken(token: String, platform: String) async -> Result<Void, Error> {
        do {
            try await api.updatePushToken(PushTokenRequest(token: token, platform: platform))
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    var isLoggedIn: Bool {
        tokenManager.isLoggedIn
    }
}
