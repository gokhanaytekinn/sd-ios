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
    var entry: UpcomingProvider.Entry

    var upcomingSubs: [Subscription] {
        let tenDaysFromNow = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
        return entry.subscriptions.filter { sub in
            guard let nextDate = sub.getNextRenewalDate() else { return false }
            return nextDate <= tenDaysFromNow && sub.isActive
        }.sorted { 
            guard let d1 = $0.getNextRenewalDate(), let d2 = $1.getNextRenewalDate() else { return false }
            return d1 < d2
        }.prefix(5).map { $0 }
    }

    var body: some View {
        ZStack {
            WidgetBackground()
            
            VStack(alignment: .leading, spacing: 0) {
                WidgetHeader(title: "Yaklaşan Ödemeler", icon: "calendar")
                
                if upcomingSubs.isEmpty {
                    Spacer()
                    Text("Yaklaşan ödeme yok")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    VStack(spacing: 4) {
                        ForEach(upcomingSubs) { sub in
                            SubscriptionWidgetRow(
                                name: sub.name,
                                cost: String(format: "%.2f", sub.cost),
                                date: sub.getNextRenewalDate()?.formatted(date: .abbreviated, time: .omitted),
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

struct UpcomingPaymentsWidget: Widget {
    let kind: String = "UpcomingPaymentsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpcomingProvider()) { entry in
            UpcomingPaymentsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Yaklaşan Ödemeler")
        .description("Gelecek 10 gün içindeki ödemelerinizi gösterir.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
