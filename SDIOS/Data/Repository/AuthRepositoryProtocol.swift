import Foundation

/// Kimlik doğrulama ve kullanıcı işlemleri için repository protokolü.
/// ViewModel'lar ve UseCase'ler doğrudan sınıfa değil, bu protokole güvenir.
protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async -> Result<ApiAuthResponse, Error>
    func register(email: String, password: String, name: String?, language: String?) async -> Result<ApiAuthResponse, Error>
    func loginWithGoogle(idToken: String) async -> Result<ApiAuthResponse, Error>
    func getCurrentUser() async -> Result<UserResponse, Error>
    func logout()
    func forgotPassword(email: String) async -> Result<Void, Error>
    func verifyCode(email: String, code: String) async -> Result<Void, Error>
    func resetPassword(email: String, code: String, newPassword: String) async -> Result<Void, Error>
    func deleteAccount() async -> Result<Void, Error>
    func updateNotificationSettings(enabled: Bool, language: String?) async -> Result<Void, Error>
    func updatePushToken(token: String, platform: String) async -> Result<Void, Error>
    var isLoggedIn: Bool { get }
}
