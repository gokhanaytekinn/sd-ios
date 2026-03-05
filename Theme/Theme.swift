import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
}
