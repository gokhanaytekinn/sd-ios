import SwiftUI

/// Uygulama genelinde kullanılan iskelet (skeleton) görünümleri.
/// Spinner yerine bu yapılar kullanılarak "Cevap Veren UI" (Perceived Performance) sağlanır.

// MARK: - Skeleton Shimmer Animasyonu
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.15),
                            .clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: phase * geo.size.width)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

extension Shape {
    func baseSkeleton(colorScheme: ColorScheme) -> some View {
        self.fill(Color.appSurfaceVariant(for: colorScheme).opacity(0.5))
            .shimmer()
    }
}

// MARK: - Dashboard Skeleton
struct DashboardSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header (hello + title)
                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 160, height: 12)
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 120, height: 22)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer().frame(height: 20)
                
                // Summary card
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 110, height: 12)
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 160, height: 28)
                        
                        Spacer()
                        
                        Capsule()
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 80, height: 24)
                    }
                }
                .padding(24)
                .background(Color.appSurface(for: colorScheme).opacity(0.001))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 16)
                
                // Analytics entry card
                RoundedRectangle(cornerRadius: 20)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 72)
                    .padding(.horizontal, 24)
                
                Spacer().frame(height: 28)
                
                // Upcoming section title
                RoundedRectangle(cornerRadius: 4)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 150, height: 16)
                    .padding(.horizontal, 24)
                
                Spacer().frame(height: 12)
                
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        SubscriptionRowSkeleton()
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 28)
                
                // Most expensive title
                RoundedRectangle(cornerRadius: 4)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 180, height: 16)
                    .padding(.horizontal, 24)
                
                Spacer().frame(height: 12)
                
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        SubscriptionRowSkeleton()
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 24)
                
                // Bottom outlined button
                OutlinedButtonSkeleton()
                    .padding(.horizontal, 24)
                
                Spacer().frame(height: 32)
            }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Subscription List Skeleton
struct SubscriptionListSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Title
            RoundedRectangle(cornerRadius: 4)
                .baseSkeleton(colorScheme: colorScheme)
                .frame(width: 140, height: 22)
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            Spacer().frame(height: 16)
            
            // Summary card
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 4)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 110, height: 12)
                
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 160, height: 28)
                    
                    Spacer()
                    
                    Capsule()
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 90, height: 24)
                }
            }
            .padding(16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 20)
            
            // Tabs
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 40)
                RoundedRectangle(cornerRadius: 8)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 40)
                RoundedRectangle(cornerRadius: 8)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 40)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 16)
            
            // Search bar
            RoundedRectangle(cornerRadius: 12)
                .baseSkeleton(colorScheme: colorScheme)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 12)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(0..<8, id: \.self) { _ in
                        SubscriptionRowSkeleton()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Transaction List Skeleton
struct TransactionListSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<8) { _ in
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 140, height: 14)
                        RoundedRectangle(cornerRadius: 4)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 90, height: 10)
                    }
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 70, height: 14)
                }
                .padding(16)
                .background(Color.appSurface(for: colorScheme))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()
        DashboardSkeleton()
            .environment(\.colorScheme, .dark)
    }
}

// MARK: - Plan Card Skeleton (Premium Upgrade)
struct PlanCardSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<2) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 100, height: 18)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 150, height: 32)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appSurface(for: colorScheme))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Premium Action Button Skeleton
struct PremiumButtonSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .baseSkeleton(colorScheme: colorScheme)
            .frame(height: 45)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appOutline(for: colorScheme).opacity(0.5), lineWidth: 1)
            )
    }
}

// MARK: - Subscription Row Skeleton (matches SubscriptionCard layout)
struct SubscriptionRowSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 10)
                .baseSkeleton(colorScheme: colorScheme)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 140, height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 90, height: 12)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 72, height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 50, height: 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.appSurface(for: colorScheme).opacity(0.001))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
        )
    }
}

// MARK: - Outlined Button Skeleton (matches PremiumButton usage on Dashboard)
struct OutlinedButtonSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .baseSkeleton(colorScheme: colorScheme)
            .frame(height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
            )
    }
}

