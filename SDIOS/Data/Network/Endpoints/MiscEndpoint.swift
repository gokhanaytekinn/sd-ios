import Foundation

/// İşlemler, Davetiyeler ve Analizler gibi diğer uç noktaları kapsayan Enum.
enum MiscEndpoint: APIEndpoint {
    case getTransactions(page: Int, size: Int)
    case getReminders
    case getConvertedAmount(ConversionRequest)
    case getPendingInvitations
    case acceptInvitation(id: String)
    case rejectInvitation(id: String)
    case removeParticipant(subscriptionId: String, email: String)
    case verifyPurchase(PurchaseRequest)
    case getNotifications(isRead: Bool?)
    case getUnreadNotificationCount
    case markNotificationRead(id: String)
    case markAllNotificationsRead
    case deleteNotification(id: String)
    case submitSupportTicket(SupportTicketRequest)
    
    var path: String {
        switch self {
        case .getTransactions: return "/api/transactions"
        case .getReminders: return "/api/reminders"
        case .getConvertedAmount: return "/api/convert"
        case .getPendingInvitations: return "/api/invitations/pending"
        case .acceptInvitation(let id): return "/api/invitations/\(id)/accept"
        case .rejectInvitation(let id): return "/api/invitations/\(id)/reject"
        case .removeParticipant(let subId, let email): return "/api/subscriptions/\(subId)/participants/\(email)"
        case .verifyPurchase: return "/api/purchases/verify"
        case .getNotifications: return "/api/notifications"
        case .getUnreadNotificationCount: return "/api/notifications/unread-count"
        case .markNotificationRead(let id): return "/api/notifications/\(id)/read"
        case .markAllNotificationsRead: return "/api/notifications/read-all"
        case .deleteNotification(let id): return "/api/notifications/\(id)"
        case .submitSupportTicket: return "/api/support/tickets"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getTransactions, .getReminders, .getPendingInvitations, .getNotifications, .getUnreadNotificationCount:
            return .get
        case .getConvertedAmount, .acceptInvitation, .rejectInvitation, .verifyPurchase:
            return .post
        case .removeParticipant, .deleteNotification:
            return .delete
        case .markNotificationRead, .markAllNotificationsRead:
            return .patch
        case .submitSupportTicket:
            return .post
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .getConvertedAmount(let req): return try? encoder.encode(req)
        case .verifyPurchase(let req): return try? encoder.encode(req)
        case .submitSupportTicket(let req): return try? encoder.encode(req)
        default: return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getTransactions(let page, let size):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)")
            ]
        case .getNotifications(let isRead):
            guard let isRead else { return nil }
            return [URLQueryItem(name: "isRead", value: isRead ? "true" : "false")]
        default: return nil
        }
    }
    
    var requiresAuth: Bool {
        return true
    }
}
