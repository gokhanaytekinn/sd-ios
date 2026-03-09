import Foundation

protocol TokenManagerProtocol {
    func saveToken(_ token: String)
    func getToken() -> String?
    func clearToken()
    func saveUserEmail(_ email: String)
    func getUserEmail() -> String?
    var isLoggedIn: Bool { get }
}

extension TokenManager: TokenManagerProtocol {}
