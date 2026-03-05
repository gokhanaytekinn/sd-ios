import SwiftUI

@main
struct SDiOSApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(authViewModel)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
