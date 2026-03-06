import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var upcomingSubscriptions: [Subscription] = []
    @Published var stats: SubscriptionStats = SubscriptionStats()
    @Published var isLoading = true
    @Published var error: String?
    
    private let repository = SubscriptionRepository.shared
    
    func loadDashboard() {
        Task {
            isLoading = true
            error = nil
            
            async let subsResult = repository.getSubscriptions()
            async let statsResult = repository.getStats()
            async let upcomingResult = repository.getUpcomingSubscriptions()
            
            let (subs, st, upcoming) = await (subsResult, statsResult, upcomingResult)
            
            switch subs {
            case .success(let list):
                subscriptions = list.filter { $0.isActive }.sorted { $0.cost > $1.cost }
            case .failure(let err):
                error = err.localizedDescription
            }
            
            switch st {
            case .success(let s):
                stats = s
            case .failure: break
            }
            
            switch upcoming {
            case .success(let list):
                upcomingSubscriptions = list
            case .failure: break
            }
            
            isLoading = false
        }
    }
}
