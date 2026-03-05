import Foundation

struct CurrencyFormatter {
    static func formatAmount(_ amount: Double, currencyCode: Int) -> String {
        let symbol = getCurrencySymbol(currencyCode)
        let formatted = formatAmountLocalized(amount)
        return "\(formatted) \(symbol)"
    }
    
    static func formatAmountLocalized(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "0,00"
    }
    
    static func getCurrencySymbol(_ currencyCode: Int) -> String {
        switch currencyCode {
        case 1: return "₺"
        case 2: return "$"
        case 3: return "€"
        case 4: return "£"
        case 5: return "₽"
        case 6: return "₼"
        case 7: return "₸"
        default: return "₺"
        }
    }
    
    static func formatAmountWithoutSymbol(_ amount: Double) -> String {
        return String(format: "%.2f", amount)
    }
}
