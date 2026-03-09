import Foundation

/// Kullanıcı giriş işlemlerini yöneten Use Case (Interactor).
/// Clean Architecture prensiplerine göre, ViewModel doğrudan Repository ile konuşmak yerine
/// bu Use Case'i tetikler. Bu sayede iş mantığı (business logic) merkezileşmiş olur.
protocol LoginUseCaseProtocol {
    /// Giriş işlemini yürütür.
    /// - Parameters:
    ///   - email: Kullanıcının e-posta adresi
    ///   - password: Kullanıcının şifresi
    /// - Returns: Başarılı ise Auth Response, başarısız ise Error döner.
    func execute(email: String, password: String) async -> Result<ApiAuthResponse, Error>
}

class LoginUseCase: LoginUseCaseProtocol {
    // Repository bağımlılığı, protokol üzerinden enjekte edilir (Dependency Injection).
    // Bu sayede test edilebilirliği artırırız.
    private let repository: AuthRepositoryProtocol
    
    /// Başlatıcı (Dependency Injection desteği ile)
    /// - Parameter repository: Kullanılacak repository (Varsayılan: AuthRepository.shared)
    init(repository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.repository = repository
    }
    
    /// İş mantığını yürüten ana fonksiyon.
    func execute(email: String, password: String) async -> Result<ApiAuthResponse, Error> {
        // Burada gerekirse girişe özel ek kontroller (logging, analytics vb.) yapılabilir.
        // Ancak işlevsel bir değişiklik yapmamak adına doğrudan repository çağrısı yapıyoruz.
        return await repository.login(email: email, password: password)
    }
}
