import Foundation

extension String {
    func localized(tableName: String? = nil) -> String {
        let language = LanguagePreferences.shared.selectedLanguage
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, tableName: tableName, bundle: .main, comment: "")
        }
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, comment: "")
    }
}
