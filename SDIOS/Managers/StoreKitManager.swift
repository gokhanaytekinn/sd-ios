import Foundation
import StoreKit
import Combine

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    // Product IDs must match your App Store Connect configuration
    private let monthlyProductID = "com.nexus.sd.premium.monthly"
    private let yearlyProductID = "com.nexus.sd.premium.yearly"
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    var transactionListener: Task<Void, Error>?
    
    init() {
        // Start listening for transactions as soon as the manager is initialized
        transactionListener = listenForTransactions()
        
        Task {
            print("StoreKitManager: Initializing and fetching products...")
            await fetchProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    func fetchProducts() async {
        do {
            print("StoreKitManager: Fetching products for IDs: \([monthlyProductID, yearlyProductID])")
            let storeProducts = try await Product.products(for: [monthlyProductID, yearlyProductID])
            print("StoreKitManager: Found \(storeProducts.count) products in App Store")
            
            for product in storeProducts {
                print("StoreKitManager: Product - \(product.id), \(product.displayName), \(product.displayPrice)")
            }
            
            self.products = storeProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("StoreKitManager: Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()
        
        // Iterate through all current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Only consider active subscriptions
                if transaction.revocationDate == nil {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    guard let self = self else { return }
                    // Now checkVerified is nonisolated so we can call it from a background task
                    let transaction = try self.checkVerified(result)
                    
                    // addPurchasedProductID is @MainActor, so we await it
                    await self.addPurchasedProductID(transaction.productID)
                    
                    await transaction.finish()
                } catch {
                    print("Transaction update failed: \(error)")
                }
            }
        }
    }
    
    @MainActor
    private func addPurchasedProductID(_ id: String) {
        purchasedProductIDs.insert(id)
    }
    
    nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
