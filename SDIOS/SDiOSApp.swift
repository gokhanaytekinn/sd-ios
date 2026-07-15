import SwiftUI

@main
struct SDiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var notificationsViewModel = NotificationsViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(authViewModel)
                .environmentObject(notificationsViewModel)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DidRegisterRemoteNotification"))) { notification in
                    if let token = notification.object as? String {
                        authViewModel.updatePushToken(token: token)
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        notificationsViewModel.refreshUnreadCount()
                    }
                }
        }
    }
}
