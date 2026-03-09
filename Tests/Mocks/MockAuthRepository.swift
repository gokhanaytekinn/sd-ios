import Foundation
@testable import SDIOS

class MockAuthRepository: AuthRepositoryProtocol {
    var loginResult: Result<ApiAuthResponse, Error> = .failure(NSError(domain: "", code: -1))
    var registerResult: Result<ApiAuthResponse, Error> = .failure(NSError(domain: "", code: -1))
    var logoutCalled = false
    var isLoggedInValue = false
    
    func login(email: String, password: String) async -> Result<ApiAuthResponse, Error> {
        return loginResult
    }
    
    func register(email: String, password: String, name: String?, language: String?) async -> Result<ApiAuthResponse, Error> {
        return registerResult
    }
    
    func loginWithGoogle(idToken: String) async -> Result<ApiAuthResponse, Error> {
        return loginResult
    }
    
    func getCurrentUser() async -> Result<UserResponse, Error> {
        return .failure(NSError(domain: "", code: -1))
    }
    
    func logout() {
        logoutCalled = true
    }
    
    func forgotPassword(email: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    func verifyCode(email: String, code: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    func resetPassword(email: String, code: String, newPassword: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    func deleteAccount() async -> Result<Void, Error> {
        return .success(())
    }
    
    func updateNotificationSettings(enabled: Bool, language: String?) async -> Result<Void, Error> {
        return .success(())
    }
    
    func updatePushToken(token: String, platform: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    var isLoggedIn: Bool {
        return isLoggedInValue
    }
}
