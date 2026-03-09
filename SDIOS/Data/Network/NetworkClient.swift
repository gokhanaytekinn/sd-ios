import Foundation

/// Sadece veri iletişiminden sorumlu düşük seviyeli ağ istemcisi.
/// Clean Architecture prensiplerine göre, neyin istendiğini bilmez (Single Responsibility).
protocol NetworkClientProtocol {
    func execute<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func executeVoid(_ endpoint: APIEndpoint) async throws
}

class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    /// Generic bir isteği yürütür ve sonucu decode eder.
    func execute<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try endpoint.asURLRequest()
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Başarı kontrolü (200-299)
        if (200...299).contains(httpResponse.statusCode) {
            // Boş cevap durumunu yönet
            if data.isEmpty, let empty = EmptyResponse() as? T {
                return empty
            }
            return try decoder.decode(T.self, from: data)
        } else {
            // Hata durumunda API'dan gelen mesajı oku
            let message = try? decoder.decode(ErrorResponse.self, from: data).message
            throw APIError.httpError(httpResponse.statusCode, message ?? "Sunucu hatası")
        }
    }
    
    /// Cevap beklemeyen (Void) istekleri yürütür.
    func executeVoid(_ endpoint: APIEndpoint) async throws {
        let request = try endpoint.asURLRequest()
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw APIError.httpError(httpResponse.statusCode, "Hata oluştu")
        }
    }
}
