import SwiftUI
import Combine

#if !WIDGET
@MainActor
class AnalyticsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var summary: AnalyticsSummaryResponse?
    @Published var insights: [String] = []
    @Published var selectedCategory: String = "All"
    
    static func colorForCategory(_ category: String) -> Color {
        switch category {
        case "category_streaming": return Color(hex: "E50914") // Netflix Red
        case "category_gaming": return Color(hex: "7289DA") // Discord Blue
        case "category_software": return Color(hex: "0078D4") // Office Blue
        case "category_shopping": return Color(hex: "FF9900") // Amazon Orange
        case "category_entertainment": return Color(hex: "9D50BB") // Purple
        case "category_music": return Color(hex: "1DB954") // Spotify Green
        case "category_sports": return Color(hex: "003594") // NFL Blue
        case "category_education": return Color(hex: "1C8ADB") // Blue
        case "category_cloud": return Color(hex: "4285F4") // Google Blue
        case "category_ecommerce": return Color(hex: "5CB333") // Green
        case "category_news": return Color(hex: "333333") // Dark Grey
        case "category_transport": return Color(hex: "000000") // Black
        case "category_finance": return Color(hex: "2ECC71") // Emerald
        case "category_technology": return Color(hex: "3498DB") // Peter River
        case "category_other": return Color.gray
        default: return Color.primaryBlue
        }
    }
    
    @Published var categories: [String] = ["All", "category_streaming", "category_gaming", "category_software", "category_shopping", "category_entertainment", "category_music", "category_sports", "category_education", "category_cloud", "category_ecommerce", "category_news", "category_transport", "category_finance", "category_technology", "category_other"]
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
