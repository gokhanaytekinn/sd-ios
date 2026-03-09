import UIKit
import UserNotifications
import AppTrackingTransparency
import AdSupport

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permission
        requestNotificationPermission()
        
        // Request IDFA tracking permission and then setup AdMob
        requestTrackingPermission()
        
        return true
    }
    
    func requestTrackingPermission() {
        // Delay slightly to ensure the app is in the foreground
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    Task { @MainActor in
                        print("ATTrackingManager Status: \(status.rawValue)")
                        // Setup AdMob regardless of status, but it helps with fill rate if accepted
                        AdMobManager.shared.setup()
                    }
                }
            } else {
                Task { @MainActor in
                    AdMobManager.shared.setup()
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                Task { @MainActor in
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        // Save token to UserDefaults or send directly if AuthViewModel.shared exists
        // Since we are using SwiftUI environment objects, we can post a notification
        // or use a shared state.
        NotificationCenter.default.post(name: Notification.Name("DidRegisterRemoteNotification"), object: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let navigateTo = userInfo["navigate_to"] as? String {
            NotificationCenter.default.post(name: NSNotification.Name("DidRequestNavigation"), object: navigateTo)
        }
        
        completionHandler()
    }
}
