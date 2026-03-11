import Foundation
import Combine
import WidgetKit

class LanguagePreferences: ObservableObject {
    static let shared = LanguagePreferences()
    
    private let appGroupID = "group.com.subtracker.SDiOS"
    
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
            sharedDefaults?.set(selectedLanguage, forKey: "selectedLanguage")
            sharedDefaults?.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    struct Language: Identifiable {
        let id: String
        let code: String
        let name: String
        let flag: String
    }
    
    static let supportedLanguages: [Language] = [
        // 1. Türkçe
        Language(id: "tr", code: "tr", name: "Türkçe", flag: "🇹🇷"),
        
        // 2. Diğer Türk Dilleri
        Language(id: "az", code: "az", name: "Azərbaycanca", flag: "🇦🇿"),
        Language(id: "tk", code: "tk", name: "Türkmençe", flag: "🇹🇲"),
        Language(id: "kk", code: "kk", name: "Қазақша", flag: "🇰🇿"),
        Language(id: "ky", code: "ky", name: "Кыргызча", flag: "🇰🇬"),
        Language(id: "uz", code: "uz", name: "Oʻzbekcha", flag: "🇺🇿"),
        Language(id: "ug", code: "ug", name: "ئۇيغۇرچە", flag: "🌐"), // Uygurca
        Language(id: "tt", code: "tt", name: "Татарча", flag: "🌐"), // Tatarca
        Language(id: "ba", code: "ba", name: "Башҡортса", flag: "🌐"), // Başkurtça
        Language(id: "cv", code: "cv", name: "Чӑвашла", flag: "🌐"), // Çuvaşça
        Language(id: "gag", code: "gag", name: "Gagauzça", flag: "🌐"), // Gagauzca
        Language(id: "sah", code: "sah", name: "Саха тыла", flag: "🌐"), // Yakutça
        
        // 3. Diğer Diller (En sık kullanılandan en aza)
        Language(id: "en", code: "en", name: "English", flag: "🇬🇧"),
        Language(id: "zh", code: "zh", name: "简体中文", flag: "🇨🇳"),
        Language(id: "es", code: "es", name: "Español", flag: "🇪🇸"),
        Language(id: "fr", code: "fr", name: "Français", flag: "🇫🇷"),
        Language(id: "ru", code: "ru", name: "Русский", flag: "🇷🇺"),
        Language(id: "de", code: "de", name: "Deutsch", flag: "🇩🇪"),
        Language(id: "id", code: "id", name: "Bahasa Indonesia", flag: "🇮🇩"),
    ]
    
    private init() {
        // More robust device language detection
        let deviceLang = Locale.preferredLanguages.first ?? "en"
        
        if deviceLang.hasPrefix("ar") {
            // ARABIC OVERRIDE: Always force Turkish, no matter what was saved
            self.selectedLanguage = "tr"
        } else if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            // Normal flow: Use saved preference if not in Arabic mode
            self.selectedLanguage = savedLanguage
        } else {
            // First time launch for non-Arabic devices
            let langCode = Locale.current.language.languageCode?.identifier ?? "en"
            
            if LanguagePreferences.supportedLanguages.contains(where: { $0.code == langCode }) {
                self.selectedLanguage = langCode
            } else {
                self.selectedLanguage = "en"
            }
        }
        
        // Sync to UserDefaults
        UserDefaults.standard.set(self.selectedLanguage, forKey: "selectedLanguage")
        let sharedDefaults = UserDefaults(suiteName: "group.com.subtracker.SDiOS")
        sharedDefaults?.set(self.selectedLanguage, forKey: "selectedLanguage")
        sharedDefaults?.synchronize()
    }
}
