import XCTest
import Combine
@testable import SDIOS

final class AuthViewModelTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockRepo: MockAuthRepository!
    var mockLogin: MockLoginUseCase!
    var mockRegister: MockRegisterUseCase!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        mockLogin = MockLoginUseCase()
        mockRegister = MockRegisterUseCase()
        
        viewModel = AuthViewModel(
            repository: mockRepo,
            loginUseCase: mockLogin,
            registerUseCase: mockRegister
        )
    }
    
    @MainActor
    func testLoginSuccess() {
        // Given
        let expectedResponse = ApiAuthResponse(
            token: "token",
            user: UserResponse(id: "1", email: "test@test.com", name: "User", tier: 1, notificationsEnabled: true, language: "tr", createdAt: nil),
            message: nil,
            success: true
        )
        mockLogin.result = .success(expectedResponse)
        
        let expectation = XCTestExpectation(description: "Login success")
        
        // When
        viewModel.login(email: "test@test.com", password: "password") {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.userEmail, "test@test.com")
        XCTAssertNil(viewModel.error)
    }
    
    @MainActor
    func testSubscriptionLimit() {
        // Tier 1 (Free) and 5+ subs -> Limit reached
        viewModel.tier = 1
        viewModel.subscriptionCount = 5
        XCTAssertTrue(viewModel.isSubscriptionLimitReached)
        
        // Tier 2 (Premium) -> No limit
        viewModel.tier = 2
        viewModel.subscriptionCount = 10
        XCTAssertFalse(viewModel.isSubscriptionLimitReached)
        
        // Tier 1 and < 5 subs -> No limit
        viewModel.tier = 1
        viewModel.subscriptionCount = 4
        XCTAssertFalse(viewModel.isSubscriptionLimitReached)
    }
    
    @MainActor
    func testLogout() {
        // Given
        viewModel.isAuthenticated = true
        
        // When
        viewModel.logout()
        
        // Then
        XCTAssertTrue(mockRepo.logoutCalled)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.tier, 1)
    }
}
