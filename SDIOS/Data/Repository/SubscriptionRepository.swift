import Foundation

class SubscriptionRepository {
    static let shared = SubscriptionRepository()
    
    private let api = ApiService.shared
    
    private init() {}
    
    func getSubscriptions() async -> Result<[Subscription], Error> {
        do {
            let responses = try await api.getSubscriptions()
            return .success(responses.map { $0.toSubscription() })
        } catch {
            return .failure(error)
        }
    }
    
    func getSubscription(id: String) async -> Result<Subscription, Error> {
        do {
            let response = try await api.getSubscription(id: id)
            return .success(response.toSubscription())
        } catch {
            return .failure(error)
        }
    }
    
    func createSubscription(_ request: SubscriptionRequest) async -> Result<Subscription, Error> {
        do {
            let response = try await api.createSubscription(request)
            return .success(response.toSubscription())
        } catch {
            return .failure(error)
        }
    }
    
    func updateSubscription(id: String, _ request: SubscriptionUpdateRequest) async -> Result<Subscription, Error> {
        do {
            let response = try await api.updateSubscription(id: id, request)
            return .success(response.toSubscription())
        } catch {
            return .failure(error)
        }
    }
    
    func deleteSubscription(id: String) async -> Result<Void, Error> {
        do {
            try await api.deleteSubscription(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func getSuspiciousSubscriptions() async -> Result<[Subscription], Error> {
        do {
            let responses = try await api.getSuspiciousSubscriptions()
            return .success(responses.map { $0.toSubscription() })
        } catch {
            return .failure(error)
        }
    }
    
    func approveSubscription(id: String) async -> Result<Subscription, Error> {
        do {
            let response = try await api.approveSubscription(id: id)
            return .success(response.toSubscription())
        } catch {
            return .failure(error)
        }
    }
    
    func cancelSubscription(id: String) async -> Result<Void, Error> {
        do {
            try await api.cancelSubscription(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func reactivateSubscription(id: String) async -> Result<Void, Error> {
        do {
            try await api.reactivateSubscription(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func getUpcomingSubscriptions() async -> Result<[Subscription], Error> {
        do {
            let responses = try await api.getUpcomingSubscriptions()
            return .success(responses.map { $0.toSubscription() })
        } catch {
            return .failure(error)
        }
    }
    
    func getTransactions(page: Int = 0, size: Int = 20) async -> Result<PageTransactionResponse, Error> {
        do {
            let response = try await api.getTransactions(page: page, size: size)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func getPendingInvitations() async -> Result<[SubscriptionInvitation], Error> {
        do {
            let invitations = try await api.getPendingInvitations()
            return .success(invitations)
        } catch {
            return .failure(error)
        }
    }
    
    func acceptInvitation(id: String) async -> Result<Void, Error> {
        do {
            try await api.acceptInvitation(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func rejectInvitation(id: String) async -> Result<Void, Error> {
        do {
            try await api.rejectInvitation(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func removeParticipant(subscriptionId: String, email: String) async -> Result<Void, Error> {
        do {
            try await api.removeParticipant(subscriptionId: subscriptionId, email: email)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
