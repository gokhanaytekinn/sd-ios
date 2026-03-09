import Foundation

/// Abonelik verilerini yöneten repository protokolü.
protocol SubscriptionRepositoryProtocol {
    func getSubscriptions() async -> Result<[Subscription], Error>
    func getSubscription(id: String) async -> Result<Subscription, Error>
    func createSubscription(_ request: SubscriptionRequest) async -> Result<Subscription, Error>
    func updateSubscription(id: String, _ request: SubscriptionUpdateRequest) async -> Result<Subscription, Error>
    func deleteSubscription(id: String) async -> Result<Void, Error>
    func getSuspiciousSubscriptions() async -> Result<[Subscription], Error>
    func approveSubscription(id: String) async -> Result<Subscription, Error>
    func cancelSubscription(id: String) async -> Result<Void, Error>
    func reactivateSubscription(id: String) async -> Result<Void, Error>
    func getUpcomingSubscriptions() async -> Result<[Subscription], Error>
    func getTransactions(page: Int, size: Int) async -> Result<PageTransactionResponse, Error>
    func getPendingInvitations() async -> Result<[SubscriptionInvitation], Error>
    func acceptInvitation(id: String) async -> Result<Void, Error>
    func rejectInvitation(id: String) async -> Result<Void, Error>
    func removeParticipant(subscriptionId: String, email: String) async -> Result<Void, Error>
}
