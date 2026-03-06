import SwiftUI

struct RegisterScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onRegisterSuccess: () -> Void
    let onNavigateToLogin: () -> Void
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordVisible = false
    @State private var confirmPasswordVisible = false
    @State private var termsAccepted = false
    @State private var showTermsDialog = false
    @State private var showPrivacyDialog = false
    
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
                    
                    Text("register".localized())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    Spacer().frame(height: 8)
                    
                    Text("register_desc".localized())
                        .font(.system(size: 16))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        .lineSpacing(4)
                    
                    Spacer().frame(height: 24)
                    
                    // Full Name
                    SDOutlinedTextField(
                        title: "full_name".localized(),
                        placeholder: "full_name_placeholder".localized(),
                        text: $fullName,
                        errorMessage: authViewModel.nameError
                    )
                    .onChange(of: fullName) { _ in self.authViewModel.clearNameError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Email
                    SDOutlinedTextField(
                        title: "email".localized(),
                        placeholder: "email_placeholder".localized(),
                        text: $email,
                        errorMessage: authViewModel.emailError,
                        keyboardType: .emailAddress
                    )
                    .onChange(of: email) { _ in self.authViewModel.clearEmailError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Password
                    SDOutlinedTextField(
                        title: "password".localized(),
                        placeholder: "password_placeholder".localized(),
                        text: $password,
                        errorMessage: authViewModel.passwordError,
                        isSecure: true
                    )
                    .onChange(of: password) { _ in self.authViewModel.clearPasswordError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Confirm Password
                    SDOutlinedTextField(
                        title: "confirm_password_label".localized(),
                        placeholder: "password_placeholder".localized(),
                        text: $confirmPassword,
                        errorMessage: authViewModel.confirmPasswordError,
                        isSecure: true
                    )
                    .onChange(of: confirmPassword) { _ in self.authViewModel.clearConfirmPasswordError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Terms Checkbox
                    HStack(alignment: .top, spacing: 8) {
                        Button(action: { termsAccepted.toggle() }) {
                            Image(systemName: termsAccepted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundColor(termsAccepted ? .primaryBlue : Color.appOnSurfaceVariant(for: colorScheme))
                        }
                        
                        VStack(alignment: .leading) {
                            (Text("accept_terms_pre".localized())
                                .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                             + Text("terms_of_use_title".localized())
                                .foregroundColor(.primaryBlue)
                                .fontWeight(.medium)
                             + Text("and".localized())
                                .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                             + Text("privacy_policy_title".localized())
                                .foregroundColor(.primaryBlue)
                                .fontWeight(.medium)
                             + Text("accept_terms_post".localized())
                                .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                            )
                            .font(.system(size: 14))
                            .lineSpacing(4)
                            .onTapGesture {
                                // Could show terms or privacy
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Sticky Footer
            VStack(spacing: 16) {
                SDButton(
                    title: "register".localized(),
                    isLoading: authViewModel.isLoading,
                    isEnabled: termsAccepted && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !fullName.isEmpty
                ) {
                    authViewModel.register(name: fullName, email: email, password: password, confirmPassword: confirmPassword, onSuccess: onRegisterSuccess)
                }
                
                HStack(spacing: 0) {
                    Text("already_have_account_prompt".localized())
                        .font(.system(size: 14))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                    
                    Button(action: onNavigateToLogin) {
                        Text("login".localized())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primaryBlue)
                    }
                }
                
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 24)
            .background(Color.appBackground(for: colorScheme))
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .alert("error".localized(), isPresented: Binding(
            get: { authViewModel.error != nil },
            set: { if !$0 { authViewModel.clearGeneralError() } }
        )) {
            Button("close".localized(), role: .cancel) {
                authViewModel.clearGeneralError()
            }
        } message: {
            Text(authViewModel.error ?? "")
        }
        .sheet(isPresented: $showTermsDialog) {
            termsSheet
        }
        .sheet(isPresented: $showPrivacyDialog) {
            privacySheet
        }
    }
    
    private var termsSheet: some View {
        NavigationStack {
            ScrollView {
                Text("terms_of_use_content".localized())
                    .padding()
            }
            .navigationTitle("terms_of_use_title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("understood".localized()) {
                        showTermsDialog = false
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private var privacySheet: some View {
        NavigationStack {
            ScrollView {
                Text("privacy_dialog_content".localized())
                    .padding()
            }
            .navigationTitle("privacy_policy_title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("close".localized()) {
                        showPrivacyDialog = false
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.bold)
                }
            }
        }
        .withErrorDialog(errorMessage: $authViewModel.error) {
            authViewModel.clearGeneralError()
        }
    }
}
