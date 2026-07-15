import Foundation

// MARK: - Protocols
protocol GetAnalyticsSummaryUseCaseProtocol {
    func execute(category: String?) async -> Result<AnalyticsSummaryResponse, Error>
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
