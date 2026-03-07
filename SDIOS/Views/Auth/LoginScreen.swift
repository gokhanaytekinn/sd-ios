import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onLoginSuccess: () -> Void
    let onNavigateToRegister: () -> Void
    let onNavigateToForgotPassword: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var passwordVisible = false
    
    @FocusState private var focusedField: String?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            Text("app_name".localized())
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(16)
            
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    // Headline
                    Text("welcome_back".localized())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    Spacer().frame(height: 8)
                    
                    Text("login_desc".localized())
                        .font(.system(size: 16))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        .lineSpacing(4)
                    
                    Spacer().frame(height: 24)
                    
                    // Email Field
                    SDOutlinedTextField(
                        title: "email".localized(),
                        placeholder: "email_placeholder".localized(),
                        text: $email,
                        errorMessage: authViewModel.emailError,
                        keyboardType: .emailAddress,
                        focusBinding: $focusedField,
                        focusValue: "email"
                    )
                    .onChange(of: email) { _ in self.authViewModel.clearEmailError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Password Field
                    SDOutlinedTextField(
                        title: "password".localized(),
                        placeholder: "password_placeholder".localized(),
                        text: $password,
                        errorMessage: authViewModel.passwordError,
                        isSecure: true,
                        focusBinding: $focusedField,
                        focusValue: "password"
                    )
                    .onChange(of: password) { _ in self.authViewModel.clearPasswordError() }
                    
                    Spacer().frame(height: 12)
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button(action: onNavigateToForgotPassword) {
                            Text("forgot_password".localized())
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primaryBlue)
                        }
                    }
                    
                    Spacer().frame(height: 24)
                    
                    // Footer content now inside ScrollView
                    VStack(spacing: 0) {
                        Divider().opacity(0.1)
                        
                        VStack(spacing: 16) {
                            // Login Button
                            SDButton(
                                title: "login".localized(),
                                isLoading: authViewModel.isLoading,
                                isEnabled: !email.isEmpty && !password.isEmpty
                            ) {
                                performLogin()
                            }
                            
                            HStack {
                                VStack { Divider().background(Color.appOutline(for: colorScheme)) }
                                Text("or".localized())
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                                    .padding(.horizontal, 8)
                                VStack { Divider().background(Color.appOutline(for: colorScheme)) }
                            }
                            
                            GoogleSignInButton {
                                authViewModel.signInWithGoogle(onSuccess: onLoginSuccess)
                            }
                            
                            // Register Link
                            HStack(spacing: 0) {
                                Text("no_account_prompt".localized())
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                                
                                Button(action: onNavigateToRegister) {
                                    Text("register".localized())
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primaryBlue)
                                }
                            }
                            
                            Spacer().frame(height: 16)
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .withErrorDialog(errorMessage: $authViewModel.error) {
            authViewModel.clearGeneralError()
        }
    }
    
    private func performLogin() {
        authViewModel.login(email: email, password: password) {
            onLoginSuccess()
        }
        
        // Handle auto-focus on error
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if authViewModel.emailError != nil {
                focusedField = "email"
            } else if authViewModel.passwordError != nil {
                focusedField = "password"
            }
        }
    }
}
