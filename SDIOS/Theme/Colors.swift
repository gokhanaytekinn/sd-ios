import SwiftUI

extension Color {
    // Primary
    static let primaryBlue = Color(hex: "359EFF")
    static let primaryDark = Color(hex: "1976D2")
    static let accentColor = Color(hex: "4CAF50")
    
    // Background colors
    static let backgroundLight = Color(hex: "F5F7F8")
    static let backgroundDark = Color(hex: "0F1923")
    
    // Surface/Card colors - Dark
    static let surfaceDark = Color(hex: "1E293B")
    static let cardDark = Color(hex: "1E293B")
    
    // Surface/Card colors - Light
    static let cardBackground = Color.white
    static let surfaceLight = Color.white
    
    // Text colors
    static let textPrimary = Color(hex: "0F172A")       // slate-900
    static let textSecondary = Color(hex: "64748B")      // slate-500
    static let textGray = Color(hex: "94A3B8")           // slate-400
    static let grayText = Color(hex: "9CA3AF")
    
    // Semantic colors
    static let errorColor = Color(hex: "EF4444")
    static let successColor = Color(hex: "22C55E")
    static let warningColor = Color(hex: "F97316")
    static let orangeDark = Color(hex: "1E1510")
    
    // Brand colors
    static let netflixRed = Color(hex: "E50914")
    static let spotifyGreen = Color(hex: "1DB954")
    static let adobeRed = Color(hex: "FF0000")
    static let amazonOrange = Color(hex: "FF9900")
    
    // Slate colors used in theme
    static let slate100 = Color(hex: "F1F5F9")
    static let slate200 = Color(hex: "E2E8F0")
    static let slate300 = Color(hex: "CBD5E1")
    static let slate600 = Color(hex: "475569")
    static let slate700 = Color(hex: "334155")
    
    // Additional
    static let darkGrayBg = Color(hex: "374151")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme-aware colors
extension Color {
    static func appBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .backgroundDark : .backgroundLight
    }
    
    static func appSurface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .surfaceDark : .surfaceLight
    }
    
    static func appOnBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white : .textPrimary
    }
    
    static func appOnSurface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white : .textPrimary
    }
    
    static func appOnSurfaceVariant(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .textGray : .textSecondary
    }
    
    static func appOutline(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .slate700 : .slate200
    }
    
    static func appSurfaceVariant(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "273549") : .slate100
    }
    
    static func dynamicColor(from name: String) -> Color {
        let colors: [Color] = [
            .primaryBlue, .errorColor, .successColor, .warningColor,
            Color(hex: "8B5CF6"), // Purple
            Color(hex: "EC4899"), // Pink
            Color(hex: "06B6D4"), // Cyan
            Color(hex: "F59E0B"), // Amber
            Color(hex: "10B981"), // Emerald
            Color(hex: "6366F1")  // Indigo
        ]
        
        let hash = name.lowercased().hashValue
        let index = abs(hash) % colors.count
        return colors[index]
    }
}
