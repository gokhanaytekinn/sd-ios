import Foundation
import Combine

/// İşlem geçmişini yöneten ViewModel.
/// Global standartlarımıza uygun olarak Use Case katmanını kullanır ve @MainActor ile izole edilmiştir.
@MainActor
class TransactionsViewModel: ObservableObject {
    @Published var transactions: [TransactionResponse] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let getTransactionsUseCase: GetTransactionsUseCaseProtocol
    
    init(getTransactionsUseCase: GetTransactionsUseCaseProtocol? = nil) {
        self.getTransactionsUseCase = getTransactionsUseCase ?? GetTransactionsUseCase()
    }
    
    /// Belirli bir sayfadaki işlemleri yükler.
    func loadTransactions(page: Int = 0, size: Int = 20) {
        Task {
            isLoading = true
            error = nil
            
            let result = await getTransactionsUseCase.execute(page: page, size: size)
            
            switch result {
            case .success(let pageResponse):
                self.transactions = pageResponse.content
            case .failure(let err):
                self.error = err.localizedDescription
            }
            
            isLoading = false
        }
    }
}
