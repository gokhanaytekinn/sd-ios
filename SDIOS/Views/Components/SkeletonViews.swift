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
        VStack(spacing: 24) {
            // Özet Kartı Skeleton
            RoundedRectangle(cornerRadius: 24)
                .baseSkeleton(colorScheme: colorScheme)
                .frame(height: 180)
            
            VStack(alignment: .leading, spacing: 16) {
                // Başlık
                RoundedRectangle(cornerRadius: 4)
                    .baseSkeleton(colorScheme: colorScheme)
                    .frame(width: 150, height: 20)
                
                // Yaklaşan Abonelikler Listesi
                ForEach(0..<3) { _ in
                    HStack(spacing: 16) {
                        Circle()
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .baseSkeleton(colorScheme: colorScheme)
                                .frame(width: 100, height: 14)
                            RoundedRectangle(cornerRadius: 4)
                                .baseSkeleton(colorScheme: colorScheme)
                                .frame(width: 60, height: 10)
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 50, height: 14)
                    }
                    .padding(16)
                    .background(Color.appSurface(for: colorScheme))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.appOutline(for: colorScheme).opacity(0.5), lineWidth: 1)
                    )
                }
            }
        }
        .padding(24)
    }
}

// MARK: - Subscription List Skeleton
struct SubscriptionListSkeleton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<6) { _ in
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 10)
                            .baseSkeleton(colorScheme: colorScheme)
                            .frame(width: 36, height: 36)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 4)
                                .baseSkeleton(colorScheme: colorScheme)
                                .frame(width: 120, height: 16)
                            RoundedRectangle(cornerRadius: 4)
                                .baseSkeleton(colorScheme: colorScheme)
                                .frame(width: 80, height: 12)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            RoundedRectangle(cornerRadius: 4)
                                .baseSkeleton(colorScheme: colorScheme)
                                .frame(width: 60, height: 16)
                            RoundedRectangle(cornerRadius: 4)
                                .baseSkeleton(colorScheme: colorScheme)
                                .frame(width: 40, height: 12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.appSurface(for: colorScheme))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appOutline(for: colorScheme).opacity(0.5), lineWidth: 1)
                    )
                }
            }
            .padding(20)
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
