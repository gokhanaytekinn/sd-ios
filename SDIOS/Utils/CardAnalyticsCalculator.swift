import Foundation

struct CardSpendingGroup: Identifiable {
    let id: String
    let displayName: String
    let monthlyAmount: Double
    let subscriptionCount: Int
}

struct CardAnalyticsSummary {
    let groups: [CardSpendingGroup]
    let topCard: CardSpendingGroup?
    let topCardSharePercent: Double
    let uniqueCardCount: Int
    let labeledSubscriptionCount: Int
    let missingCardInfoCount: Int
    let totalLabeledMonthlyAmount: Double
    
    static let empty = CardAnalyticsSummary(
        groups: [],
        topCard: nil,
        topCardSharePercent: 0,
        uniqueCardCount: 0,
        labeledSubscriptionCount: 0,
        missingCardInfoCount: 0,
        totalLabeledMonthlyAmount: 0
    )
}

enum CardAnalyticsCalculator {
    static func normalizeCardKey(_ cardInfo: String?) -> String? {
        guard let raw = cardInfo?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }
        return raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
    }
    
    static func monthlyAmount(for subscription: Subscription, targetCurrency: Int) -> Double {
        let convertedCost = CurrencyService.shared.convert(
            amount: subscription.cost,
            from: subscription.currency,
            to: targetCurrency
        )
        
        switch subscription.billingCycle {
        case .monthly:
            return convertedCost
        case .yearly:
            return convertedCost / 12.0
        case .weekly:
            return convertedCost * 4.0
        case .quarterly:
            return convertedCost / 3.0
        case .daily:
            return convertedCost * 30.0
        }
    }
    
    static func filteredActiveSubscriptions(
        from subscriptions: [Subscription],
        category: String
    ) -> [Subscription] {
        let active = subscriptions.filter { $0.isActive }
        guard category != "All" else { return active }
        return active.filter { $0.category == category }
    }
    
    static func calculate(
        from subscriptions: [Subscription],
        category: String,
        targetCurrency: Int
    ) -> CardAnalyticsSummary {
        let filtered = filteredActiveSubscriptions(from: subscriptions, category: category)
        guard !filtered.isEmpty else { return .empty }
        
        var groupsByKey: [String: (displayName: String, amount: Double, count: Int)] = [:]
        var missingCount = 0
        
        for sub in filtered {
            guard let key = normalizeCardKey(sub.cardInfo),
                  let displayName = sub.cardInfo?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !displayName.isEmpty else {
                missingCount += 1
                continue
            }
            
            let amount = monthlyAmount(for: sub, targetCurrency: targetCurrency)
            if var existing = groupsByKey[key] {
                existing.amount += amount
                existing.count += 1
                groupsByKey[key] = existing
            } else {
                groupsByKey[key] = (displayName: displayName, amount: amount, count: 1)
            }
        }
        
        let groups = groupsByKey.map { key, value in
            CardSpendingGroup(
                id: key,
                displayName: value.displayName,
                monthlyAmount: value.amount,
                subscriptionCount: value.count
            )
        }.sorted { $0.monthlyAmount > $1.monthlyAmount }
        
        let totalLabeled = groups.reduce(0.0) { $0 + $1.monthlyAmount }
        let topCard = groups.first
        let sharePercent: Double
        if let top = topCard, totalLabeled > 0 {
            sharePercent = (top.monthlyAmount / totalLabeled) * 100.0
        } else {
            sharePercent = 0
        }
        
        let labeledCount = groups.reduce(0) { $0 + $1.subscriptionCount }
        
        return CardAnalyticsSummary(
            groups: groups,
            topCard: topCard,
            topCardSharePercent: sharePercent,
            uniqueCardCount: groups.count,
            labeledSubscriptionCount: labeledCount,
            missingCardInfoCount: missingCount,
            totalLabeledMonthlyAmount: totalLabeled
        )
    }
    
    static func peakDayCardBreakdown(
        events: [CalendarEvent],
        subscriptions: [Subscription],
        peakDay: Int,
        calendarMonth: Date,
        category: String,
        calendar: Calendar = .current
    ) -> [(displayName: String, amount: Double)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let monthComponents = calendar.dateComponents([.year, .month], from: calendarMonth)
        
        let dayEvents = events.filter { event in
            guard let date = formatter.date(from: event.paymentDate) else { return false }
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            guard components.year == monthComponents.year,
                  components.month == monthComponents.month,
                  components.day == peakDay else { return false }
            
            if category == "All" { return true }
            return subscriptions.first(where: { $0.id == event.subscriptionId })?.category == category
        }
        
        var totals: [String: (displayName: String, amount: Double)] = [:]
        
        for event in dayEvents {
            guard let sub = subscriptions.first(where: { $0.id == event.subscriptionId }),
                  let key = normalizeCardKey(sub.cardInfo),
                  let displayName = sub.cardInfo?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !displayName.isEmpty else { continue }
            
            if var existing = totals[key] {
                existing.amount += event.amount
                totals[key] = existing
            } else {
                totals[key] = (displayName: displayName, amount: event.amount)
            }
        }
        
        return totals.values.sorted { $0.amount > $1.amount }
    }
}
