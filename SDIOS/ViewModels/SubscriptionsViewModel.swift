import SwiftUI
import Combine

@MainActor
class SubscriptionsViewModel: ObservableObject {
    @Published var allSubscriptions: [Subscription] = []
    @Published var invitations: [SubscriptionInvitation] = []
    @Published var stats: SubscriptionStats = SubscriptionStats()
    @Published var isLoading = true
    @Published var error: String?
    
    private let repository = SubscriptionRepository.shared
    
    var activeSubscriptions: [Subscription] {
        allSubscriptions.filter { $0.status == 1 }
    }
    
    var suspiciousSubscriptions: [Subscription] {
        allSubscriptions.filter { $0.isSuspicious || $0.status == 4 }
    }
    
    var cancelledSubscriptions: [Subscription] {
        allSubscriptions.filter { $0.status == 3 }
    }
    
    func loadSubscriptions() {
        Task {
            isLoading = true
            error = nil
            
            async let subsResult = repository.getSubscriptions()
            async let statsResult = repository.getStats()
            async let invitationsResult = repository.getPendingInvitations()
            
            let (subs, st, inv) = await (subsResult, statsResult, invitationsResult)
            
            switch subs {
            case .success(let list): allSubscriptions = list
            case .failure(let err): error = err.localizedDescription
            }
            
            switch st {
            case .success(let s): stats = s
            case .failure: break
            }
            
            switch inv {
            case .success(let list): invitations = list
            case .failure: break
            }
            
            isLoading = false
        }
    }
    
    func acceptInvitation(id: String) {
        Task {
            let result = await repository.acceptInvitation(id: id)
            if case .success = result {
                invitations.removeAll { $0.id == id }
                loadSubscriptions()
            }
        }
    }
    
    func rejectInvitation(id: String) {
        Task {
            let result = await repository.rejectInvitation(id: id)
            if case .success = result {
                invitations.removeAll { $0.id == id }
            }
        }
    }
    
    func deleteSubscription(id: String) {
        Task {
            let result = await repository.deleteSubscription(id: id)
            if case .success = result {
                allSubscriptions.removeAll { $0.id == id }
            }
        }
    }
    
    func cancelSubscription(id: String) {
        Task {
            let result = await repository.cancelSubscription(id: id)
            if case .success(let sub) = result {
                if let index = allSubscriptions.firstIndex(where: { $0.id == id }) {
                    allSubscriptions[index] = sub
                }
            }
        }
    }
    
    func reactivateSubscription(id: String) {
        Task {
            let result = await repository.reactivateSubscription(id: id)
            if case .success(let sub) = result {
                if let index = allSubscriptions.firstIndex(where: { $0.id == id }) {
                    allSubscriptions[index] = sub
                }
            }
        }
    }
}
