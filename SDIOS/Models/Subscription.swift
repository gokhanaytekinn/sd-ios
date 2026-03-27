import Foundation

// MARK: - Subscription Status
enum SubscriptionStatus: Int, Codable {
    case active = 1
    case suspended = 2
    case cancelled = 3
    case pendingApproval = 4
}

// MARK: - Billing Cycle
enum BillingCycle: Int, Codable, CaseIterable {
    case monthly = 1
    case yearly = 2
    case weekly = 3
    case quarterly = 4
    case daily = 5
    
    static func fromString(_ value: String) -> BillingCycle {
        switch value.uppercased() {
        case "MONTHLY": return .monthly
        case "YEARLY": return .yearly
        case "WEEKLY": return .weekly
        case "QUARTERLY": return .quarterly
        case "DAILY": return .daily
        default: return .monthly
        }
    }
}

// MARK: - Invitation Participant
struct InvitationParticipant: Codable, Identifiable {
    var id: String { email }
    let email: String
    let name: String?
    let status: String // PENDING, ACCEPTED, REJECTED
}

// MARK: - Subscription
struct Subscription: Codable, Identifiable {
    let id: String
    let suspiciousReason: String?
    let responseMessage: String?
    let name: String
    let cost: Double
    let currency: Int
    let billingCycle: BillingCycle
    let billingDay: Int?
    let billingMonth: Int?
    let endDate: String?
    let category: String?
    let icon: String?
    let status: Int
    let isSuspicious: Bool
    let tier: Int?
    let reminderEnabled: Bool
    let jointEmails: [String]?
    let isOwner: Bool
    let isFreeTrial: Bool?
    let participants: [InvitationParticipant]?
    
    var isActive: Bool {
        status == 1 || status == 4
    }
    
    init(id: String, suspiciousReason: String? = nil, responseMessage: String? = nil, name: String, cost: Double, currency: Int, billingCycle: BillingCycle, billingDay: Int? = nil, billingMonth: Int? = nil, endDate: String? = nil, category: String? = nil, icon: String? = nil, status: Int = 1, isSuspicious: Bool = false, tier: Int? = nil, reminderEnabled: Bool = false, jointEmails: [String]? = nil, isOwner: Bool = true, isFreeTrial: Bool? = nil, participants: [InvitationParticipant]? = nil) {
        self.id = id
        self.suspiciousReason = suspiciousReason
        self.responseMessage = responseMessage
        self.name = name
        self.cost = cost
        self.currency = currency
        self.billingCycle = billingCycle
        self.billingDay = billingDay
        self.billingMonth = billingMonth
        self.endDate = endDate
        self.category = category
        self.icon = icon
        self.status = status
        self.isSuspicious = isSuspicious
        self.tier = tier
        self.reminderEnabled = reminderEnabled
        self.jointEmails = jointEmails
        self.isOwner = isOwner
        self.isFreeTrial = isFreeTrial
        self.participants = participants
    }
    
    func getNextRenewalDate() -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        switch billingCycle {
        case .daily:
            return now
        case .weekly:
            guard let billingDay else { return nil }
            // billingDay: 1...7 (Mon...Sun)
            let weekdayNow = ((calendar.component(.weekday, from: now) + 5) % 7) + 1
            var daysUntil = billingDay - weekdayNow
            if daysUntil < 0 { daysUntil += 7 }
            return calendar.date(byAdding: .day, value: daysUntil, to: now)
        case .yearly:
            guard let billingDay, let billingMonth else { return nil }
            var components = calendar.dateComponents([.year], from: now)
            components.month = billingMonth
            let daysInMonth = calendar.range(of: .day, in: .month, for: calendar.date(from: components) ?? now)?.count ?? 28
            components.day = min(billingDay, daysInMonth)
            
            if let target = calendar.date(from: components), target >= now {
                return target
            }
            components.year = (components.year ?? 0) + 1
            return calendar.date(from: components)
        case .monthly, .quarterly:
            guard let billingDay else { return nil }
            var components = calendar.dateComponents([.year, .month], from: now)
            let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 28
            components.day = min(billingDay, daysInMonth)
            
            if let target = calendar.date(from: components), target >= now {
                return target
            }
            let monthStep = billingCycle == .quarterly ? 3 : 1
            if let nextMonth = calendar.date(byAdding: .month, value: monthStep, to: now) {
                var nextComponents = calendar.dateComponents([.year, .month], from: nextMonth)
                let nextDaysInMonth = calendar.range(of: .day, in: .month, for: nextMonth)?.count ?? 28
                nextComponents.day = min(billingDay, nextDaysInMonth)
                return calendar.date(from: nextComponents)
            }
            return nil
        }
    }
}

// MARK: - Subscription Stats
struct SubscriptionStats: Codable {
    var totalMonthlyCost: Double = 0.0
    var totalYearlyCost: Double = 0.0
    var activeCount: Int = 0
    var cancelledCount: Int = 0
    var suspiciousCount: Int = 0
    
    static func calculate(from list: [Subscription], targetCurrency: Int = 1) -> SubscriptionStats {
        let activeSubs = list.filter { $0.isActive }
        
        let monthlyCost = activeSubs.reduce(0.0) { total, sub in
            let convertedCost = CurrencyService.shared.convert(
                amount: sub.cost,
                from: sub.currency,
                to: targetCurrency
            )
            
            switch sub.billingCycle {
            case .monthly:
                return total + convertedCost
            case .yearly:
                return total + (convertedCost / 12.0)
            case .weekly:
                return total + (convertedCost * 4.0)
            case .quarterly:
                return total + (convertedCost / 3.0)
            case .daily:
                return total + (convertedCost * 30.0)
            }
        }
        
        var stats = SubscriptionStats()
        stats.totalMonthlyCost = monthlyCost
        stats.totalYearlyCost = monthlyCost * 12.0
        stats.activeCount = activeSubs.count
        stats.cancelledCount = list.filter { $0.status == 3 }.count
        stats.suspiciousCount = list.filter { $0.isSuspicious }.count
        return stats
    }
}

// MARK: - Subscription Invitation
struct SubscriptionInvitation: Codable, Identifiable {
    let id: String
    let subscriptionName: String?
    let ownerEmail: String?
    let amount: Double?
    let currency: Int?
    let billingCycle: Int?
    let createdAt: String
    let status: String
}
