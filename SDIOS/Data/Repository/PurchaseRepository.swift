import Foundation

/// Uygulama içi satın alma (IAP) ve fatura doğrulama işlemlerinden sorumlu Repository.
class PurchaseRepository: PurchaseRepositoryProtocol {
    /// Singleton örneği - Protokol tipinde.
    static let shared: PurchaseRepositoryProtocol = PurchaseRepository()
    
    /// API servis bağımlılığı.
    private let api: ApiServiceProtocol
    
    /// Bağımlılık Enjeksiyonu destekli başlatıcı.
    init(api: ApiServiceProtocol = ApiService.shared) {
        self.api = api
    }
    
    /// Apple tarafında gerçekleşen satın almayı sunucu tarafında doğrular.
    func verifyPurchase(_ request: PurchaseRequest) async -> Result<UserResponse, Error> {
        do {
            let response = try await api.verifyPurchase(request)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
