import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int, String)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response"
        case .httpError(_, let message): return message
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error): return error.localizedDescription
        }
    }
}

class ApiService {
    static let shared = ApiService()
    
    private let session: URLSession
    private let baseURL: String
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        self.baseURL = NetworkConfig.baseURL
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    // MARK: - Generic Request
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
            // Handle empty body for Void-like responses
            if data.isEmpty, let emptyResult = EmptyResponse() as? T {
                return emptyResult
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } else {
            let errorMessage: String
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                errorMessage = errorResponse.message
            } else if let str = String(data: data, encoding: .utf8) {
                errorMessage = str
            } else {
                errorMessage = "HTTP Error \(httpResponse.statusCode)"
            }
            throw APIError.httpError(httpResponse.statusCode, errorMessage)
        }
    }
    
    private func requestVoid(
        endpoint: String,
        method: String = "GET",
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = true
    ) async throws {
        guard var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            let errorMessage: String
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                errorMessage = errorResponse.message
            } else {
                errorMessage = "HTTP Error \(httpResponse.statusCode)"
            }
            throw APIError.httpError(httpResponse.statusCode, errorMessage)
        }
    }
    
    // MARK: - Auth Endpoints
    func login(_ request: LoginRequest) async throws -> ApiAuthResponse {
        return try await self.request(endpoint: "/api/auth/login", method: "POST", body: request, requiresAuth: false)
    }
    
    func register(_ request: RegisterRequest) async throws -> ApiAuthResponse {
        return try await self.request(endpoint: "/api/auth/register", method: "POST", body: request, requiresAuth: false)
    }
    
    func loginWithGoogle(_ request: GoogleAuthRequest) async throws -> ApiAuthResponse {
        return try await self.request(endpoint: "/api/auth/google", method: "POST", body: request, requiresAuth: false)
    }
    
    
    func getCurrentUser() async throws -> UserResponse {
        return try await request(endpoint: "/api/auth/me")
    }
    
    func deleteAccount() async throws {
        try await requestVoid(endpoint: "/api/auth/delete", method: "DELETE")
    }
    
    func forgotPassword(_ request: ForgotPasswordRequest) async throws {
        try await requestVoid(endpoint: "/api/auth/forgot-password", method: "POST", body: request, requiresAuth: false)
    }
    
    func verifyCode(_ request: VerifyCodeRequest) async throws {
        try await requestVoid(endpoint: "/api/auth/verify-code", method: "POST", body: request, requiresAuth: false)
    }
    
    func resetPassword(_ request: ResetPasswordRequest) async throws {
        try await requestVoid(endpoint: "/api/auth/reset-password", method: "POST", body: request, requiresAuth: false)
    }
    
    func updateNotificationSettings(_ request: NotificationSettingsRequest) async throws {
        try await requestVoid(endpoint: "/api/users/notifications", method: "PATCH", body: request)
    }
    
    // MARK: - Subscription Endpoints
    func getSubscriptions() async throws -> [SubscriptionResponse] {
        return try await request(endpoint: "/api/subscriptions")
    }
    
    func getSubscription(id: String) async throws -> SubscriptionResponse {
        return try await request(endpoint: "/api/subscriptions/\(id)")
    }
    
    func createSubscription(_ request: SubscriptionRequest) async throws -> SubscriptionResponse {
        return try await self.request(endpoint: "/api/subscriptions", method: "POST", body: request)
    }
    
    func updateSubscription(id: String, _ request: SubscriptionUpdateRequest) async throws -> SubscriptionResponse {
        return try await self.request(endpoint: "/api/subscriptions/\(id)", method: "PUT", body: request)
    }
    
    func deleteSubscription(id: String) async throws {
        try await requestVoid(endpoint: "/api/subscriptions/\(id)", method: "DELETE")
    }
    
    func getSuspiciousSubscriptions() async throws -> [SubscriptionResponse] {
        return try await request(endpoint: "/api/subscriptions/suspicious")
    }
    
    func approveSubscription(id: String) async throws -> SubscriptionResponse {
        return try await request(endpoint: "/api/subscriptions/\(id)/approve", method: "PATCH")
    }
    
    func flagSuspicious(id: String, _ request: FlagSuspiciousRequest) async throws -> SubscriptionResponse {
        return try await self.request(endpoint: "/api/subscriptions/\(id)/flag", method: "PATCH", body: request)
    }
    
    func cancelSubscription(id: String) async throws {
        try await requestVoid(endpoint: "/api/subscriptions/\(id)/cancel", method: "PATCH")
    }
    
    func reactivateSubscription(id: String) async throws {
        try await requestVoid(endpoint: "/api/subscriptions/\(id)/reactivate", method: "PATCH")
    }
    
    func getUpcomingSubscriptions() async throws -> [SubscriptionResponse] {
        return try await request(endpoint: "/api/subscriptions/upcoming")
    }
    
    // MARK: - Transactions
    func getTransactions(page: Int = 0, size: Int = 20) async throws -> PageTransactionResponse {
        return try await request(
            endpoint: "/api/transactions",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)")
            ]
        )
    }
    
    // MARK: - Reminders
    func getReminders() async throws -> [ReminderResponse] {
        return try await request(endpoint: "/api/reminders")
    }
    
    // MARK: - Analytics
    func getConvertedAmount(_ request: ConversionRequest) async throws -> Double {
        return try await self.request(endpoint: "/api/convert", method: "POST", body: request)
    }
    
    // MARK: - Invitations
    func getPendingInvitations() async throws -> [SubscriptionInvitation] {
        return try await request(endpoint: "/api/invitations/pending")
    }
    
    func acceptInvitation(id: String) async throws {
        try await requestVoid(endpoint: "/api/invitations/\(id)/accept", method: "POST")
    }
    
    func rejectInvitation(id: String) async throws {
        try await requestVoid(endpoint: "/api/invitations/\(id)/reject", method: "POST")
    }
    
    func removeParticipant(subscriptionId: String, email: String) async throws {
        try await requestVoid(endpoint: "/api/subscriptions/\(subscriptionId)/participants/\(email)", method: "DELETE")
    }
}

// MARK: - Empty Response
struct EmptyResponse: Codable {}
