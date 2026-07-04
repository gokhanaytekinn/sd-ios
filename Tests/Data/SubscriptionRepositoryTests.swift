import XCTest
@testable import SDIOS

final class SubscriptionRepositoryTests: XCTestCase {
    var mockApi: MockApiService!
    var repository: SubscriptionRepository!
    
    override func setUp() {
        super.setUp()
        mockApi = MockApiService()
        repository = SubscriptionRepository(api: mockApi)
    }
    
    func testGetSubscriptionsSuccess() async {
        // Given
        let apiResponses = [
            SubscriptionResponse(id: "1", name: "Apple", amount: 9.99, currency: 1, billingCycle: 1, status: 1),
            SubscriptionResponse(id: "2", name: "Google", amount: 1.99, currency: 1, billingCycle: 1, status: 1)
        ]
        mockApi.subscriptionsResponse = apiResponses
        
        // When
        let result = await repository.getSubscriptions()
        
        // Then
        switch result {
        case .success(let subscriptions):
            XCTAssertEqual(subscriptions.count, 2)
            XCTAssertEqual(subscriptions[0].name, "Apple")
        case .failure:
            XCTFail("Repository should return success")
        }
    }
    
    func testGetSubscriptionsError() async {
        // Given
        mockApi.error = NSError(domain: "NetworkError", code: 500)
        
        // When
        let result = await repository.getSubscriptions()
        
        // Then
        switch result {
        case .success:
            XCTFail("Repository should return failure")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 500)
        }
    }
}
