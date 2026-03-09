import XCTest
@testable import SDIOS

final class SubscriptionsViewModelTests: XCTestCase {
    var viewModel: SubscriptionsViewModel!
    var mockGetSubs: MockGetSubscriptionsUseCase!
    var mockGetInv: MockGetPendingInvitationsUseCase!
    var mockAcceptInv: MockAcceptInvitationUseCase!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockGetSubs = MockGetSubscriptionsUseCase()
        mockGetInv = MockGetPendingInvitationsUseCase()
        mockAcceptInv = MockAcceptInvitationUseCase()
        
        viewModel = SubscriptionsViewModel(
            getSubscriptionsUseCase: mockGetSubs,
            getInvitationsUseCase: mockGetInv,
            acceptInvitationUseCase: mockAcceptInv
        )
    }
    
    @MainActor
    func testLoadSubscriptionsSuccess() async {
        // Given
        let subs = [Subscription(id: "1", name: "S1", cost: 5.0, currency: 1, billingCycle: .monthly, status: 1)]
        let invs = [SubscriptionInvitation(id: "i1", subscriptionName: "D1", ownerEmail: "o@o.com", amount: 10.0, currency: 1, billingCycle: 1, createdAt: "", status: "PENDING")]
        
        mockGetSubs.result = .success(subs)
        mockGetInv.result = .success(invs)
        
        // When
        viewModel.loadSubscriptions()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.allSubscriptions.count, 1)
        XCTAssertEqual(viewModel.invitations.count, 1)
        XCTAssertEqual(viewModel.activeSubscriptions.count, 1)
    }
    
    @MainActor
    func testAcceptInvitationLimitReached() {
        // Given
        let authVM = AuthViewModel(repository: MockAuthRepository())
        authVM.tier = 1
        authVM.subscriptionCount = 5
        viewModel.authViewModel = authVM
        
        // When
        viewModel.acceptInvitation(id: "i1")
        
        // Then
        XCTAssertTrue(viewModel.showingLimitAlert)
    }
}
