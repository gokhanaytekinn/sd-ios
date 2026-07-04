import Foundation

// MARK: - Analytics Summary Response
struct AnalyticsSummaryResponse: Codable {
    let totalMonthlyCost: Double
    let totalYearlyCost: Double
    let lifetimeSpent: [String: LifetimeMetric]
    let categoryBreakdown: [String: Double]
    let calendarEvents: [CalendarEvent]
    let currency: Int
    
    struct LifetimeMetric: Codable, Identifiable {
        var id: String { name }
        let name: String
        let totalAmount: Double
        let icon: String?
    }
}

struct CalendarEvent: Codable, Identifiable {
    var id: String { "\(subscriptionId)-\(paymentDate)" }
    let subscriptionId: String
    let subscriptionName: String
    let amount: Double
    let paymentDate: String // "YYYY-MM-DD"
    let icon: String?
}

struct UpcomingPayment: Codable, Identifiable {
    var id: String { subscriptionId + paymentDate }
    let subscriptionName: String
    let subscriptionId: String
    let amount: Double
    let paymentDate: String // ISO date string
    let icon: String?
}
