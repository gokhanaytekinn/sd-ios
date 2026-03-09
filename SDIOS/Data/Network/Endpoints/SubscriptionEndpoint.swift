import Foundation

/// Abonelik işlemleri için API uç noktalarını tanımlayan Enum.
enum SubscriptionEndpoint: APIEndpoint {
    case getSubscriptions
    case getSubscription(id: String)
    case createSubscription(SubscriptionRequest)
    case updateSubscription(id: String, SubscriptionUpdateRequest)
    case deleteSubscription(id: String)
    case getSuspicious
    case approve(id: String)
    case flagSuspicious(id: String, FlagSuspiciousRequest)
    case cancel(id: String)
    case reactivate(id: String)
    case getUpcoming
    
    var path: String {
        switch self {
        case .getSubscriptions, .createSubscription:
            return "/api/subscriptions"
        case .getSubscription(let id), .updateSubscription(let id, _), .deleteSubscription(let id):
            return "/api/subscriptions/\(id)"
        case .getSuspicious:
            return "/api/subscriptions/suspicious"
        case .approve(let id):
            return "/api/subscriptions/\(id)/approve"
        case .flagSuspicious(let id, _):
            return "/api/subscriptions/\(id)/flag"
        case .cancel(let id):
            return "/api/subscriptions/\(id)/cancel"
        case .reactivate(let id):
            return "/api/subscriptions/\(id)/reactivate"
        case .getUpcoming:
            return "/api/subscriptions/upcoming"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getSubscriptions, .getSubscription, .getSuspicious, .getUpcoming:
            return .get
        case .createSubscription:
            return .post
        case .updateSubscription:
            return .put
        case .deleteSubscription:
            return .delete
        case .approve, .flagSuspicious, .cancel, .reactivate:
            return .patch
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .createSubscription(let req): return try? encoder.encode(req)
        case .updateSubscription(_, let req): return try? encoder.encode(req)
        case .flagSuspicious(_, let req): return try? encoder.encode(req)
        default: return nil
        }
    }
    
    var requiresAuth: Bool {
        return true
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}
