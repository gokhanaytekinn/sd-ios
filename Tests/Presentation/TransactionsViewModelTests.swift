import XCTest
@testable import SDIOS

final class TransactionsViewModelTests: XCTestCase {
    var viewModel: TransactionsViewModel!
    var mockGetTrans: MockGetTransactionsUseCase!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockGetTrans = MockGetTransactionsUseCase()
        viewModel = TransactionsViewModel(getTransactionsUseCase: mockGetTrans)
    }
    
    @MainActor
    func testLoadTransactionsSuccess() async {
        // Given
        let trans = [TransactionResponse(id: "t1", subscriptionId: "s1", userId: "u1", amount: 10.0, currency: 1, type: 1, status: 1, description: "Test", metadata: nil, createdAt: "2024-03-20", updatedAt: nil)]
        let pageResponse = PageTransactionResponse(content: trans, totalElements: 1, totalPages: 1, size: 20, number: 0)
        mockGetTrans.result = .success(pageResponse)
        
        // When
        viewModel.loadTransactions()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
}
