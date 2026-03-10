import SwiftUI
import Combine

#if !WIDGET
@MainActor
class AnalyticsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var summary: AnalyticsSummaryResponse?
    @Published var trends: [AnalyticsTrendResponse.MonthTrend] = []
    @Published var insights: [String] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Use Cases
    private let getSummaryUseCase: GetAnalyticsSummaryUseCaseProtocol
    private let getTrendsUseCase: GetAnalyticsTrendsUseCaseProtocol
    private let getInsightsUseCase: GetAnalyticsInsightsUseCaseProtocol
    
    var authViewModel: AuthViewModel?
    
    var isPremium: Bool {
        guard let auth = authViewModel else { return false }
        // tier 2 is monthly, 3 is yearly
        return auth.tier >= 2
    }
    
    init(
        getSummaryUseCase: GetAnalyticsSummaryUseCaseProtocol = GetAnalyticsSummaryUseCase(),
        getTrendsUseCase: GetAnalyticsTrendsUseCaseProtocol = GetAnalyticsTrendsUseCase(),
        getInsightsUseCase: GetAnalyticsInsightsUseCaseProtocol = GetAnalyticsInsightsUseCase()
    ) {
        self.getSummaryUseCase = getSummaryUseCase
        self.getTrendsUseCase = getTrendsUseCase
        self.getInsightsUseCase = getInsightsUseCase
    }
    
    func loadAnalytics() {
        Task {
            isLoading = true
            error = nil
            
            // We fetch even if not premium to show blurred preview
            async let summaryResult = getSummaryUseCase.execute()
            async let trendsResult = getTrendsUseCase.execute()
            async let insightsResult = getInsightsUseCase.execute()
            
            let (summaryRes, trendsRes, insightsRes) = await (summaryResult, trendsResult, insightsResult)
            
            switch summaryRes {
            case .success(let data):
                self.summary = data
            case .failure(let err):
                self.error = err.localizedDescription
            }
            
            switch trendsRes {
            case .success(let data):
                self.trends = data.monthlyTrends
            case .failure:
                break // Trends failure is non-critical for preview
            }
            
            switch insightsRes {
            case .success(let data):
                self.insights = data.insights
            case .failure:
                break
            }
            
            isLoading = false
        }
    }
}
#endif
