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
    }
    
    static let supportedLanguages: [Language] = [
        // 1. Türkçe
        Language(id: "tr", code: "tr", name: "Türkçe"),
        
        // 2. Diğer Türk Dilleri
        Language(id: "az", code: "az", name: "Azərbaycanca"),
        Language(id: "tk", code: "tk", name: "Türkmençe"),
        Language(id: "kk", code: "kk", name: "Қазақша"),
        Language(id: "ky", code: "ky", name: "Кыргызча"),
        Language(id: "uz", code: "uz", name: "Oʻzbekcha"),
        Language(id: "ug", code: "ug", name: "ئۇيغۇرچە"), // Uygurca
        Language(id: "tt", code: "tt", name: "Татарча"), // Tatarca
        Language(id: "ba", code: "ba", name: "Башҡортса"), // Başkurtça
        Language(id: "cv", code: "cv", name: "Чӑвашла"), // Çuvaşça
        Language(id: "gag", code: "gag", name: "Gagauzça"), // Gagauzca
        Language(id: "sah", code: "sah", name: "Саха тыла"), // Yakutça
        
        // 3. Diğer Diller (En sık kullanılandan en aza)
        Language(id: "en", code: "en", name: "English"),
        Language(id: "zh", code: "zh", name: "简体中文"),
        Language(id: "es", code: "es", name: "Español"),
        Language(id: "fr", code: "fr", name: "Français"),
        Language(id: "ru", code: "ru", name: "Русский"),
        Language(id: "de", code: "de", name: "Deutsch"),
        Language(id: "id", code: "id", name: "Bahasa Indonesia"),
        
        // 4. Newly added
        Language(id: "it", code: "it", name: "Italiano"),
        Language(id: "nl", code: "nl", name: "Nederlands"),
        Language(id: "sv", code: "sv", name: "Svenska"),
        Language(id: "pl", code: "pl", name: "Polski"),
        Language(id: "cs", code: "cs", name: "Čeština"),
        Language(id: "el", code: "el", name: "Ελληνικά"),
        Language(id: "uk", code: "uk", name: "Українська"),
        Language(id: "ja", code: "ja", name: "日本語"),
        Language(id: "ko", code: "ko", name: "한국어"),
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
