import Foundation

/// HTTP istek tiplerini tanımlayan enum.
/// Tip güvenliği (type-safety) için String yerine kullanılır.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
