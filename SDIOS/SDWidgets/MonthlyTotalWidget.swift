import WidgetKit
import SwiftUI

#if !WIDGET
// Provide these only to the main app target (SDIOS) 
// The widget extension (SDWidgetsExtension) already has them in WidgetViews.swift
struct WidgetHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
}

extension String {
    func widgetLocalized() -> String {
        let defaults = UserDefaults(suiteName: "group.com.subtracker.SDiOS")
        let langCode = defaults?.string(forKey: "selectedLanguage") ?? "en"
        
        if let path = Bundle.main.path(forResource: langCode, ofType: "lproj"),
           let langBundle = Bundle(path: path) {
            
            let translated = NSLocalizedString(self, tableName: "WidgetLocalizable", bundle: langBundle, comment: "")
            if translated != self { return translated }
            return NSLocalizedString(self, bundle: langBundle, comment: "")
        }
        
        let bundle = Bundle.main
        let translated = NSLocalizedString(self, tableName: "WidgetLocalizable", bundle: bundle, comment: "")
        if translated != self { return translated }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
#endif

struct MonthlyTotalProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonthlyTotalEntry {
        MonthlyTotalEntry(date: Date(), totalMonthly: 0.0, currency: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (MonthlyTotalEntry) -> ()) {
        let entry = calculateEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = calculateEntry()
        
        // Refresh every hour or when app updates it
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func calculateEntry() -> MonthlyTotalEntry {
        let subs = WidgetDataManager.shared.loadSnapshot()
        
        let defaults = UserDefaults(suiteName: "group.com.subtracker.SDiOS")
        let currency = defaults?.integer(forKey: "selectedCurrency") ?? 1
        
        let stats = SubscriptionStats.calculate(from: subs, targetCurrency: currency)
        
        return MonthlyTotalEntry(
            date: Date(),
            totalMonthly: stats.totalMonthlyCost,
            currency: currency
        )
    }
}

struct MonthlyTotalEntry: TimelineEntry {
    let date: Date
    let totalMonthly: Double
    let currency: Int
}

struct MonthlyTotalWidgetView : View {
    @Environment(\.widgetFamily) var family
    var entry: MonthlyTotalProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 4 : 8) {
            WidgetHeader(title: "widget_monthly_total_title".widgetLocalized(), icon: "chart.bar.fill")
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(CurrencyFormatter.formatAmount(entry.totalMonthly, currencyCode: entry.currency))
                    .font(.system(size: family == .systemSmall ? 20 : 28, weight: .bold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                
                Text("total_monthly".widgetLocalized())
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct MonthlyTotalWidget: Widget {
    let kind: String = "MonthlyTotalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MonthlyTotalProvider()) { entry in
            MonthlyTotalWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("widget_monthly_total_title".widgetLocalized())
        .description("widget_monthly_total_desc".widgetLocalized())
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
