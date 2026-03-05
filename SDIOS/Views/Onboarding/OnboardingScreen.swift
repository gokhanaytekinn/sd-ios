import SwiftUI

struct OnboardingScreen: View {
    let onGetStartedClick: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 48)
                
                // Badge
                HStack(spacing: 4) {
                    Text("🔍")
                        .font(.system(size: 12))
                    Text("app_name".localized().uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "9db99d"))
                        .tracking(1.5)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primaryBlue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 50))
                
                Spacer()
                
                // Hero Visual
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                    
                    Text("🔍💳")
                        .font(.system(size: 80))
                }
                .frame(width: 280, height: 280)
                
                Spacer().frame(height: 24)
                
                // Title
                (Text("onboarding_title_1".localized())
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                 + Text(" ")
                 + Text("onboarding_title_2".localized())
                    .foregroundColor(.primaryBlue)
                )
                .font(.system(size: 32, weight: .heavy))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                
                Spacer().frame(height: 16)
                
                // Description
                Text("onboarding_desc_1".localized())
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "9CA3AF"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                // Get Started Button
                Button(action: onGetStartedClick) {
                    HStack {
                        Text("get_started".localized())
                            .font(.system(size: 18, weight: .bold))
                            .tracking(0.15)
                        
                        Spacer().frame(width: 8)
                        
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Spacer().frame(height: 24)
                
                // Pagination
                HStack(spacing: 10) {
                    Circle().fill(Color.primaryBlue).frame(width: 10, height: 10)
                    Circle().fill(Color(hex: "374151")).frame(width: 10, height: 10)
                    Circle().fill(Color(hex: "374151")).frame(width: 10, height: 10)
                }
                
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 24)
        }
    }
}
