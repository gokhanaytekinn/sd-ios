import Foundation
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupID = "group.com.subtracker.SDiOS"
    private let snapshotKey = "widget_subscription_snapshot"
    
    private init() {}
    
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    /// Saves a snapshot of subscriptions to shared storage for widgets.
    func saveSnapshot(_ subscriptions: [Subscription]) {
        do {
            let data = try JSONEncoder().encode(subscriptions)
            sharedDefaults?.set(data, forKey: snapshotKey)
            sharedDefaults?.synchronize()
            
            // Trigger widget refresh
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to encode subscriptions for widget: \(error)")
        }
    }
    
    /// Loads the subscription snapshot from shared storage.
    func loadSnapshot() -> [Subscription] {
        guard let data = sharedDefaults?.data(forKey: snapshotKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Subscription].self, from: data)
        } catch {
            print("Failed to decode subscriptions for widget: \(error)")
            return []
        }
    }
}
