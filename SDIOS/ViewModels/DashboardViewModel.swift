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
    var authViewModel: AuthViewModel?
    
    func loadDashboard() {
        Task {
            isLoading = true
            error = nil
            
            async let subsResult = repository.getSubscriptions()
            async let upcomingResult = repository.getUpcomingSubscriptions()
            
            let (subs, upcoming) = await (subsResult, upcomingResult)
            
            switch subs {
            case .success(let list):
                subscriptions = list.filter { $0.isActive }.sorted { $0.cost > $1.cost }
                stats = SubscriptionStats.calculate(from: list)
                authViewModel?.subscriptionCount = list.count
            case .failure(let err):
                error = err.localizedDescription
            }
            
            switch upcoming {
            case .success(let list):
                let tenDaysFromNow = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
                upcomingSubscriptions = list.filter { sub in
                    guard let nextDate = sub.getNextRenewalDate() else { return false }
                    return nextDate <= tenDaysFromNow
                }.sorted { 
                    guard let d1 = $0.getNextRenewalDate(), let d2 = $1.getNextRenewalDate() else { return false }
                    return d1 < d2
                }
            case .failure: break
            }
            
            isLoading = false
        }
    }
}
