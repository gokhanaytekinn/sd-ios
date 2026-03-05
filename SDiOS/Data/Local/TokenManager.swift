import Foundation
import Security

class TokenManager {
    static let shared = TokenManager()
    
    private let tokenKey = "jwt_token"
    private let emailKey = "user_email"
    private let service = "com.gokhanaytekinn.sdios"
    
    private init() {}
    
    // MARK: - Token
    func saveToken(_ token: String) {
        save(key: tokenKey, value: token)
    }
    
    func getToken() -> String? {
        return load(key: tokenKey)
    }
    
    func clearToken() {
        delete(key: tokenKey)
        delete(key: emailKey)
    }
    
    // MARK: - Email
    func saveUserEmail(_ email: String) {
        save(key: emailKey, value: email)
    }
    
    func getUserEmail() -> String? {
        return load(key: emailKey)
    }
    
    var isLoggedIn: Bool {
        return getToken() != nil
    }
    
    // MARK: - Keychain helpers
    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
        
        var newQuery = query
        newQuery[kSecValueData as String] = data
        
        SecItemAdd(newQuery as CFDictionary, nil)
    }
    
    private func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
