import Foundation

// MARK: - Auth Response
struct ApiAuthResponse: Codable {
    let token: String?
    let user: UserResponse?
    let message: String?
    let success: Bool?
}

// MARK: - User Response
struct UserResponse: Codable {
    let id: String
    let email: String
    let name: String?
    let tier: Int?
    let notificationsEnabled: Bool?
    let language: String?
    let createdAt: String?
}

// MARK: - Subscription Response
struct SubscriptionResponse: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String?
    let category: String?
    let message: String?
    let tier: Int?
    let amount: Double
    let currency: Int
    let billingCycle: Int
    let endDate: String?
    let billingDay: Int?
    let billingMonth: Int?
    let status: Int
    let isSuspicious: Bool?
    let suspiciousReason: String?
    let isApproved: Bool?
    let reminderEnabled: Bool?
    let isFreeTrial: Bool?
    let cardInfo: String?
    let approvedAt: String?
    let approvedBy: String?
    let userId: String?
    let createdAt: String?
    let updatedAt: String?
    let jointEmails: [String]?
    let owner: Bool?
    let participants: [InvitationParticipant]?
    
    func toSubscription() -> Subscription {
        Subscription(
            id: id,
            suspiciousReason: suspiciousReason,
            responseMessage: message,
            name: name,
            cost: amount,
            currency: currency,
            billingCycle: BillingCycle(rawValue: billingCycle) ?? .monthly,
            billingDay: billingDay,
            billingMonth: billingMonth,
            endDate: endDate,
            category: category,
            icon: icon,
            status: status,
            isSuspicious: isSuspicious ?? false,
            tier: tier,
            reminderEnabled: reminderEnabled ?? false,
            cardInfo: cardInfo,
            jointEmails: jointEmails,
            isOwner: owner ?? true,
            isFreeTrial: isFreeTrial,
            participants: participants
        )
    }
}

// MARK: - Transaction Response
struct TransactionResponse: Codable, Identifiable {
    let id: String
    let subscriptionId: String?
    let userId: String?
    let amount: Double
    let currency: Int?
    let type: Int
    let status: Int
    let description: String?
    let metadata: [String: AnyCodable]?
    let createdAt: String
    let updatedAt: String?
}

// MARK: - Page Transaction Response
struct PageTransactionResponse: Codable {
    let content: [TransactionResponse]
    let totalElements: Int
    let totalPages: Int
    let size: Int
    let number: Int
}

// MARK: - Reminder Response
struct ReminderResponse: Codable, Identifiable {
    let id: String
    let userId: String?
    let title: String?
    let type: String
    let message: String
    let scheduledAt: String
    let sentAt: String?
    let isRead: Bool
    let metadata: [String: AnyCodable]?
    let createdAt: String
    let updatedAt: String?
}

// MARK: - In-App Notification Response
struct InAppNotificationResponse: Codable, Identifiable {
    let id: String
    let title: String?
    let body: String?
    let data: [String: String]?
    let isRead: Bool
    let createdAt: String
}

// MARK: - Unread Notification Count Response
struct UnreadNotificationCountResponse: Codable {
    let count: Int
}

// MARK: - Error Response
struct ErrorResponse: Codable {
    let status: Int?
    let errorCode: String?
    let message: String
    let userMessage: String?
    let path: String?
    let timestamp: String?
}

// MARK: - AnyCodable helper
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intVal = value as? Int {
            try container.encode(intVal)
        } else if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        }
    }
}
