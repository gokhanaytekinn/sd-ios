import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onLoginSuccess: () -> Void
    let onNavigateToRegister: () -> Void
    let onNavigateToForgotPassword: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var passwordVisible = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            Text(NSLocalizedString("app_name", comment: ""))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(16)
            
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    // Headline
                    Text(NSLocalizedString("welcome_back", comment: ""))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    Spacer().frame(height: 8)
                    
                    Text(NSLocalizedString("login_desc", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        .lineSpacing(4)
                    
                    Spacer().frame(height: 24)
                    
                    // Email Field
                    SDOutlinedTextField(
                        title: NSLocalizedString("email", comment: ""),
                        placeholder: NSLocalizedString("email_placeholder", comment: ""),
                        text: $email,
                        error: authViewModel.emailError,
                        keyboardType: .emailAddress
                    )
                    .onChange(of: email) { _, _ in authViewModel.clearError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Password Field
                    SDOutlinedTextField(
                        title: NSLocalizedString("password", comment: ""),
                        placeholder: NSLocalizedString("password_placeholder", comment: ""),
                        text: $password,
                        error: authViewModel.passwordError,
                        isSecure: true
                    )
                    .onChange(of: password) { _, _ in authViewModel.clearError() }
                    
                    Spacer().frame(height: 12)
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button(action: onNavigateToForgotPassword) {
                            Text(NSLocalizedString("forgot_password", comment: ""))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primaryBlue)
                        }
                    }
                    
                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 24)
            }
            
            // Sticky Footer
            VStack(spacing: 0) {
                Divider().opacity(0.1)
                
                VStack(spacing: 16) {
                    // Login Button
                    SDButton(
                        title: NSLocalizedString("login", comment: ""),
                        isLoading: authViewModel.isLoading,
                        isEnabled: !email.isEmpty && !password.isEmpty
                    ) {
                        authViewModel.login(email: email, password: password, onSuccess: onLoginSuccess)
                    }
                    
                    // Register Link
                    HStack(spacing: 0) {
                        Text(NSLocalizedString("no_account_prompt", comment: ""))
                            .font(.system(size: 14))
                            .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        
                        Button(action: onNavigateToRegister) {
                            Text(NSLocalizedString("register", comment: ""))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primaryBlue)
                        }
                    }
                    
                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(Color.appBackground(for: colorScheme))
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .alert(NSLocalizedString("error", comment: ""), isPresented: Binding(
            get: { authViewModel.error != nil },
            set: { if !$0 { authViewModel.clearGeneralError() } }
        )) {
            Button(NSLocalizedString("close", comment: ""), role: .cancel) {
                authViewModel.clearGeneralError()
            }
        } message: {
            Text(authViewModel.error ?? "")
        }
    }
}
