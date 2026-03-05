import Foundation

struct User: Codable {
    let id: String
    let email: String
    let name: String?
    let token: String?
}

struct AuthRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}
