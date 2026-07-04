import XCTest
@testable import SDIOS

final class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var mockGetSubs: MockGetSubscriptionsUseCase!
    var mockGetUpcoming: MockGetUpcomingSubscriptionsUseCase!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockGetSubs = MockGetSubscriptionsUseCase()
        mockGetUpcoming = MockGetUpcomingSubscriptionsUseCase()
        viewModel = DashboardViewModel(
            getSubscriptionsUseCase: mockGetSubs,
            getUpcomingUseCase: mockGetUpcoming
        )
    }
    
    @MainActor
    func testLoadDashboardSuccess() async {
        // Given
        let subs = [Subscription(id: "1", name: "Test", cost: 10.0, currency: 1, billingCycle: .monthly)]
        mockGetSubs.result = .success(subs)
        mockGetUpcoming.result = .success(subs)
        
        // When
        viewModel.loadDashboard()
        
        // Wait for @Published changes (Task based async)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.subscriptions.count, 1)
        XCTAssertNil(viewModel.error)
    }
    
    @MainActor
    func testLoadDashboardFailure() async {
        // Given
        mockGetSubs.result = .failure(NSError(domain: "Error", code: 500))
        
        // When
        viewModel.loadDashboard()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
    }
}
