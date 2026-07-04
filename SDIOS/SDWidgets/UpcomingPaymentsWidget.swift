import WidgetKit
import SwiftUI

struct UpcomingProvider: TimelineProvider {
    func placeholder(in context: Context) -> UpcomingEntry {
        UpcomingEntry(date: Date(), subscriptions: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (UpcomingEntry) -> ()) {
        let subs = WidgetDataManager.shared.loadSnapshot()
        let entry = UpcomingEntry(date: Date(), subscriptions: subs)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let subs = WidgetDataManager.shared.loadSnapshot()
        let entry = UpcomingEntry(date: Date(), subscriptions: subs)
        
        // Refresh every hour or when app updates it
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct UpcomingEntry: TimelineEntry {
    let date: Date
    let subscriptions: [Subscription]
}

struct UpcomingPaymentsWidgetView : View {
    @Environment(\.widgetFamily) var family
    var entry: UpcomingProvider.Entry
    
    private var selectedLanguage: String {
        let defaults = UserDefaults(suiteName: "group.com.subtracker.SDiOS")
        return defaults?.string(forKey: "selectedLanguage") ?? "en"
    }

    var upcomingSubs: [Subscription] {
        let count = family == .systemLarge ? 5 : 2
        let tenDaysFromNow = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
        return entry.subscriptions.filter { sub in
            guard let nextDate = sub.getNextRenewalDate() else { return false }
            return nextDate <= tenDaysFromNow && sub.isActive
        }.sorted { 
            guard let d1 = $0.getNextRenewalDate(), let d2 = $1.getNextRenewalDate() else { return false }
            return d1 < d2
        }.prefix(count).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WidgetHeader(title: "widget_upcoming_title".widgetLocalized(), icon: "calendar")
            
            if upcomingSubs.isEmpty {
                Spacer()
                Text("no_upcoming_payments".widgetLocalized())
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            } else {
                VStack(spacing: family == .systemLarge ? 12 : 8) {
                    ForEach(upcomingSubs) { sub in
                        SubscriptionWidgetRow(
                            name: sub.name,
                            cost: CurrencyFormatter.formatAmount(sub.cost, currencyCode: sub.currency),
                            date: recurrenceText(for: sub),
                            icon: sub.icon,
                            cycle: sub.billingCycle
                        )
                    }
                    if family == .systemLarge {
                        Spacer()
                    } else {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
    
    private func recurrenceText(for sub: Subscription) -> String? {
        switch sub.billingCycle {
        case .daily:
            return "billing_daily_label".widgetLocalized()
        case .weekly:
            if let day = sub.billingDay {
                return String(format: "billing_weekly_label_day".widgetLocalized(), day)
            }
            return "billing_weekly_label".widgetLocalized()
        case .monthly:
            if let day = sub.billingDay {
                return DateUtils.formatMonthlyRenewal(day: day, language: selectedLanguage)
            }
            return nil
        case .yearly:
            if let day = sub.billingDay, let month = sub.billingMonth {
                return DateUtils.formatYearlyRenewal(day: day, month: month, language: selectedLanguage)
            }
            return nil
        case .quarterly:
            if let day = sub.billingDay {
                return DateUtils.formatMonthlyRenewal(day: day, language: selectedLanguage)
            }
            return nil
        }
    }
}

struct UpcomingPaymentsWidget: Widget {
    let kind: String = "UpcomingPaymentsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpcomingProvider()) { entry in
            UpcomingPaymentsWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("widget_upcoming_title".widgetLocalized())
        .description("widget_upcoming_desc".widgetLocalized())
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
