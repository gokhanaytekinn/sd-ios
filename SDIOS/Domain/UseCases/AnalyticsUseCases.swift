import Foundation

// MARK: - Protocols
protocol GetAnalyticsSummaryUseCaseProtocol {
    func execute(category: String?) async -> Result<AnalyticsSummaryResponse, Error>
}


protocol GetAnalyticsInsightsUseCaseProtocol {
    func execute() async -> Result<AnalyticsInsightResponse, Error>
}

// MARK: - Implementations
class GetAnalyticsSummaryUseCase: GetAnalyticsSummaryUseCaseProtocol {
    private let repository: AnalyticsRepositoryProtocol
    
    init(repository: AnalyticsRepositoryProtocol = AnalyticsRepository.shared) {
        self.repository = repository
    }
    
    func execute(category: String?) async -> Result<AnalyticsSummaryResponse, Error> {
        await repository.getSummary(category: category)
    }
}


class GetAnalyticsInsightsUseCase: GetAnalyticsInsightsUseCaseProtocol {
    private let repository: AnalyticsRepositoryProtocol
    
    init(repository: AnalyticsRepositoryProtocol = AnalyticsRepository.shared) {
        self.repository = repository
    }
    
    func execute() async -> Result<AnalyticsInsightResponse, Error> {
        await repository.getInsights()
    }
}
