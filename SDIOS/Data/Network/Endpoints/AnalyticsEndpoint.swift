import Foundation

enum AnalyticsEndpoint: APIEndpoint {
    case getSummary
    
    var path: String {
        switch self {
        case .getSummary: return "/api/user-analytics/summary"
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
