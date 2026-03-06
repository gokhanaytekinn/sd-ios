import Foundation
import Combine

class LanguagePreferences: ObservableObject {
    static let shared = LanguagePreferences()
    
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        }
    }
    
    struct Language: Identifiable {
        let id: String
        let code: String
        let name: String
        let flag: String
    }
    
    static let supportedLanguages: [Language] = [
        Language(id: "tr", code: "tr", name: "Türkçe", flag: "🇹🇷"),
        Language(id: "en", code: "en", name: "English", flag: "🇬🇧"),
        Language(id: "es", code: "es", name: "Español", flag: "🇪🇸"),
        Language(id: "ru", code: "ru", name: "Русский", flag: "🇷🇺"),
        Language(id: "zh", code: "zh", name: "简体中文", flag: "🇨🇳"),
        Language(id: "fr", code: "fr", name: "Français", flag: "🇫🇷"),
        Language(id: "de", code: "de", name: "Deutsch", flag: "🇩🇪"),
        Language(id: "id", code: "id", name: "Bahasa Indonesia", flag: "🇮🇩"),
        Language(id: "az", code: "az", name: "Azərbaycanca", flag: "🇦🇿"),
        Language(id: "tk", code: "tk", name: "Türkmençe", flag: "🇹🇲"),
        Language(id: "kk", code: "kk", name: "Қазақша", flag: "🇰🇿"),
        Language(id: "ky", code: "ky", name: "Кыргызча", flag: "🇰🇬"),
        Language(id: "uz", code: "uz", name: "Oʻzbekcha", flag: "🇺🇿"),
    ]
    
    private init() {
        self.selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "tr"
    }
}
