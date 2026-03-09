import Foundation
@testable import SDIOS

class MockApiService: ApiServiceProtocol {
    var subscriptionsResponse: [SubscriptionResponse] = []
    var subscriptionResponse: SubscriptionResponse?
    var authResponse: ApiAuthResponse?
    var userResponse: UserResponse?
    var error: Error?
    
    func login(_ request: LoginRequest) async throws -> ApiAuthResponse {
        if let error = error { throw error }
        return authResponse!
    }
    
    func register(_ request: RegisterRequest) async throws -> ApiAuthResponse {
        if let error = error { throw error }
        return authResponse!
    }
    
    func loginWithGoogle(_ request: GoogleAuthRequest) async throws -> ApiAuthResponse {
        if let error = error { throw error }
        return authResponse!
    }
    
    func getCurrentUser() async throws -> UserResponse {
        if let error = error { throw error }
        return userResponse!
    }
    
    func deleteAccount() async throws {}
    func forgotPassword(_ request: ForgotPasswordRequest) async throws {}
    func verifyCode(_ request: VerifyCodeRequest) async throws {}
    func resetPassword(_ request: ResetPasswordRequest) async throws {}
    func updateNotificationSettings(_ request: NotificationSettingsRequest) async throws {}
    func updatePushToken(_ request: PushTokenRequest) async throws {}
    
    func getSubscriptions() async throws -> [SubscriptionResponse] {
        if let error = error { throw error }
        return subscriptionsResponse
    }
    
    func getSubscription(id: String) async throws -> SubscriptionResponse {
        if let error = error { throw error }
        return subscriptionResponse!
    }
    
    func createSubscription(_ request: SubscriptionRequest) async throws -> SubscriptionResponse {
        if let error = error { throw error }
        return subscriptionResponse!
    }
    
    func updateSubscription(id: String, _ request: SubscriptionUpdateRequest) async throws -> SubscriptionResponse {
        if let error = error { throw error }
        return subscriptionResponse!
    }
    
    func deleteSubscription(id: String) async throws {}
    func getSuspiciousSubscriptions() async throws -> [SubscriptionResponse] { return [] }
    func approveSubscription(id: String) async throws -> SubscriptionResponse { return subscriptionResponse! }
    func flagSuspicious(id: String, _ request: FlagSuspiciousRequest) async throws -> SubscriptionResponse { return subscriptionResponse! }
    func cancelSubscription(id: String) async throws {}
    func reactivateSubscription(id: String) async throws {}
    func getUpcomingSubscriptions() async throws -> [SubscriptionResponse] { return [] }
    
    func getTransactions(page: Int, size: Int) async throws -> PageTransactionResponse {
        return PageTransactionResponse(content: [], totalElements: 0, totalPages: 0, size: size, number: page)
    }
    
    func getReminders() async throws -> [ReminderResponse] { return [] }
    func getConvertedAmount(_ request: ConversionRequest) async throws -> Double { return 0.0 }
    func getPendingInvitations() async throws -> [SubscriptionInvitation] { return [] }
    func acceptInvitation(id: String) async throws {}
    func rejectInvitation(id: String) async throws {}
    func removeParticipant(subscriptionId: String, email: String) async throws {}
    func verifyPurchase(_ request: PurchaseRequest) async throws -> UserResponse { return userResponse! }
}
