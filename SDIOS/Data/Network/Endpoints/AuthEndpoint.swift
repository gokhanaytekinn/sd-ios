import Foundation

/// Auth ile ilgili tüm API uç noktalarını tanımlayan Enum.
/// Bu yapı, isteklerin parametrelerini tip güvenli ve tek bir yerde toplar.
enum AuthEndpoint: APIEndpoint {
    case login(LoginRequest)
    case register(RegisterRequest)
    case loginWithGoogle(GoogleAuthRequest)
    case getCurrentUser
    case deleteAccount
    case forgotPassword(ForgotPasswordRequest)
    case verifyCode(VerifyCodeRequest)
    case resetPassword(ResetPasswordRequest)
    
    var path: String {
        switch self {
        case .login: return "/api/auth/login"
        case .register: return "/api/auth/register"
        case .loginWithGoogle: return "/api/auth/google"
        case .getCurrentUser: return "/api/auth/me"
        case .deleteAccount: return "/api/auth/delete"
        case .forgotPassword: return "/api/auth/forgot-password"
        case .verifyCode: return "/api/auth/verify-code"
        case .resetPassword: return "/api/auth/reset-password"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .loginWithGoogle, .forgotPassword, .verifyCode, .resetPassword:
            return .post
        case .getCurrentUser:
            return .get
        case .deleteAccount:
            return .delete
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .login(let req): return try? encoder.encode(req)
        case .register(let req): return try? encoder.encode(req)
        case .loginWithGoogle(let req): return try? encoder.encode(req)
        case .forgotPassword(let req): return try? encoder.encode(req)
        case .verifyCode(let req): return try? encoder.encode(req)
        case .resetPassword(let req): return try? encoder.encode(req)
        default: return nil
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .login, .register, .loginWithGoogle, .forgotPassword, .verifyCode, .resetPassword:
            return false
        default:
            return true
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}
