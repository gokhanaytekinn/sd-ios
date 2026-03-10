import SwiftUI
import Combine

#if !WIDGET
@MainActor
class AnalyticsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var summary: AnalyticsSummaryResponse?
    @Published var insights: [String] = []
    @Published var selectedCategory: String = "All" {
        didSet {
            if oldValue != selectedCategory {
                loadAnalytics()
            }
        }
    }
    
    @Published var categories: [String] = ["All", "Entertainment", "Productivity", "Finance", "Health", "Shopping", "Other"]
    @Published var allSubscriptions: [Subscription] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Use Cases
    private let getSummaryUseCase: GetAnalyticsSummaryUseCaseProtocol
    private let getInsightsUseCase: GetAnalyticsInsightsUseCaseProtocol
    private let getSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol
    
    var authViewModel: AuthViewModel?
    
    var isPremium: Bool {
        guard let auth = authViewModel else { return false }
        // tier 2 is monthly, 3 is yearly
        return auth.tier >= 2
    }
    
    init(
        getSummaryUseCase: GetAnalyticsSummaryUseCaseProtocol? = nil,
        getInsightsUseCase: GetAnalyticsInsightsUseCaseProtocol? = nil,
        getSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol? = nil
    ) {
        self.getSummaryUseCase = getSummaryUseCase ?? GetAnalyticsSummaryUseCase()
        self.getInsightsUseCase = getInsightsUseCase ?? GetAnalyticsInsightsUseCase()
        self.getSubscriptionsUseCase = getSubscriptionsUseCase ?? GetSubscriptionsUseCase()
    }
    
    func loadAnalytics() {
        Task {
            isLoading = true
            error = nil
            
            // We fetch even if not premium to show blurred preview
            async let summaryResult = getSummaryUseCase.execute(category: selectedCategory)
            async let insightsResult = getInsightsUseCase.execute()
            async let subsResult = getSubscriptionsUseCase.execute()
            
            let (summaryRes, insightsRes, subsRes) = await (summaryResult, insightsResult, subsResult)
            
            switch summaryRes {
            case .success(let data):
                self.summary = data
            case .failure(let err):
                self.error = err.localizedDescription
            }
            
            
            switch insightsRes {
            case .success(let data):
                self.insights = data.insights
            case .failure:
                break
            }
            
            switch subsRes {
            case .success(let data):
                self.allSubscriptions = data
            case .failure:
                break
            }
            
            isLoading = false
        }
    }
}
#endif
