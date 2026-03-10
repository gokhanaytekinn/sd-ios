import Foundation

enum APIError: LocalizedError, Equatable {
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
    
    // Manuel Equatable uygulaması. Error tipleri direkt karşılaştırılamadığı için mesajları kontrol edilir.
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL), (.invalidResponse, .invalidResponse):
            return true
        case (.httpError(let lCode, let lMsg), .httpError(let rCode, let rMsg)):
            return lCode == rCode && lMsg == rMsg
        case (.decodingError(let lErr), .decodingError(let rErr)):
            return lErr.localizedDescription == rErr.localizedDescription
        case (.networkError(let lErr), .networkError(let rErr)):
            return lErr.localizedDescription == rErr.localizedDescription
        default:
            return false
        }
    }
}

class ApiService: ApiServiceProtocol {
    /// Singleton örneği - Protokol üzerinden erişim sağlanır.
    static let shared: ApiServiceProtocol = ApiService()
    
    /// Düşük seviyeli ağ iletişiminden sorumlu istemci.
    private let client: NetworkClientProtocol
    
    /// Başlatıcı - Dependency Injection desteği ile.
    /// Farklı bir NetworkClient (örneğin mock) enjekte edilebilir.
    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }
    
    // MARK: - Auth İşlemleri
    
    func login(_ request: LoginRequest) async throws -> ApiAuthResponse {
        return try await client.execute(AuthEndpoint.login(request))
    }
    
    func register(_ request: RegisterRequest) async throws -> ApiAuthResponse {
        return try await client.execute(AuthEndpoint.register(request))
    }
    
    func loginWithGoogle(_ request: GoogleAuthRequest) async throws -> ApiAuthResponse {
        return try await client.execute(AuthEndpoint.loginWithGoogle(request))
    }
    
    func getCurrentUser() async throws -> UserResponse {
        return try await client.execute(AuthEndpoint.getCurrentUser)
    }
    
    func deleteAccount() async throws {
        try await client.executeVoid(AuthEndpoint.deleteAccount)
    }
    
    func forgotPassword(_ request: ForgotPasswordRequest) async throws {
        try await client.executeVoid(AuthEndpoint.forgotPassword(request))
    }
    
    func verifyCode(_ request: VerifyCodeRequest) async throws {
        try await client.executeVoid(AuthEndpoint.verifyCode(request))
    }
    
    func resetPassword(_ request: ResetPasswordRequest) async throws {
        try await client.executeVoid(AuthEndpoint.resetPassword(request))
    }
    
    func updateNotificationSettings(_ request: NotificationSettingsRequest) async throws {
        // Bu istek Misc veya User endpoint'ine de taşınabilir, şimdilik ApiService'de korunuyor.
        let body = try? JSONEncoder().encode(request)
        let endpoint = GenericEndpoint(path: "/api/users/notifications", method: .patch, body: body)
        try await client.executeVoid(endpoint)
    }
    
    func updatePushToken(_ request: PushTokenRequest) async throws {
        let body = try? JSONEncoder().encode(request)
        let endpoint = GenericEndpoint(path: "/api/users/push-token", method: .patch, body: body)
        try await client.executeVoid(endpoint)
    }
    
    // MARK: - Abonelik İşlemleri
    
    func getSubscriptions() async throws -> [SubscriptionResponse] {
        return try await client.execute(SubscriptionEndpoint.getSubscriptions)
    }
    
    func getSubscription(id: String) async throws -> SubscriptionResponse {
        return try await client.execute(SubscriptionEndpoint.getSubscription(id: id))
    }
    
    func createSubscription(_ request: SubscriptionRequest) async throws -> SubscriptionResponse {
        return try await client.execute(SubscriptionEndpoint.createSubscription(request))
    }
    
    func updateSubscription(id: String, _ request: SubscriptionUpdateRequest) async throws -> SubscriptionResponse {
        return try await client.execute(SubscriptionEndpoint.updateSubscription(id: id, request))
    }
    
    func deleteSubscription(id: String) async throws {
        try await client.executeVoid(SubscriptionEndpoint.deleteSubscription(id: id))
    }
    
    func getSuspiciousSubscriptions() async throws -> [SubscriptionResponse] {
        return try await client.execute(SubscriptionEndpoint.getSuspicious)
    }
    
    func approveSubscription(id: String) async throws -> SubscriptionResponse {
        return try await client.execute(SubscriptionEndpoint.approve(id: id))
    }
    
    func flagSuspicious(id: String, _ request: FlagSuspiciousRequest) async throws -> SubscriptionResponse {
        return try await client.execute(SubscriptionEndpoint.flagSuspicious(id: id, request))
    }
    
    func cancelSubscription(id: String) async throws {
        try await client.executeVoid(SubscriptionEndpoint.cancel(id: id))
    }
    
    func reactivateSubscription(id: String) async throws {
        try await client.executeVoid(SubscriptionEndpoint.reactivate(id: id))
    }
    
    func getUpcomingSubscriptions() async throws -> [SubscriptionResponse] {
        return try await client.execute(SubscriptionEndpoint.getUpcoming)
    }
    
    // MARK: - İşlemler & Diğer
    
    func getTransactions(page: Int = 0, size: Int = 20) async throws -> PageTransactionResponse {
        return try await client.execute(MiscEndpoint.getTransactions(page: page, size: size))
    }
    
    func getReminders() async throws -> [ReminderResponse] {
        return try await client.execute(MiscEndpoint.getReminders)
    }
    
    // MARK: - Analytics
    #if !WIDGET
    func getAnalyticsSummary() async throws -> AnalyticsSummaryResponse {
        return try await client.execute(AnalyticsEndpoint.getSummary)
    }
    
    func getAnalyticsTrends() async throws -> AnalyticsTrendResponse {
        return try await client.execute(AnalyticsEndpoint.getTrends)
    }
    
    func getAnalyticsInsights() async throws -> AnalyticsInsightResponse {
        return try await client.execute(AnalyticsEndpoint.getInsights)
    }
    #endif
    
    func getConvertedAmount(_ request: ConversionRequest) async throws -> Double {
        return try await client.execute(MiscEndpoint.getConvertedAmount(request))
    }
    
    func getPendingInvitations() async throws -> [SubscriptionInvitation] {
        return try await client.execute(MiscEndpoint.getPendingInvitations)
    }
    
    func acceptInvitation(id: String) async throws {
        try await client.executeVoid(MiscEndpoint.acceptInvitation(id: id))
    }
    
    func rejectInvitation(id: String) async throws {
        try await client.executeVoid(MiscEndpoint.rejectInvitation(id: id))
    }
    
    func removeParticipant(subscriptionId: String, email: String) async throws {
        try await client.executeVoid(MiscEndpoint.removeParticipant(subscriptionId: subscriptionId, email: email))
    }
    
    func verifyPurchase(_ request: PurchaseRequest) async throws -> UserResponse {
        return try await client.execute(MiscEndpoint.verifyPurchase(request))
    }
}

/// Basit veya tek seferlik istekler için kullanılan esnek endpoint yapısı.
struct GenericEndpoint: APIEndpoint {
    var path: String
    var method: HTTPMethod
    var body: Data?
    var queryItems: [URLQueryItem]? = nil
    var requiresAuth: Bool = true
}

// MARK: - Purchase Models
struct PurchaseRequest: Codable {
    let purchaseToken: String
    let productId: String
}

// MARK: - Empty Response
struct EmptyResponse: Codable {}
