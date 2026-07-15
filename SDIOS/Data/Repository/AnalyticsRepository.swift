import Foundation

class AnalyticsRepository: AnalyticsRepositoryProtocol {
    static let shared: AnalyticsRepositoryProtocol = AnalyticsRepository()
    
    private let api: ApiServiceProtocol
    
    init(api: ApiServiceProtocol = ApiService.shared) {
        self.api = api
    }
    
    func getSummary(category: String?) async -> Result<AnalyticsSummaryResponse, Error> {
        do {
            let response = try await api.getAnalyticsSummary(category: category)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
