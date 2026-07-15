import SwiftUI
import Combine

#if !WIDGET
@MainActor
class AnalyticsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var summary: AnalyticsSummaryResponse?
    @Published var selectedCategory: String = "All"
    
    static func colorForCategory(_ category: String) -> Color {
        switch category {
        case "category_streaming": return Color(hex: "E50914") // Netflix Red
        case "category_gaming": return Color(hex: "7289DA") // Discord Blue
        case "category_software": return Color(hex: "0078D4") // Office Blue
        case "category_shopping": return Color(hex: "FF9900") // Amazon Orange
        case "category_education": return Color(hex: "1C8ADB") // Blue
        case "category_transport": return Color(hex: "000000") // Black
        case "category_other": return Color.gray
        default: return Color.primaryBlue
        }
    }
    
    @Published var categories: [String] = ["All", "category_streaming", "category_gaming", "category_software", "category_shopping", "category_education", "category_transport", "category_other"]
    @Published var allSubscriptions: [Subscription] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Use Cases
    private let getSummaryUseCase: GetAnalyticsSummaryUseCaseProtocol
    private let getSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol
    
    var authViewModel: AuthViewModel?
    
    var isPremium: Bool {
        guard let auth = authViewModel else { return false }
        // tier 2 is monthly, 3 is yearly
        return auth.tier >= 2
    }
    
    init(
        getSummaryUseCase: GetAnalyticsSummaryUseCaseProtocol? = nil,
        getSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol? = nil
    ) {
        self.getSummaryUseCase = getSummaryUseCase ?? GetAnalyticsSummaryUseCase()
        self.getSubscriptionsUseCase = getSubscriptionsUseCase ?? GetSubscriptionsUseCase()
    }
    
    func loadAnalytics() {
        Task {
            isLoading = true
            error = nil
            
            // We fetch even if not premium to show blurred preview
            async let summaryResult = getSummaryUseCase.execute(category: selectedCategory)
            async let subsResult = getSubscriptionsUseCase.execute()
            
            let (summaryRes, subsRes) = await (summaryResult, subsResult)
            
            switch summaryRes {
            case .success(let data):
                self.summary = data
            case .failure(let err):
                self.error = err.localizedDescription
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
