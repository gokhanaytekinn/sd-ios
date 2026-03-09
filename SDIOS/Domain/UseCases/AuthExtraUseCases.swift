import Foundation

// MARK: - Forgot Password Use Case
protocol ForgotPasswordUseCaseProtocol {
    func execute(email: String) async -> Result<Void, Error>
}

class ForgotPasswordUseCase: ForgotPasswordUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    init(repository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.repository = repository
    }
    func execute(email: String) async -> Result<Void, Error> {
        return await repository.forgotPassword(email: email)
    }
}

// MARK: - Verify Code Use Case
protocol VerifyCodeUseCaseProtocol {
    func execute(email: String, code: String) async -> Result<Void, Error>
}

class VerifyCodeUseCase: VerifyCodeUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    init(repository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.repository = repository
    }
    func execute(email: String, code: String) async -> Result<Void, Error> {
        return await repository.verifyCode(email: email, code: code)
    }
}

// MARK: - Reset Password Use Case
protocol ResetPasswordUseCaseProtocol {
    func execute(email: String, code: String, newPassword: String) async -> Result<Void, Error>
}

class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    init(repository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.repository = repository
    }
    func execute(email: String, code: String, newPassword: String) async -> Result<Void, Error> {
        return await repository.resetPassword(email: email, code: code, newPassword: newPassword)
    }
}

// MARK: - Delete Account Use Case
protocol DeleteAccountUseCaseProtocol {
    func execute() async -> Result<Void, Error>
}

class DeleteAccountUseCase: DeleteAccountUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    init(repository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.repository = repository
    }
    func execute() async -> Result<Void, Error> {
        return await repository.deleteAccount()
    }
}
