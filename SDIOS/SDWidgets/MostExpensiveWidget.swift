import WidgetKit
import SwiftUI

struct ExpensiveProvider: TimelineProvider {
    func placeholder(in context: Context) -> ExpensiveEntry {
        ExpensiveEntry(date: Date(), subscriptions: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (ExpensiveEntry) -> ()) {
        let subs = WidgetDataManager.shared.loadSnapshot()
        let entry = ExpensiveEntry(date: Date(), subscriptions: subs)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let subs = WidgetDataManager.shared.loadSnapshot()
        let entry = ExpensiveEntry(date: Date(), subscriptions: subs)
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct ExpensiveEntry: TimelineEntry {
    let date: Date
    let subscriptions: [Subscription]
}

struct MostExpensiveWidgetView : View {
    @Environment(\.widgetFamily) var family
    var entry: ExpensiveProvider.Entry

    var expensiveSubs: [Subscription] {
        let count = family == .systemLarge ? 5 : 2
        return entry.subscriptions
            .filter { $0.isActive }
            .sorted { $0.cost > $1.cost }
            .prefix(count)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(title: "widget_expensive_title".widgetLocalized(), icon: "creditcard.fill")
            
            if expensiveSubs.isEmpty {
                Spacer()
                Text("no_subscriptions".widgetLocalized())
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            } else {
                VStack(spacing: family == .systemLarge ? 12 : 6) {
                    ForEach(expensiveSubs) { sub in
                        SubscriptionWidgetRow(
                            name: sub.name,
                            cost: CurrencyFormatter.formatAmount(sub.cost, currencyCode: sub.currency),
                            date: sub.billingCycle == .monthly ? "billing_monthly_label".widgetLocalized() : "billing_yearly_label".widgetLocalized(),
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
}

struct MostExpensiveWidget: Widget {
    let kind: String = "MostExpensiveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExpensiveProvider()) { entry in
            MostExpensiveWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("widget_expensive_title".widgetLocalized())
        .description("widget_expensive_desc".widgetLocalized())
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
