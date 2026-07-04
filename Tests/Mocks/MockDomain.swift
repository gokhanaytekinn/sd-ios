import Foundation
@testable import SDIOS

// MARK: - Subscriptions
class MockGetSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol {
    var result: Result<[Subscription], Error> = .success([])
    func execute() async -> Result<[Subscription], Error> { return result }
}

class MockGetUpcomingSubscriptionsUseCase: GetUpcomingSubscriptionsUseCaseProtocol {
    var result: Result<[Subscription], Error> = .success([])
    func execute() async -> Result<[Subscription], Error> { return result }
}

class MockCreateSubscriptionUseCase: CreateSubscriptionUseCaseProtocol {
    var result: Result<Subscription, Error> = .failure(NSError(domain: "", code: -1))
    func execute(request: SubscriptionRequest) async -> Result<Subscription, Error> { return result }
}

class MockUpdateSubscriptionUseCase: UpdateSubscriptionUseCaseProtocol {
    var result: Result<Subscription, Error> = .failure(NSError(domain: "", code: -1))
    func execute(id: String, request: SubscriptionUpdateRequest) async -> Result<Subscription, Error> { return result }
}

class MockDeleteSubscriptionUseCase: DeleteSubscriptionUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute(id: String) async -> Result<Void, Error> { return result }
}

class MockCancelSubscriptionUseCase: CancelSubscriptionUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute(id: String) async -> Result<Void, Error> { return result }
}

class MockReactivateSubscriptionUseCase: ReactivateSubscriptionUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute(id: String) async -> Result<Void, Error> { return result }
}

// MARK: - Invitations
class MockGetPendingInvitationsUseCase: GetPendingInvitationsUseCaseProtocol {
    var result: Result<[SubscriptionInvitation], Error> = .success([])
    func execute() async -> Result<[SubscriptionInvitation], Error> { return result }
}

class MockAcceptInvitationUseCase: AcceptInvitationUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute(id: String) async -> Result<Void, Error> { return result }
}

class MockRejectInvitationUseCase: RejectInvitationUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute(id: String) async -> Result<Void, Error> { return result }
}

// MARK: - Auth
class MockLoginUseCase: LoginUseCaseProtocol {
    var result: Result<ApiAuthResponse, Error> = .failure(NSError(domain: "", code: -1))
    func execute(email: String, password: String) async -> Result<ApiAuthResponse, Error> { return result }
}

class MockRegisterUseCase: RegisterUseCaseProtocol {
    var result: Result<ApiAuthResponse, Error> = .failure(NSError(domain: "", code: -1))
    func execute(email: String, password: String, name: String?, language: String?) async -> Result<ApiAuthResponse, Error> { return result }
}

class MockGoogleLoginUseCase: GoogleLoginUseCaseProtocol {
    var result: Result<ApiAuthResponse, Error> = .failure(NSError(domain: "", code: -1))
    func execute(idToken: String) async -> Result<ApiAuthResponse, Error> { return result }
}

class MockForgotPasswordUseCase: ForgotPasswordUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute(email: String) async -> Result<Void, Error> { return result }
}

class MockVerifyCodeUseCase: VerifyCodeUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute(email: String, code: String) async -> Result<Void, Error> { return result }
}

class MockResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute(email: String, code: String, newPassword: String) async -> Result<Void, Error> { return result }
}

class MockDeleteAccountUseCase: DeleteAccountUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    func execute() async -> Result<Void, Error> { return result }
}

// MARK: - Transactions
class MockGetTransactionsUseCase: GetTransactionsUseCaseProtocol {
    var result: Result<PageTransactionResponse, Error> = .failure(NSError(domain: "", code: -1))
    func execute(page: Int, size: Int) async -> Result<PageTransactionResponse, Error> { return result }
}
