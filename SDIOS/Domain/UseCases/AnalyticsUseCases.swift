import Foundation

// MARK: - Protocols
protocol GetAnalyticsSummaryUseCaseProtocol {
    func execute() async -> Result<AnalyticsSummaryResponse, Error>
}

protocol GetAnalyticsTrendsUseCaseProtocol {
    func execute() async -> Result<AnalyticsTrendResponse, Error>
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
    
    func execute() async -> Result<AnalyticsSummaryResponse, Error> {
        await repository.getSummary()
    }
}

class GetAnalyticsTrendsUseCase: GetAnalyticsTrendsUseCaseProtocol {
    private let repository: AnalyticsRepositoryProtocol
    
    init(repository: AnalyticsRepositoryProtocol = AnalyticsRepository.shared) {
        self.repository = repository
    }
    
    func execute() async -> Result<AnalyticsTrendResponse, Error> {
        await repository.getTrends()
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
