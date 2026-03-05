import Foundation

class CurrencyPreferences {
    static let shared = CurrencyPreferences()
    
    @Published var selectedCurrency: Int {
        didSet {
            UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency")
        }
    }
    
    struct CurrencyOption: Identifiable {
        let id: Int
        let code: String
        let name: String
        let symbol: String
    }
    
    static let currencies: [CurrencyOption] = [
        CurrencyOption(id: 1, code: "TRY", name: "Türk Lirası", symbol: "₺"),
        CurrencyOption(id: 2, code: "USD", name: "US Dollar", symbol: "$"),
        CurrencyOption(id: 3, code: "EUR", name: "Euro", symbol: "€"),
        CurrencyOption(id: 4, code: "GBP", name: "British Pound", symbol: "£"),
        CurrencyOption(id: 5, code: "RUB", name: "Russian Ruble", symbol: "₽"),
        CurrencyOption(id: 6, code: "AZN", name: "Azerbaijani Manat", symbol: "₼"),
        CurrencyOption(id: 7, code: "KZT", name: "Kazakhstani Tenge", symbol: "₸"),
    ]
    
    private init() {
        self.selectedCurrency = UserDefaults.standard.integer(forKey: "selectedCurrency")
        if self.selectedCurrency == 0 { self.selectedCurrency = 1 }
    }
}
