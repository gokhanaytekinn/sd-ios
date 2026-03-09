import SwiftUI

/// Yükleme, Hata ve Boş veri durumlarını merkezi olarak yöneten bileşen.
/// Spinner yerine sadece Skeleton sistemini destekler.
struct StatefulView<Content: View, Skeleton: View>: View {
    let isLoading: Bool
    let error: String?
    let isEmpty: Bool
    let emptyMessage: String
    let emptyIcon: String
    let skeleton: Skeleton
    let content: Content
    let onRetry: (() -> Void)?
    
    @Environment(\.colorScheme) var colorScheme
    
    init(
        isLoading: Bool,
        error: String? = nil,
        isEmpty: Bool = false,
        emptyMessage: String = "Henüz veri bulunamadı.",
        emptyIcon: String = "tray.fill",
        onRetry: (() -> Void)? = nil,
        @ViewBuilder skeleton: () -> Skeleton,
        @ViewBuilder content: () -> Content
    ) {
        self.isLoading = isLoading
        self.error = error
        self.isEmpty = isEmpty
        self.emptyMessage = emptyMessage
        self.emptyIcon = emptyIcon
        self.onRetry = onRetry
        self.skeleton = skeleton()
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                skeleton
                    .transition(.opacity.animation(.easeInOut))
            } else if let error = error {
                ErrorStateView(message: error, onRetry: onRetry)
                    .transition(.opacity.animation(.easeInOut))
            } else if isEmpty {
                EmptyStateView(message: emptyMessage, icon: emptyIcon)
                    .transition(.opacity.animation(.easeInOut))
            } else {
                content
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
}

// MARK: - Boş Durum Bileşeni
struct EmptyStateView: View {
    let message: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme).opacity(0.5))
            
            Text(message)
                .font(.sdBody)
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Hata Durumu Bileşeni
struct ErrorStateView: View {
    let message: String
    let onRetry: (() -> Void)?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 48))
                .foregroundColor(.errorColor.opacity(0.8))
            
            Text(message)
                .font(.sdBody)
                .foregroundColor(Color.appOnBackground(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Tekrar Dene")
                        .font(.sdBodyBold)
                        .foregroundColor(.primaryBlue)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.appSurface(for: colorScheme))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryBlue, lineWidth: 1)
                        )
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
