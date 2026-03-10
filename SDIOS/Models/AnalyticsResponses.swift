import Foundation

// MARK: - Analytics Summary Response
struct AnalyticsSummaryResponse: Codable {
    let totalMonthlyCost: Double
    let totalYearlyCost: Double
    let categoryBreakdown: [String: Double]
    let currency: Int
}

// MARK: - Analytics Trend Response
struct AnalyticsTrendResponse: Codable {
    let monthlyTrends: [MonthTrend]
    
    struct MonthTrend: Codable, Identifiable {
        var id: String { month }
        let month: String
        let totalCost: Double
    }
}

// MARK: - Analytics Insight Response
struct AnalyticsInsightResponse: Codable {
    let insights: [String]
}
