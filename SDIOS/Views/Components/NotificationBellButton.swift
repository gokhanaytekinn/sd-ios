import SwiftUI

/// Sağ üstte okunmamış sayı rozeti gösteren zil butonu.
/// Tüm ana sekmelerin başlığına eklenir; rozet sayısı `NotificationsViewModel`
/// üzerinden tüm sekmelerde senkron kalır.
struct NotificationBellButton: View {
    let unreadCount: Int
    let onTap: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                    .frame(width: 40, height: 40)
                    .background(Color.appSurface(for: colorScheme))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
                    )

                if unreadCount > 0 {
                    Text(badgeText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, unreadCount > 9 ? 4 : 0)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(Color.errorColor)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("notifications".localized())
    }

    private var badgeText: String {
        unreadCount > 9 ? "9+" : "\(unreadCount)"
    }
}
