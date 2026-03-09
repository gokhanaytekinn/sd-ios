import Foundation

/// Google ile giriş (Social Login) işlemlerini yöneten Use Case.
protocol GoogleLoginUseCaseProtocol {
    func execute(idToken: String) async -> Result<ApiAuthResponse, Error>
}

class GoogleLoginUseCase: GoogleLoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.repository = repository
    }
    
    func execute(idToken: String) async -> Result<ApiAuthResponse, Error> {
        // Repository üzerinden Google token ile oturum açma işlemini tetikle
        return await repository.loginWithGoogle(idToken: idToken)
    }
}
