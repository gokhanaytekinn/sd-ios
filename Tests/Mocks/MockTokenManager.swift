import Foundation
@testable import SDIOS

class MockTokenManager: TokenManagerProtocol {
    var savedToken: String?
    var savedEmail: String?
    var clearTokenCalled = false
    var isLoggedInValue = false
    
    func saveToken(_ token: String) { savedToken = token }
    func getToken() -> String? { return savedToken }
    func clearToken() { clearTokenCalled = true; savedToken = nil; savedEmail = nil }
    func saveUserEmail(_ email: String) { savedEmail = email }
    func getUserEmail() -> String? { return savedEmail }
    var isLoggedIn: Bool { return isLoggedInValue }
}
