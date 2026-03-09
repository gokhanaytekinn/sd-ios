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
    var entry: ExpensiveProvider.Entry

    var expensiveSubs: [Subscription] {
        return entry.subscriptions
            .filter { $0.isActive }
            .sorted { $0.cost > $1.cost }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        ZStack {
            WidgetBackground()
            
            VStack(alignment: .leading, spacing: 0) {
                WidgetHeader(title: "En Pahalı Ödemeler", icon: "dollarsign.circle")
                
                if expensiveSubs.isEmpty {
                    Spacer()
                    Text("Abonelik bulunamadı")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    VStack(spacing: 4) {
                        ForEach(expensiveSubs) { sub in
                            SubscriptionWidgetRow(
                                name: sub.name,
                                cost: String(format: "%.2f", sub.cost),
                                date: sub.billingCycle == .monthly ? "Aylık" : "Yıllık",
                                icon: sub.icon
                            )
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct MostExpensiveWidget: Widget {
    let kind: String = "MostExpensiveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExpensiveProvider()) { entry in
            MostExpensiveWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("En Pahalı Ödemeler")
        .description("En yüksek tutarlı 5 aboneliğinizi listeler.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
