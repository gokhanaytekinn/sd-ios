import Foundation

/// Kullanıcı kayıt (signup) işlemlerini yöneten Use Case.
/// ViewModel'ın yükünü azaltarak kayıt mantığını tek bir yerde toplar.
protocol RegisterUseCaseProtocol {
    /// Kayıt işlemini yürütür.
    /// - Parameters:
    ///   - name: Kullanıcı adı
    ///   - email: E-posta adresi
    ///   - password: Şifre
    ///   - language: Tercih edilen dil
    /// - Returns: Başarılı ise Auth Response, başarısız ise Error döner.
    func execute(name: String, email: String, password: String, language: String?) async -> Result<ApiAuthResponse, Error>
}

class RegisterUseCase: RegisterUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    /// Başlatıcı
    /// - Parameter repository: Kullanılacak repository (Varsayılan: AuthRepository.shared)
    init(repository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.repository = repository
    }
    
    /// İş mantığını yürüten ana fonksiyon.
    func execute(name: String, email: String, password: String, language: String?) async -> Result<ApiAuthResponse, Error> {
        // Kayıt işlemini repository üzerinden tetikliyoruz.
        return await repository.register(email: email, password: password, name: name, language: language)
    }
}
