import Foundation

class PremiumPreferences {
    static let shared = PremiumPreferences()
    
    var isPremium: Bool {
        get { UserDefaults.standard.bool(forKey: "isPremium") }
        set { UserDefaults.standard.set(newValue, forKey: "isPremium") }
    }
    
    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSeenOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSeenOnboarding") }
    }
    
    private init() {}
}
