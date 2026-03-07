import Foundation

struct DateUtils {
    static func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: LanguagePreferences.shared.selectedLanguage)
            displayFormatter.dateFormat = "dd MMM yyyy"
            return displayFormatter.string(from: date)
        }
        
        // Try another common format
        let altFormatter = DateFormatter()
        altFormatter.dateFormat = "yyyy-MM-dd"
        if let date = altFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: LanguagePreferences.shared.selectedLanguage)
            displayFormatter.dateFormat = "dd MMM yyyy"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
    
    static func calculateDaysRemaining(_ dateString: String) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var targetDate: Date?
        targetDate = formatter.date(from: dateString)
        
        if targetDate == nil {
            let altFormatter = DateFormatter()
            altFormatter.dateFormat = "yyyy-MM-dd"
            targetDate = altFormatter.date(from: dateString)
        }
        
        guard let target = targetDate else { return -1 }
        
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: target))
        return components.day ?? -1
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LanguagePreferences.shared.selectedLanguage)
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    static func toISOString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}
