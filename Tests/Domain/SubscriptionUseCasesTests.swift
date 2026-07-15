import XCTest
@testable import SDIOS

final class SubscriptionUseCasesTests: XCTestCase {
    var mockRepository: MockSubscriptionRepository!
    var getSubscriptionsUseCase: GetSubscriptionsUseCase!
    var createSubscriptionUseCase: CreateSubscriptionUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockSubscriptionRepository()
        getSubscriptionsUseCase = GetSubscriptionsUseCase(repository: mockRepository)
        createSubscriptionUseCase = CreateSubscriptionUseCase(repository: mockRepository)
    }
    
    func testGetSubscriptionsSuccess() async {
        // Given
        let expectedSubs = [
            Subscription(id: "1", name: "Netflix", cost: 15.99, currency: 1, billingCycle: .monthly),
            Subscription(id: "2", name: "Spotify", cost: 9.99, currency: 1, billingCycle: .monthly)
        ]
        mockRepository.subscriptionsResult = .success(expectedSubs)
        
        // When
        let result = await getSubscriptionsUseCase.execute()
        
        // Then
        switch result {
        case .success(let subs):
            XCTAssertEqual(subs.count, 2)
            XCTAssertEqual(subs[0].name, "Netflix")
        case .failure:
            XCTFail("Should succeed")
        }
    }
    
    func testCreateSubscriptionSuccess() async {
        // Given
        let request = SubscriptionRequest(name: "New Sub", amount: 10.0, currency: 1, billingCycle: 1)
        let expectedSub = Subscription(id: "3", name: "New Sub", cost: 10.0, currency: 1, billingCycle: .monthly)
        mockRepository.createResult = .success(expectedSub)
        
        // When
        let result = await createSubscriptionUseCase.execute(request: request)
        
        // Then
        switch result {
        case .success(let sub):
            XCTAssertEqual(sub.name, "New Sub")
        case .failure:
            XCTFail("Should succeed")
        }
    }
}
