import Foundation

// Google Sign-In Helper for iOS
// This requires adding the Google Sign-In SDK via Swift Package Manager:
// https://github.com/google/GoogleSignIn-iOS
// Also requires a GoogleService-Info.plist in the project

// Instructions to set up:
// 1. Add GoogleSignIn-iOS package: https://github.com/google/GoogleSignIn-iOS
// 2. Download GoogleService-Info.plist from Firebase Console
// 3. Add the reversed client ID as a URL scheme in Info.plist
// 4. Update the clientID below

import UIKit

class GoogleSignInHelper {
    static let shared = GoogleSignInHelper()
    
    private init() {}
    
    // Call this from the Login screen's Google button
    func signIn(completion: @escaping (Result<String, Error>) -> Void) {
        // When Google Sign-In SDK is added, use:
        //
        // guard let rootController = getRootViewController() else {
        //     completion(.failure(GoogleSignInError.noRootViewController))
        //     return
        // }
        //
        // GIDSignIn.sharedInstance.signIn(
        //     withPresenting: rootController
        // ) { signInResult, error in
        //     if let error = error {
        //         completion(.failure(error))
        //         return
        //     }
        //     guard let idToken = signInResult?.user.idToken?.tokenString else {
        //         completion(.failure(GoogleSignInError.noIdToken))
        //         return
        //     }
        //     completion(.success(idToken))
        // }
        
        // Placeholder - will be activated when Google Sign-In SDK is configured
        completion(.failure(GoogleSignInError.notConfigured))
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
    
    enum GoogleSignInError: LocalizedError {
        case noRootViewController
        case noIdToken
        case notConfigured
        
        var errorDescription: String? {
            switch self {
            case .noRootViewController: return "No root view controller found"
            case .noIdToken: return "No ID token received"
            case .notConfigured: return "Google Sign-In is not configured yet. Add GoogleSignIn-iOS SDK and GoogleService-Info.plist."
            }
        }
    }
}
