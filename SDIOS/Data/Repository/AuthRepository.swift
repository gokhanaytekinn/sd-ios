import Foundation

/// Kimlik doğrulama ve kullanıcı verilerinin yönetiminden sorumlu Repository.
/// İş mantığı (Domain) katmanı ile Veri (Data) katmanı arasında köprü görevi görür.
class AuthRepository: AuthRepositoryProtocol {
    /// Singleton örneği - Uygulama genelinde tek bir örnek üzerinden erişim sağlanır.
    static let shared: AuthRepositoryProtocol = AuthRepository()
    
    /// API isteklerini yöneten servis bağımlılığı.
    private let api: ApiServiceProtocol
    private let tokenManager: TokenManagerProtocol
    
    /// Bağımlılık Enjeksiyonu (Dependency Injection) destekli başlatıcı.
    /// Testlerde sahte (mock) API servisleri ve TokenManager enjekte edilebilir.
    init(api: ApiServiceProtocol = ApiService.shared, tokenManager: TokenManagerProtocol = TokenManager.shared) {
        self.api = api
        self.tokenManager = tokenManager
    }
    
    /// Kullanıcı giriş işlemini API üzerinden gerçekleştirir.
    /// Başarılı olursa dönen token'ı TokenManager'a kaydeder.
    func login(email: String, password: String) async -> Result<ApiAuthResponse, Error> {
        do {
            let response = try await api.login(LoginRequest(email: email, password: password))
            // Token'ı yerel depolamaya güvenli bir şekilde kaydet
            if let token = response.token {
                tokenManager.saveToken(token)
            }
            // Kullanıcı e-postasını oturum yönetimi için sakla
            if let email = response.user?.email {
                tokenManager.saveUserEmail(email)
            }
            return .success(response)
        } catch {
            return .failure(error) // Hata durumunu yukarı katmana ilet
        }
    }
    
    /// Yeni kullanıcı kaydı oluşturur.
    func register(email: String, password: String, name: String?, language: String?) async -> Result<ApiAuthResponse, Error> {
        do {
            let response = try await api.register(RegisterRequest(email: email, password: password, name: name, language: language))
            // Kayıt sonrası otomatik giriş için token ve e-postayı sakla
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
    
    /// Google ID Token ile oturum açma işlemini yönetir.
    func loginWithGoogle(idToken: String) async -> Result<ApiAuthResponse, Error> {
        do {
            let response = try await api.loginWithGoogle(GoogleAuthRequest(idToken: idToken))
            // Sosyal login sonrası token yönetimini gerçekleştir
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
    

    
    /// Mevcut kullanıcının profil bilgilerini getirir.
    func getCurrentUser() async -> Result<UserResponse, Error> {
        do {
            let response = try await api.getCurrentUser()
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    /// Yerel oturumu sonlandırır ve token'ları temizler.
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
