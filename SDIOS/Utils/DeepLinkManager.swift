import SwiftUI
import Combine

class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var pendingRoute: String?
    
    private init() {}
    
    func handle(url: URL) {
        if url.scheme == "sdios" {
            if url.host == "add_subscription" {
                pendingRoute = "add_subscription"
            }
        }
    }
    
    func consume() -> String? {
        let route = pendingRoute
        pendingRoute = nil
        return route
    }
}
