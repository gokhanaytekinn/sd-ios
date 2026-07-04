import Foundation

protocol AnalyticsRepositoryProtocol {
    func getSummary(category: String?) async -> Result<AnalyticsSummaryResponse, Error>

    func getInsights() async -> Result<AnalyticsInsightResponse, Error>
}
