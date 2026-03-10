import Foundation

enum AnalyticsEndpoint: APIEndpoint {
    case getSummary
    case getTrends
    case getInsights
    
    var path: String {
        switch self {
        case .getSummary: return "/api/user-analytics/summary"
        case .getTrends: return "/api/user-analytics/trends"
        case .getInsights: return "/api/user-analytics/insights"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    var requiresAuth: Bool {
        return true
    }
}
