import Foundation

/// API servisinin uyması gereken kuralları tanımlayan protokol.
/// Dünya standartlarında, somut sınıflar yerine bu protokoller üzerinden iletişim kurulur.
protocol ApiServiceProtocol {
    // Auth Endpoints
    func login(_ request: LoginRequest) async throws -> ApiAuthResponse
    func register(_ request: RegisterRequest) async throws -> ApiAuthResponse
    func loginWithGoogle(_ request: GoogleAuthRequest) async throws -> ApiAuthResponse
    func getCurrentUser() async throws -> UserResponse
    func deleteAccount() async throws
    func forgotPassword(_ request: ForgotPasswordRequest) async throws
    func verifyCode(_ request: VerifyCodeRequest) async throws
    func resetPassword(_ request: ResetPasswordRequest) async throws
    func updateNotificationSettings(_ request: NotificationSettingsRequest) async throws
    func updatePushToken(_ request: PushTokenRequest) async throws
    
    // Subscription Endpoints
    func getSubscriptions() async throws -> [SubscriptionResponse]
    func getSubscription(id: String) async throws -> SubscriptionResponse
    func createSubscription(_ request: SubscriptionRequest) async throws -> SubscriptionResponse
    func updateSubscription(id: String, _ request: SubscriptionUpdateRequest) async throws -> SubscriptionResponse
    func deleteSubscription(id: String) async throws
    func getSuspiciousSubscriptions() async throws -> [SubscriptionResponse]
    func approveSubscription(id: String) async throws -> SubscriptionResponse
    func flagSuspicious(id: String, _ request: FlagSuspiciousRequest) async throws -> SubscriptionResponse
    func cancelSubscription(id: String) async throws
    func reactivateSubscription(id: String) async throws
    func getUpcomingSubscriptions() async throws -> [SubscriptionResponse]
    
    // Transactions
    func getTransactions(page: Int, size: Int) async throws -> PageTransactionResponse
    
    // Reminders
    func getReminders() async throws -> [ReminderResponse]
    
    // Analytics
    #if !WIDGET
    func getAnalyticsSummary(category: String?) async throws -> AnalyticsSummaryResponse

    func getAnalyticsInsights() async throws -> AnalyticsInsightResponse
    #endif
    func getConvertedAmount(_ request: ConversionRequest) async throws -> Double
    
    // Invitations
    func getPendingInvitations() async throws -> [SubscriptionInvitation]
    func acceptInvitation(id: String) async throws
    func rejectInvitation(id: String) async throws
    func removeParticipant(subscriptionId: String, email: String) async throws
    
    // Purchase
    func verifyPurchase(_ request: PurchaseRequest) async throws -> UserResponse
}
