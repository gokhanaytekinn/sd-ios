import Foundation

/// Uygulama içi satın alma ve fatura doğrulama işlemlerini yöneten repository protokolü.
protocol PurchaseRepositoryProtocol {
    func verifyPurchase(_ request: PurchaseRequest) async -> Result<UserResponse, Error>
}
