import WidgetKit
import SwiftUI

struct QuickAddProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickAddEntry {
        QuickAddEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickAddEntry) -> ()) {
        let entry = QuickAddEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = QuickAddEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct QuickAddEntry: TimelineEntry {
    let date: Date
}

struct QuickAddWidgetView : View {
    var entry: QuickAddProvider.Entry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Link(destination: URL(string: "sdios://add_subscription")!) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(LocalizedStringKey("quick_add_title"), tableName: "WidgetLocalizable", bundle: .main)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct QuickAddWidget: Widget {
    let kind: String = "QuickAddWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddProvider()) { entry in
            QuickAddWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("quick_add_title".widgetLocalized())
        .description("widget_quick_add_desc".widgetLocalized())
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    QuickAddWidget()
} timeline: {
    QuickAddEntry(date: Date())
}
