import Foundation

struct PushTokenRequest: Codable {
    let token: String
    let platform: String
    let isSandbox: Bool
}