// MARK: - Subscription Details Skeleton
struct SubscriptionDetailsSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Icon
                Circle()
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 120, height: 120)
                    .padding(.top, 20)
                
                // Name
                RoundedRectangle(cornerRadius: 8)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 220, height: 32)
                
                // Price row
                RoundedRectangle(cornerRadius: 8)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 180, height: 40)
                
                // Summary card
                RoundedRectangle(cornerRadius: 16)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                    )
                
                // Grid blocks
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 80)
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 80)
                }
                
                // Action buttons row
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 52)
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 52)
                }
                
                // Primary CTA
                RoundedRectangle(cornerRadius: 12)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 45)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                    )
                
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Splash Skeleton (used during auth bootstrap)
struct SplashSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Circle()
                .baseSkeleton(colorScheme: colorScheme)
                .frame(width: 88, height: 88)
            
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 180, height: 18)
                
                RoundedRectangle(cornerRadius: 6)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 240, height: 14)
            }
            
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 72)
                RoundedRectangle(cornerRadius: 16)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 72)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
}

// MARK: - Auth / Password Reset Skeletons
struct ForgotPasswordSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Circle()
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 28, height: 28)
                Spacer()
            }
            .padding(16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    // Title
                    RoundedRectangle(cornerRadius: 6)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 220, height: 34)
                    
                    Spacer().frame(height: 12)
                    
                    // Description (2 lines)
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 280, height: 14)
                    Spacer().frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 230, height: 14)
                    
                    Spacer().frame(height: 32)
                    
                    // Email field
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.35), lineWidth: 1)
                        )
                    
                    Spacer().frame(height: 32)
                    
                    // Primary button
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.35), lineWidth: 1)
                        )
                    
                    Spacer().frame(height: 20)
                    
                    // Back to login link
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 120, height: 14)
                    
                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
}

struct VerificationCodeSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 28, height: 28)
                Spacer()
            }
            .padding(16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 240, height: 34)
                    
                    Spacer().frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 300, height: 14)
                    Spacer().frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 180, height: 14)
                    
                    Spacer().frame(height: 32)
                    
                    // Label
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 90, height: 12)
                    
                    Spacer().frame(height: 10)
                    
                    // Code field
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.35), lineWidth: 1)
                        )
                    
                    Spacer().frame(height: 32)
                    
                    // Button
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.35), lineWidth: 1)
                        )
                    
                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
}

struct ResetPasswordSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 28, height: 28)
                Spacer()
            }
            .padding(16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 240, height: 34)
                    
                    Spacer().frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 300, height: 14)
                    Spacer().frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 260, height: 14)
                    
                    Spacer().frame(height: 32)
                    
                    // New password field
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.35), lineWidth: 1)
                        )
                    
                    Spacer().frame(height: 20)
                    
                    // Confirm password field
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.35), lineWidth: 1)
                        )
                    
                    Spacer().frame(height: 32)
                    
                    // Primary button
                    RoundedRectangle(cornerRadius: 12)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.35), lineWidth: 1)
                        )
                    
                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
}

// MARK: - Search List Skeleton
struct SearchListSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectangle(cornerRadius: 4)
                .baseSkeleton(colorScheme: colorScheme)
                .frame(width: 120, height: 14)
            
            ForEach(0..<5) { _ in
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 10)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 36, height: 36)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 140, height: 16)
                        RoundedRectangle(cornerRadius: 4)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 90, height: 12)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.appSurface(for: colorScheme))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}
// MARK: - Analytics Skeleton
struct AnalyticsSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Kategori Seçici Skeleton
                HStack(spacing: 12) {
                    ForEach(0..<4) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 80, height: 36)
                    }
                }
                .padding(.horizontal, 24)
                
                // Özet Kartı Skeleton
                RoundedRectangle(cornerRadius: 24)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(height: 160)
                    .padding(.horizontal, 24)
                
                // Takvim Skeleton
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 120, height: 18)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(height: 300)
                }
                .padding(.horizontal, 24)
                
                // Liste Skeleton
                VStack(alignment: .leading, spacing: 16) {
                    RoundedRectangle(cornerRadius: 4)
                        .baseSkeleton(colorScheme: colorScheme)
                        .frame(width: 150, height: 18)
                    
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(height: 60)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 24)
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()
        AnalyticsSkeleton()
            .environment(\.colorScheme, .dark)
    }
}
