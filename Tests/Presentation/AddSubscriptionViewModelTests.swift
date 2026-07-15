import XCTest
@testable import SDIOS

final class AddSubscriptionViewModelTests: XCTestCase {
    var viewModel: AddSubscriptionViewModel!
    var mockCreate: MockCreateSubscriptionUseCase!
    var mockUpdate: MockUpdateSubscriptionUseCase!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockCreate = MockCreateSubscriptionUseCase()
        mockUpdate = MockUpdateSubscriptionUseCase()
        viewModel = AddSubscriptionViewModel(
            createSubscriptionUseCase: mockCreate,
            updateSubscriptionUseCase: mockUpdate
        )
    }
    
    @MainActor
    func testAddJointEmailValid() {
        // When
        viewModel.emailInput = "test@example.com"
        viewModel.addJointEmail()
        
        // Then
        XCTAssertEqual(viewModel.jointEmails.count, 1)
        XCTAssertEqual(viewModel.jointEmails.first, "test@example.com")
        XCTAssertEqual(viewModel.emailInput, "")
    }
    
    @MainActor
    func testAddJointEmailInvalid() {
        // When
        viewModel.emailInput = "invalid-email"
        viewModel.addJointEmail()
        
        // Then
        XCTAssertEqual(viewModel.jointEmails.count, 0)
        XCTAssertNotNil(viewModel.error)
    }
    
    @MainActor
    func testAmountFormatting() async {
        // When: User types "1234"
        viewModel.handleAmountChange("1234")
        
        // Then: Should format as "1.234"
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.amount, "1.234")
        
        // When: User types "1234,56"
        viewModel.handleAmountChange("1234,56")
        
        // Then: Should format as "1.234,56"
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.amount, "1.234,56")
    }
    
    @MainActor
    func testValidationFailure() {
        // Given: Empty fields
        viewModel.name = ""
        viewModel.amount = ""
        
        // When
        let isValid = viewModel.validate()
        
        // Then
        XCTAssertFalse(isValid)
        XCTAssertNotNil(viewModel.nameError)
        XCTAssertNotNil(viewModel.amountError)
    }
    
    @MainActor
    func testSetupForEdit() {
        // Given
        let sub = Subscription(id: "s1", name: "Netflix", cost: 15.99, currency: 1, billingCycle: .monthly)
        
        // When
        viewModel.setupForEdit(subscription: sub)
        
        // Then
        XCTAssertTrue(viewModel.isEditing)
        XCTAssertEqual(viewModel.name, "Netflix")
        XCTAssertEqual(viewModel.amount, "15,99")
    }
    
    @MainActor
    func testSaveSuccess() async {
        // Given
        viewModel.name = "New Sub"
        viewModel.amount = "10,00"
        viewModel.selectedCategory = "category_streaming"
        mockCreate.result = .success(Subscription(id: "1", name: "New Sub", cost: 10.0, currency: 1, billingCycle: .monthly))
        
        let expectation = XCTestExpectation(description: "Save successful")
        
        // When
        viewModel.save(currency: 1) {
            expectation.fulfill()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
}
