import Foundation

// MARK: - Auth
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String?
    let language: String?
}

struct GoogleAuthRequest: Codable {
    let idToken: String
}

struct AppleAuthRequest: Codable {
    let identityToken: String
    let firstName: String?
    let lastName: String?
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct VerifyCodeRequest: Codable {
    let email: String
    let code: String
}

struct ResetPasswordRequest: Codable {
    let email: String
    let code: String
    let newPassword: String
}

// MARK: - Subscriptions
struct SubscriptionRequest: Codable {
    let name: String
    let icon: String?
    let category: String
    let tier: Int?
    let amount: Double
    let currency: Int
    let billingCycle: Int
    let billingDay: Int?
    let billingMonth: Int?
    let endDate: String?
    let reminderEnabled: Bool
    let isFreeTrial: Bool?
    let jointEmails: [String]?
}

struct SubscriptionUpdateRequest: Codable {
    let name: String?
    let icon: String?
    let category: String?
    let tier: Int?
    let amount: Double?
    let currency: Int?
    let billingCycle: Int?
    let billingDay: Int?
    let billingMonth: Int?
    let endDate: String?
    let reminderEnabled: Bool?
    let isFreeTrial: Bool?
    let jointEmails: [String]?
}

struct FlagSuspiciousRequest: Codable {
    let reason: String
}

// MARK: - Transactions
struct TransactionRequest: Codable {
    let subscriptionId: String?
    let amount: Double
    let currency: Int
    let type: Int
    let description: String?
}

// MARK: - Reminders
struct ReminderRequest: Codable {
    let title: String
    let type: String
    let message: String
    let scheduledAt: String
}

struct ReminderUpdateRequest: Codable {
    let message: String?
    let scheduledAt: String?
    let isRead: Bool?
}

// MARK: - Conversions
struct ConversionRequest: Codable {
    let amount: Double
    let currency: Int
    let billingCycle: Int
}

// MARK: - Users
struct FcmTokenRequest: Codable {
    let token: String
}

struct NotificationSettingsRequest: Codable {
    let enabled: Bool
    let language: String?
}

// MARK: - Support Tickets
struct SupportTicketRequest: Codable {
    let subject: String
    let message: String
}
