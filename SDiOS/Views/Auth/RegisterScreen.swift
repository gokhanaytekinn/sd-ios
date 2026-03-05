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
            Text(NSLocalizedString("app_name", comment: ""))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(16)
            
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    Text(NSLocalizedString("register", comment: ""))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    Spacer().frame(height: 8)
                    
                    Text(NSLocalizedString("register_desc", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        .lineSpacing(4)
                    
                    Spacer().frame(height: 24)
                    
                    // Full Name
                    SDOutlinedTextField(
                        title: NSLocalizedString("full_name", comment: ""),
                        placeholder: NSLocalizedString("full_name_placeholder", comment: ""),
                        text: $fullName,
                        error: authViewModel.nameError
                    )
                    .onChange(of: fullName) { _, _ in authViewModel.clearError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Email
                    SDOutlinedTextField(
                        title: NSLocalizedString("email", comment: ""),
                        placeholder: NSLocalizedString("email_placeholder", comment: ""),
                        text: $email,
                        error: authViewModel.emailError,
                        keyboardType: .emailAddress
                    )
                    .onChange(of: email) { _, _ in authViewModel.clearError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Password
                    SDOutlinedTextField(
                        title: NSLocalizedString("password", comment: ""),
                        placeholder: NSLocalizedString("password_placeholder", comment: ""),
                        text: $password,
                        error: authViewModel.passwordError,
                        isSecure: true
                    )
                    .onChange(of: password) { _, _ in authViewModel.clearError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Confirm Password
                    SDOutlinedTextField(
                        title: NSLocalizedString("confirm_password_label", comment: ""),
                        placeholder: NSLocalizedString("password_placeholder", comment: ""),
                        text: $confirmPassword,
                        error: authViewModel.confirmPasswordError,
                        isSecure: true
                    )
                    .onChange(of: confirmPassword) { _, _ in authViewModel.clearError() }
                    
                    Spacer().frame(height: 16)
                    
                    // Terms Checkbox
                    HStack(alignment: .top, spacing: 8) {
                        Button(action: { termsAccepted.toggle() }) {
                            Image(systemName: termsAccepted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundColor(termsAccepted ? .primaryBlue : Color.appOnSurfaceVariant(for: colorScheme))
                        }
                        
                        VStack(alignment: .leading) {
                            (Text(NSLocalizedString("accept_terms_pre", comment: ""))
                                .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                             + Text(NSLocalizedString("terms_of_use_title", comment: ""))
                                .foregroundColor(.primaryBlue)
                                .fontWeight(.medium)
                             + Text(NSLocalizedString("and", comment: ""))
                                .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                             + Text(NSLocalizedString("privacy_policy_title", comment: ""))
                                .foregroundColor(.primaryBlue)
                                .fontWeight(.medium)
                             + Text(NSLocalizedString("accept_terms_post", comment: ""))
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
                    title: NSLocalizedString("register", comment: ""),
                    isLoading: authViewModel.isLoading,
                    isEnabled: termsAccepted && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !fullName.isEmpty
                ) {
                    authViewModel.register(name: fullName, email: email, password: password, confirmPassword: confirmPassword, onSuccess: onRegisterSuccess)
                }
                
                HStack(spacing: 0) {
                    Text(NSLocalizedString("already_have_account_prompt", comment: ""))
                        .font(.system(size: 14))
                        .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                    
                    Button(action: onNavigateToLogin) {
                        Text(NSLocalizedString("login", comment: ""))
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
                Text(NSLocalizedString("terms_of_use_content", comment: ""))
                    .padding()
            }
            .navigationTitle(NSLocalizedString("terms_of_use_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("understood", comment: "")) {
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
                Text(NSLocalizedString("privacy_dialog_content", comment: ""))
                    .padding()
            }
            .navigationTitle(NSLocalizedString("privacy_policy_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("close", comment: "")) {
                        showPrivacyDialog = false
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
