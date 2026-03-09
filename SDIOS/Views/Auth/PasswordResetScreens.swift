import SwiftUI

// MARK: - Forgot Password Screen
struct ForgotPasswordScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onCodeSent: () -> Void
    let onBackToLogin: () -> Void
    
    @State private var email = ""
    @FocusState private var focusedField: String?
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
                        keyboardType: .emailAddress,
                        leadingIcon: "envelope",
                        focusBinding: $focusedField,
                        focusValue: "email"
                    )
                    .onChange(of: email) { oldValue, newValue in self.authViewModel.clearEmailError() }
                    
                    Spacer().frame(height: 32)
                    
                    VStack(spacing: 20) {
                        SDButton(
                            title: NSLocalizedString("send_code", comment: ""),
                            isLoading: authViewModel.isLoading,
                            isEnabled: !email.isEmpty
                        ) {
                            sendCode()
                        }
                        
                        Button(action: onBackToLogin) {
                            Text(NSLocalizedString("back_to_login", comment: ""))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primaryBlue)
                        }
                        
                        Spacer().frame(height: 16)
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
    
    private func sendCode() {
        authViewModel.forgotPassword(email: email) {
            onCodeSent()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if authViewModel.emailError != nil {
                focusedField = "email"
            }
        }
    }
}

// MARK: - Verification Code Screen
struct VerificationCodeScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onVerified: () -> Void
    let onBack: () -> Void
    
    @State private var code = ""
    @FocusState private var isFocused: Bool
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
                            .frame(height: 45)
                            .background(Color.appSurface(for: colorScheme).opacity(0.001))
                            .contentShape(Rectangle())
                            .onTapGesture { isFocused = true }
                            .focused($isFocused)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isFocused ? Color.primaryBlue : Color.appOnBackground(for: colorScheme).opacity(0.2), lineWidth: isFocused ? 2 : 1)
                            )
                            .onChange(of: code) { oldValue, newValue in
                                if newValue.count > 6 {
                                    code = String(newValue.prefix(6))
                                }
                            }
                    }
                    
                    Spacer().frame(height: 32)
                    
                    VStack(spacing: 20) {
                        SDButton(
                            title: NSLocalizedString("verify_and_continue", comment: ""),
                            isLoading: authViewModel.isLoading,
                            isEnabled: code.count == 6
                        ) {
                            authViewModel.verifyCode(code: code, onSuccess: onVerified)
                        }
                        
                        Spacer().frame(height: 16)
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
}

// MARK: - Reset Password Screen
struct ResetPasswordScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let verificationCode: String
    let onPasswordReset: () -> Void
    let onBack: () -> Void
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: String?
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
                        isSecure: true,
                        leadingIcon: "lock",
                        focusBinding: $focusedField,
                        focusValue: "newPassword"
                    )
                    .onChange(of: newPassword) { oldValue, newValue in self.authViewModel.clearPasswordError() }
                    
                    if newPassword.count < 6 {
                        Spacer().frame(height: 8)
                        Text(NSLocalizedString("min_6_chars", comment: ""))
                            .font(.system(size: 12))
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    }
                    
                    Spacer().frame(height: 20)
                    
                    SDOutlinedTextField(
                        title: NSLocalizedString("confirm_password_label", comment: ""),
                        placeholder: NSLocalizedString("password_placeholder", comment: ""),
                        text: $confirmPassword,
                        errorMessage: authViewModel.confirmPasswordError,
                        isSecure: true,
                        leadingIcon: "lock",
                        focusBinding: $focusedField,
                        focusValue: "confirmPassword"
                    )
                    .onChange(of: confirmPassword) { oldValue, newValue in self.authViewModel.clearConfirmPasswordError() }
                    
                    if !confirmPassword.isEmpty {
                        Spacer().frame(height: 8)
                        Text(NSLocalizedString("passwords_match", comment: ""))
                            .font(.system(size: 12))
                            .foregroundColor(passwordsMatch ? .successColor : .errorColor)
                    }
                    
                    Spacer().frame(height: 32)
                    
                    VStack(spacing: 20) {
                        SDButton(
                            title: NSLocalizedString("update_password", comment: ""),
                            isLoading: authViewModel.isLoading,
                            isEnabled: newPassword.count >= 6 && passwordsMatch
                        ) {
                            performReset()
                        }
                        
                        Spacer().frame(height: 16)
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
    
    private func performReset() {
        authViewModel.resetPassword(code: verificationCode, newPassword: newPassword) {
            onPasswordReset()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if authViewModel.passwordError != nil {
                focusedField = "newPassword"
            } else if authViewModel.confirmPasswordError != nil {
                focusedField = "confirmPassword"
            }
        }
    }
}
