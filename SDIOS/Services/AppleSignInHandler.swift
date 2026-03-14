import AuthenticationServices
import SwiftUI

#if !WIDGET
class AppleSignInHandler: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let viewModel: AuthViewModel
    private let onSuccess: () -> Void
    
    init(viewModel: AuthViewModel, onSuccess: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSuccess = onSuccess
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                viewModel.error = "Failed to get Apple identity token"
                return
            }
            
            let firstName = appleIDCredential.fullName?.givenName
            let lastName = appleIDCredential.fullName?.familyName
            
            viewModel.loginWithApple(identityToken: identityToken, firstName: firstName, lastName: lastName, onSuccess: onSuccess)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        viewModel.error = error.localizedDescription
    }
}
#endif
