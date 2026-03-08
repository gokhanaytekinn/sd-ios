import Foundation

class PurchaseRepository {
    static let shared = PurchaseRepository()
    
    private let api = ApiService.shared
    
    private init() {}
    
    func verifyPurchase(productId: String, transactionId: String) async -> Result<UserResponse, Error> {
        do {
            let request = PurchaseRequest(purchaseToken: transactionId, productId: productId)
            let user = try await api.verifyPurchase(request)
            return .success(user)
        } catch {
            return .failure(error)
        }
    }
}
