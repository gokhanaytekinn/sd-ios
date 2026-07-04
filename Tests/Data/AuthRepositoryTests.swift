import XCTest
@testable import SDIOS

final class AuthRepositoryTests: XCTestCase {
    var mockApi: MockApiService!
    var mockToken: MockTokenManager!
    var repository: AuthRepository!
    
    override func setUp() {
        super.setUp()
        mockApi = MockApiService()
        mockToken = MockTokenManager()
        repository = AuthRepository(api: mockApi, tokenManager: mockToken)
    }
    
    func testLoginSuccessSavesToken() async {
        // Given
        let expectedResponse = ApiAuthResponse(
            token: "valid_token",
            user: UserResponse(id: "1", email: "test@test.com", name: "User", tier: 1, notificationsEnabled: true, language: "tr", createdAt: nil),
            message: nil, success: true
        )
        mockApi.authResponse = expectedResponse
        
        // When
        let result = await repository.login(email: "test@test.com", password: "password")
        
        // Then
        if case .success = result {
            XCTAssertEqual(mockToken.savedToken, "valid_token")
            XCTAssertEqual(mockToken.savedEmail, "test@test.com")
        } else {
            XCTFail("Should succeed")
        }
    }
    
    func testLogoutClearsToken() {
        // When
        repository.logout()
        
        // Then
        XCTAssertTrue(mockToken.clearTokenCalled)
    }
}
