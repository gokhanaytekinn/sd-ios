import Foundation
@testable import SDIOS

class MockSubscriptionRepository: SubscriptionRepositoryProtocol {
    var subscriptionsResult: Result<[Subscription], Error> = .success([])
    var subscriptionResult: Result<Subscription, Error> = .failure(NSError(domain: "", code: -1))
    var createResult: Result<Subscription, Error> = .failure(NSError(domain: "", code: -1))
    
    func getSubscriptions() async -> Result<[Subscription], Error> {
        return subscriptionsResult
    }
    
    func getSubscription(id: String) async -> Result<Subscription, Error> {
        return subscriptionResult
    }
    
    func createSubscription(_ request: SubscriptionRequest) async -> Result<Subscription, Error> {
        return createResult
    }
    
    func updateSubscription(id: String, _ request: SubscriptionUpdateRequest) async -> Result<Subscription, Error> {
        return subscriptionResult
    }
    
    func deleteSubscription(id: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    func getSuspiciousSubscriptions() async -> Result<[Subscription], Error> {
        return subscriptionsResult
    }
    
    func approveSubscription(id: String) async -> Result<Subscription, Error> {
        return subscriptionResult
    }
    
    func cancelSubscription(id: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    func reactivateSubscription(id: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    func getUpcomingSubscriptions() async -> Result<[Subscription], Error> {
        return subscriptionsResult
    }
    
    func getTransactions(page: Int, size: Int) async -> Result<PageTransactionResponse, Error> {
        // Dummy response for PageTransactionResponse
        return .failure(NSError(domain: "", code: -1))
    }
    
    func getPendingInvitations() async -> Result<[SubscriptionInvitation], Error> {
        return .success([])
    }
    
    func acceptInvitation(id: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    func rejectInvitation(id: String) async -> Result<Void, Error> {
        return .success(())
    }
    
    func removeParticipant(subscriptionId: String, email: String) async -> Result<Void, Error> {
        return .success(())
    }
}
