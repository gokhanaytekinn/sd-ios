import Foundation

/// Uygulama genelinde kullanılan merkezi hata tipleri.
/// Dünya standartlarında, hata yönetimi String yerine bu tip güvenli yapılarla yapılır.
enum AppError: LocalizedError, Equatable {
    case network(APIError)            // Ağ bağlantısı hataları
    case auth(AuthErrorType)          // Kimlik doğrulama hataları
    case validation(String)           // Veri doğrulama hataları
    case database(String)             // Yerel veritabanı hataları
    case unknown                      // Beklenmedik hatalar
    
    /// Kullanıcıya gösterilecek hata mesajı.
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.errorDescription
        case .auth(let type):
            return type.description
        case .validation(let message):
            return message
        case .database(let detail):
            return "Veritabanı hatası: \(detail)"
        case .unknown:
            return "Bir hata oluştu. Lütfen tekrar deneyin."
        }
    }

    /// Manuel Equatable uygulaması - İzolasyon sorunlarını çözmek için nonisolated.
    nonisolated static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.network(let l), .network(let r)): return l == r
        case (.auth(let l), .auth(let r)): return l == r
        case (.validation(let l), .validation(let r)): return l == r
        case (.database(let l), .database(let r)): return l == r
        case (.unknown, .unknown): return true
        default: return false
        }
    }
}

/// Kimlik doğrulama hatalarının detayları.
enum AuthErrorType: Equatable {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case sessionExpired
    
    var description: String {
        switch self {
        case .invalidCredentials: return "E-posta veya şifre hatalı."
        case .userNotFound: return "Kullanıcı bulunamadı."
        case .emailAlreadyInUse: return "Bu e-posta adresi zaten kullanımda."
        case .weakPassword: return "Şifre çok zayıf. En az 6 karakter olmalı."
        case .sessionExpired: return "Oturum süresi doldu. Lütfen tekrar giriş yapın."
        }
    }

    /// Manuel Equatable uygulaması - İzolasyon sorunlarını çözmek için nonisolated.
    nonisolated static func == (lhs: AuthErrorType, rhs: AuthErrorType) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCredentials, .invalidCredentials),
             (.userNotFound, .userNotFound),
             (.emailAlreadyInUse, .emailAlreadyInUse),
             (.weakPassword, .weakPassword),
             (.sessionExpired, .sessionExpired):
            return true
        default:
            return false
        }
    }
}
