import Foundation

protocol AnalyticsRepositoryProtocol {
    func getSummary() async -> Result<AnalyticsSummaryResponse, Error>
    func getTrends() async -> Result<AnalyticsTrendResponse, Error>
    func getInsights() async -> Result<AnalyticsInsightResponse, Error>
}
