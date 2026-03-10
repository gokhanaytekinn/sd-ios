import Foundation

class AnalyticsRepository: AnalyticsRepositoryProtocol {
    static let shared: AnalyticsRepositoryProtocol = AnalyticsRepository()
    
    private let api: ApiServiceProtocol
    
    init(api: ApiServiceProtocol = ApiService.shared) {
        self.api = api
    }
    
    func getSummary() async -> Result<AnalyticsSummaryResponse, Error> {
        do {
            let response = try await api.getAnalyticsSummary()
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func getTrends() async -> Result<AnalyticsTrendResponse, Error> {
        do {
            let response = try await api.getAnalyticsTrends()
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func getInsights() async -> Result<AnalyticsInsightResponse, Error> {
        do {
            let response = try await api.getAnalyticsInsights()
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
