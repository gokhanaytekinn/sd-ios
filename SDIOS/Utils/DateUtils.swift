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
    
    static func formatTurkishDay(_ day: Int) -> String {
        let suffix: String
        let lastDigit = day % 10
        
        switch day {
        case 10, 30: suffix = "u"
        case 20: suffix = "si"
        default:
            switch lastDigit {
            case 1, 5, 8: suffix = "i"
            case 2, 7: suffix = "si"
            case 3, 4: suffix = "ü"
            case 6: suffix = "sı"
            case 9: suffix = "u"
            case 0: suffix = "ı" // Default for 0 if it ever happens
            default: suffix = "i"
            }
        }
        return "\(day)'\(suffix)"
    }
    
    static func formatTurkishMonthlyRenewal(day: Int) -> String {
        let formattedDay = formatTurkishDay(day)
        return String(format: "monthly_renewal_format".localized(), formattedDay)
    }
    
    static func formatDayWithSuffix(day: Int, language: String) -> String {
        if language == "tr" || language == "az" {
            return formatTurkishDay(day)
        }
        
        if language == "en" {
            let j = day % 10
            let k = day % 100
            if j == 1 && k != 11 {
                return "\(day)st"
            }
            if j == 2 && k != 12 {
                return "\(day)nd"
            }
            if j == 3 && k != 13 {
                return "\(day)rd"
            }
            return "\(day)th"
        }
        
        // Default to just the number for other languages (most use "day X")
        return "\(day)"
    }
    
    static func formatMonthlyRenewal(day: Int, language: String) -> String {
        let formattedDay = formatDayWithSuffix(day: day, language: language)
        let format = "monthly_renewal_format".localized()
        return String(format: format, formattedDay)
    }
    
    /// Backend'in gönderdiği zaman damgası (offset'siz `LocalDateTime`, örn. "2024-01-15T10:30:00")
    /// dahil çeşitli ISO-8601 varyantlarını ayrıştırmayı dener.
    private static func parseFlexibleISODate(_ dateString: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        for pattern in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss"] {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = pattern
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }

    /// Bildirim listesinde kullanılan "3 dakika önce" tarzı bağıl zaman metni.
    static func formatRelative(isoString: String) -> String {
        guard let date = parseFlexibleISODate(isoString) else { return isoString }

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: LanguagePreferences.shared.selectedLanguage)
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    static func formatYearlyRenewal(day: Int, month: Int, language: String) -> String {
        let monthName = "month_\(month)".localized()
        let format = "yearly_renewal_format".localized()
        
        let formattedDay: String
        if language == "tr" || language == "az" {
            formattedDay = "\(day)"
        } else {
            formattedDay = formatDayWithSuffix(day: day, language: language)
        }
        
        return String(format: format, formattedDay, monthName)
    }
}
