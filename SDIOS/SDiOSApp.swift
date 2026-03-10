import SwiftUI

@main
struct SDiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(authViewModel)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                .onOpenURL { url in
                    DeepLinkManager.shared.handle(url: url)
                    NotificationCenter.default.post(name: NSNotification.Name("DidRequestNavigation"), object: url.host)
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DidRegisterRemoteNotification"))) { notification in
                    if let token = notification.object as? String {
                        authViewModel.updatePushToken(token: token)
                    }
                }
        }
    }
}
