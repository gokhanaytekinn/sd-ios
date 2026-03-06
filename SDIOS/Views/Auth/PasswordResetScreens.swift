import SwiftUI

// MARK: - Forgot Password Screen
struct ForgotPasswordScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onCodeSent: () -> Void
    let onBackToLogin: () -> Void
    
    @State private var email = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar with back button
            HStack {
                Button(action: onBackToLogin) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
            }
            .padding(16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    Text(NSLocalizedString("forgot_password", comment: ""))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    Spacer().frame(height: 8)
                    
                    Text(NSLocalizedString("forgot_password_desc", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        .lineSpacing(4)
                    
                    Spacer().frame(height: 32)
                    
                    SDOutlinedTextField(
                        title: NSLocalizedString("email_address_label", comment: ""),
                        placeholder: NSLocalizedString("email_placeholder", comment: ""),
                        text: $email,
                        errorMessage: authViewModel.emailError,
                        keyboardType: .emailAddress
                    )
                    .onChange(of: email) { _ in self.authViewModel.clearEmailError() }
                }
                .padding(.horizontal, 24)
            }
            
            VStack(spacing: 16) {
                SDButton(
                    title: NSLocalizedString("send_code", comment: ""),
                    isLoading: authViewModel.isLoading,
                    isEnabled: !email.isEmpty
                ) {
                    authViewModel.forgotPassword(email: email, onSuccess: onCodeSent)
                }
                
                Button(action: onBackToLogin) {
                    Text(NSLocalizedString("back_to_login", comment: ""))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryBlue)
                }
                
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 24)
            .background(Color.appBackground(for: colorScheme))
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .withErrorDialog(errorMessage: $authViewModel.error) {
            authViewModel.clearGeneralError()
        }
    }
}

// MARK: - Verification Code Screen
struct VerificationCodeScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onVerified: () -> Void
    let onBack: () -> Void
    
    @State private var code = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
            }
            .padding(16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    Text(NSLocalizedString("verify_code_title", comment: ""))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    Spacer().frame(height: 8)
                    
                    Text(String(format: NSLocalizedString("verify_code_desc", comment: ""), authViewModel.resetEmail ?? ""))
                        .font(.system(size: 16))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        .lineSpacing(4)
                    
                    Spacer().frame(height: 32)
                    
                    // Code input - 6 digit
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("verify_code_title", comment: ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        TextField("000000", text: $code)
                            .keyboardType(.numberPad)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appOnBackground(for: colorScheme).opacity(0.2), lineWidth: 1)
                            )
                            .onChange(of: code) { newValue in
                                if newValue.count > 6 {
                                    code = String(newValue.prefix(6))
                                }
                            }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            VStack(spacing: 16) {
                SDButton(
                    title: NSLocalizedString("verify_and_continue", comment: ""),
                    isLoading: authViewModel.isLoading,
                    isEnabled: code.count == 6
                ) {
                    authViewModel.verifyCode(code: code, onSuccess: onVerified)
                }
                
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 24)
            .background(Color.appBackground(for: colorScheme))
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .withErrorDialog(errorMessage: $authViewModel.error) {
            authViewModel.clearGeneralError()
        }
    }
}

// MARK: - Reset Password Screen
struct ResetPasswordScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let verificationCode: String
    let onPasswordReset: () -> Void
    let onBack: () -> Void
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @Environment(\.colorScheme) var colorScheme
    
    var passwordsMatch: Bool {
        !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
            }
            .padding(16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    Text(NSLocalizedString("reset_password_title", comment: ""))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    Spacer().frame(height: 8)
                    
                    Text(NSLocalizedString("reset_password_desc", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        .lineSpacing(4)
                    
                    Spacer().frame(height: 32)
                    
                    SDOutlinedTextField(
                        title: NSLocalizedString("new_password_label", comment: ""),
                        placeholder: NSLocalizedString("password_placeholder", comment: ""),
                        text: $newPassword,
                        errorMessage: authViewModel.passwordError,
                        isSecure: true
                    )
                    .onChange(of: newPassword) { _ in self.authViewModel.clearPasswordError() }
                    
                    Spacer().frame(height: 8)
                    
                    Text(NSLocalizedString("min_6_chars", comment: ""))
                        .font(.system(size: 12))
                        .foregroundColor(newPassword.count >= 6 ? .successColor : Color.appOnSurfaceVariant(for: colorScheme))
                    
                    Spacer().frame(height: 16)
                    
                    SDOutlinedTextField(
                        title: NSLocalizedString("confirm_password_label", comment: ""),
                        placeholder: NSLocalizedString("password_placeholder", comment: ""),
                        text: $confirmPassword,
                        errorMessage: authViewModel.confirmPasswordError,
                        isSecure: true
                    )
                    .onChange(of: confirmPassword) { _ in self.authViewModel.clearConfirmPasswordError() }
                    
                    if !confirmPassword.isEmpty {
                        Spacer().frame(height: 8)
                        Text(NSLocalizedString("passwords_match", comment: ""))
                            .font(.system(size: 12))
                            .foregroundColor(passwordsMatch ? .successColor : .errorColor)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            VStack(spacing: 16) {
                SDButton(
                    title: NSLocalizedString("update_password", comment: ""),
                    isLoading: authViewModel.isLoading,
                    isEnabled: newPassword.count >= 6 && passwordsMatch
                ) {
                    authViewModel.resetPassword(code: verificationCode, newPassword: newPassword, onSuccess: onPasswordReset)
                }
                
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 24)
            .background(Color.appBackground(for: colorScheme))
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .withErrorDialog(errorMessage: $authViewModel.error) {
            authViewModel.clearGeneralError()
        }
    }
}
