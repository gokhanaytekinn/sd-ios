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
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("register".localized())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        Text("register_desc".localized())
                            .font(.system(size: 16))
                            .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                            .lineSpacing(4)
                    }
                    
                    // Full Name
                    SDOutlinedTextField(
                        title: "full_name".localized(),
                        placeholder: "full_name_placeholder".localized(),
                        text: $fullName,
                        errorMessage: authViewModel.nameError,
                        leadingIcon: "person",
                        focusBinding: $focusedField,
                        focusValue: "fullName"
                    )
                    .onChange(of: fullName) { oldValue, newValue in self.authViewModel.clearNameError() }
                    
                    // Email
                    SDOutlinedTextField(
                        title: "email".localized(),
                        placeholder: "email_placeholder".localized(),
                        text: $email,
                        errorMessage: authViewModel.emailError,
                        keyboardType: .emailAddress,
                        leadingIcon: "envelope",
                        focusBinding: $focusedField,
                        focusValue: "email"
                    )
                    .onChange(of: email) { oldValue, newValue in self.authViewModel.clearEmailError() }
                    
                    // Password
                    SDOutlinedTextField(
                        title: "password".localized(),
                        placeholder: "password_placeholder".localized(),
                        text: $password,
                        errorMessage: authViewModel.passwordError,
                        isSecure: true,
                        leadingIcon: "lock",
                        focusBinding: $focusedField,
                        focusValue: "password"
                    )
                    .onChange(of: password) { oldValue, newValue in self.authViewModel.clearPasswordError() }
                    
                    // Confirm Password
                    SDOutlinedTextField(
                        title: "confirm_password_label".localized(),
                        placeholder: "password_placeholder".localized(),
                        text: $confirmPassword,
                        errorMessage: authViewModel.confirmPasswordError,
                        isSecure: true,
                        leadingIcon: "lock",
                        focusBinding: $focusedField,
                        focusValue: "confirmPassword"
                    )
                    .onChange(of: confirmPassword) { oldValue, newValue in self.authViewModel.clearConfirmPasswordError() }
                    
                    // Terms Checkbox
                    HStack(alignment: .top, spacing: 8) {
                        Button(action: { termsAccepted.toggle() }) {
                            Image(systemName: termsAccepted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundColor(termsAccepted ? .primaryBlue : Color.appOnSurfaceVariant(for: colorScheme))
                        }
                        
                        Text(termsAndPrivacyText)
                            .lineSpacing(4)
                            .environment(\.openURL, OpenURLAction { url in
                                if url.scheme == "app" {
                                    if url.host == "terms" {
                                        showTermsDialog = true
                                        return .handled
                                    } else if url.host == "privacy" {
                                        showPrivacyDialog = true
                                        return .handled
                                    }
                                }
                                return .systemAction
                            })
                    }
                    
                    // Register Footer inside ScrollView
                    VStack(spacing: 20) {
                        SDButton(
                            title: "register".localized(),
                            isLoading: authViewModel.isLoading,
                            isEnabled: termsAccepted && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !fullName.isEmpty
                        ) {
                            performRegister()
                        }
                        
                        HStack {
                            VStack { Divider().background(Color.appOutline(for: colorScheme)) }
                            Text("or".localized())
                                .font(.system(size: 14))
                                .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                                .padding(.horizontal, 8)
                            VStack { Divider().background(Color.appOutline(for: colorScheme)) }
                        }
                        
                        AppleSignInButton {
                            authViewModel.signInWithApple(onSuccess: onRegisterSuccess)
                        }
                        
                        GoogleSignInButton {
                            authViewModel.signInWithGoogle(onSuccess: onRegisterSuccess)
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
                }
                .padding(.horizontal, 24)
            }
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
    
    private var termsAndPrivacyText: AttributedString {
        let baseFont = Font.system(size: 14)
        let mediumFont = Font.system(size: 14, weight: .medium)
        
        var pre = AttributedString("accept_terms_pre".localized())
        pre.foregroundColor = Color.appOnBackground(for: colorScheme).opacity(0.6)
        pre.font = baseFont
        
        var terms = AttributedString("terms_of_use_title".localized())
        terms.link = URL(string: "app://terms")
        terms.foregroundColor = .primaryBlue
        terms.font = mediumFont
        
        var and = AttributedString("and".localized())
        and.foregroundColor = Color.appOnBackground(for: colorScheme).opacity(0.6)
        and.font = baseFont
        
        var privacy = AttributedString("privacy_policy_title".localized())
        privacy.link = URL(string: "app://privacy")
        privacy.foregroundColor = .primaryBlue
        privacy.font = mediumFont
        
        var post = AttributedString("accept_terms_post".localized())
        post.foregroundColor = Color.appOnBackground(for: colorScheme).opacity(0.6)
        post.font = baseFont
        
        return pre + terms + and + privacy + post
    }
    
    private func performRegister() {
        authViewModel.register(name: fullName, email: email, password: password, confirmPassword: confirmPassword) {
            onRegisterSuccess()
        }
        
        // Handle auto-focus on error
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if authViewModel.nameError != nil {
                focusedField = "fullName"
            } else if authViewModel.emailError != nil {
                focusedField = "email"
            } else if authViewModel.passwordError != nil {
                focusedField = "password"
            } else if authViewModel.confirmPasswordError != nil {
                focusedField = "confirmPassword"
            }
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
