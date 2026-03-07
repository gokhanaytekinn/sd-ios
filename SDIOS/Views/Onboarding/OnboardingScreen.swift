import SwiftUI

struct OnboardingScreen: View {
    let onGetStartedClick: () -> Void
    
    @State private var currentPage = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar with Skip button
                HStack {
                    Spacer()
                    if currentPage == 0 {
                        Button(action: onGetStartedClick) {
                            Text("skip".localized())
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .frame(height: 56)
                
                TabView(selection: $currentPage) {
                    onboardingPage(
                        title: "onboarding_title_1".localized(),
                        description: "onboarding_desc_1".localized(),
                        icon: "iphone",
                        tag: 0
                    )
                    
                    onboardingPage(
                        title: "onboarding_title_3".localized(),
                        description: "onboarding_desc_3".localized(),
                        icon: "bell_piggy",
                        tag: 1
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer().frame(height: 32)
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<2) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.primaryBlue : Color.appOnBackground(for: colorScheme).opacity(0.2))
                            .frame(width: currentPage == index ? 40 : 10, height: 10)
                    }
                }
                
                Spacer().frame(height: 48)
                
                // Action Button
                Button(action: {
                    if currentPage < 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onGetStartedClick()
                    }
                }) {
                    Text(currentPage == 1 ? "get_started".localized() : "continue_btn".localized())
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.primaryBlue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 16)
            }
        }
    }
    
    @ViewBuilder
    private func onboardingPage(title: String, description: String, icon: String, tag: Int) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon Visual
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.15))
                    .frame(width: 240, height: 240)
                
                if icon == "iphone" {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(LinearGradient(colors: [Color(hex: "4B91F7"), Color(hex: "367AF6")], startPoint: .top, endPoint: .bottom))
                            .frame(width: 70, height: 130)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        
                        VStack(spacing: 0) {
                            Spacer().frame(height: 8)
                            // Speaker/Sensor
                            Capsule()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 25, height: 3)
                            
                            Spacer()
                            
                            // Bottom indicators
                            HStack(spacing: 4) {
                                ForEach(0..<4) { _ in
                                    Circle().fill(Color.white.opacity(0.4)).frame(width: 4, height: 4)
                                }
                            }
                            Spacer().frame(height: 10)
                        }
                        .frame(width: 70, height: 130)
                    }
                    .shadow(color: Color.primaryBlue.opacity(0.3), radius: 15, y: 10)
                } else if icon == "bell_piggy" {
                    ZStack {
                        // Bell Box
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "1F2937"))
                            .frame(width: 110, height: 110)
                            .overlay(
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.primaryBlue)
                            )
                            .offset(x: -35, y: -35)
                        
                        // Piggy Box
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color.primaryBlue)
                            .frame(width: 110, height: 110)
                            .overlay(
                                Image(systemName: "piggybank.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 35, y: 35)
                    }
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 15)
                }
            }
            .frame(height: 300)
            
            Spacer().frame(height: 48)
            
            // Content
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 16)
            
            Text(description)
                .font(.system(size: 16))
                .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .tag(tag)
    }
}
