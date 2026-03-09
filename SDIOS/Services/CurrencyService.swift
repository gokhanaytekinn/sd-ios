import Foundation

class CurrencyService {
    static let shared = CurrencyService()
    
    private init() {}
    
    // Static exchange rates relative to TRY (ID: 1)
    // In a real app, these would be fetched from an API
    private let ratesToTRY: [Int: Double] = [
        1: 1.0,      // TRY
        2: 32.50,    // USD -> TRY
        3: 35.20,    // EUR -> TRY
        4: 41.10,    // GBP -> TRY
        5: 0.35,     // RUB -> TRY
        6: 19.12,    // AZN -> TRY
        7: 0.072     // KZT -> TRY
    ]
    
    func convert(amount: Double, from fromCurrency: Int, to toCurrency: Int) -> Double {
        if fromCurrency == toCurrency { return amount }
        
        guard let rateFrom = ratesToTRY[fromCurrency],
              let rateTo = ratesToTRY[toCurrency] else {
            return amount
        }
        
        // Convert to TRY first, then to target currency
        let amountInTRY = amount * rateFrom
        let finalAmount = amountInTRY / rateTo
        
        return finalAmount
    }
}
