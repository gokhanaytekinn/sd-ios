import Foundation

/// Her bir API isteğinin şemasını tanımlayan protokol.
/// Bu yapı sayesinde istekler birbirinden bağımsız ve modüler hale gelir.
protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    var requiresAuth: Bool { get }
}

extension APIEndpoint {
    var baseURL: String {
        return NetworkConfig.baseURL
    }
    
    /// Varsayılan headerlar (Content-Type vb.)
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    /// URLRequest oluşturma mantığı merkezi hale getirildi.
    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Headerları ekle
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Token gerekliyse ekle
        if requiresAuth, let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Body ekle
        request.httpBody = body
        
        return request
    }
}
