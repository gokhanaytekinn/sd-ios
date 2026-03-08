import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
}
