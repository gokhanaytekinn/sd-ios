import XCTest
@testable import SDIOS

final class AuthUseCasesTests: XCTestCase {
    var mockRepository: MockAuthRepository!
    var loginUseCase: LoginUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAuthRepository()
        loginUseCase = LoginUseCase(repository: mockRepository)
    }
    
    func testLoginSuccess() async {
        // Given
        let expectedResponse = ApiAuthResponse(
            token: "fake_token",
            user: UserResponse(id: "1", email: "test@test.com", name: "Test User", tier: 1, notificationsEnabled: true, language: "tr", createdAt: nil),
            message: "Success",
            success: true
        )
        mockRepository.loginResult = .success(expectedResponse)
        
        // When
        let result = await loginUseCase.execute(email: "test@test.com", password: "password")
        
        // Then
        switch result {
        case .success(let response):
            XCTAssertEqual(response.token, "fake_token")
            XCTAssertEqual(response.user?.email, "test@test.com")
        case .failure:
            XCTFail("Login should succeed")
        }
    }
    
    func testLoginFailure() async {
        // Given
        let expectedError = NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
        mockRepository.loginResult = .failure(expectedError)
        
        // When
        let result = await loginUseCase.execute(email: "wrong@test.com", password: "wrong")
        
        // Then
        switch result {
        case .success:
            XCTFail("Login should fail")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 401)
        }
    }
}
