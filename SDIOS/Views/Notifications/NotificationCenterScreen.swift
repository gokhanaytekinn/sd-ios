import SwiftUI

/// Push bildirimlerinin kalıcı geçmişini listeleyen ekran.
/// Zil ikonuna dokunulduğunda tüm ana sekmelerden buraya gelinir.
struct NotificationCenterScreen: View {
    @EnvironmentObject var notificationsViewModel: NotificationsViewModel
    let onBack: () -> Void
    let onNavigate: (String) -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            topBar

            StatefulView(
                isLoading: notificationsViewModel.isLoading && notificationsViewModel.notifications.isEmpty,
                error: notificationsViewModel.error,
                isEmpty: notificationsViewModel.notifications.isEmpty,
                emptyMessage: "no_notifications".localized(),
                emptyIcon: "bell.slash",
                onRetry: { notificationsViewModel.loadNotifications() },
                skeleton: { NotificationListSkeleton() }
            ) {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(notificationsViewModel.notifications) { notification in
                            NotificationRow(notification: notification)
                                .onTapGesture {
                                    notificationsViewModel.markAsRead(notification)
                                    if let navigateTo = notification.data?["navigate_to"] {
                                        onNavigate(navigateTo)
                                    }
                                }
                                .swipeToDelete {
                                    notificationsViewModel.delete(notification)
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear {
            notificationsViewModel.loadNotifications()
        }
    }

    // MARK: - Üst Bar
    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                    .frame(width: 44, height: 44)
                    .background(Color.appSurface(for: colorScheme))
                    .clipShape(Circle())
            }
            Spacer()
            Text("notifications".localized())
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
            Spacer()
            if notificationsViewModel.unreadCount > 0 {
                Button(action: { notificationsViewModel.markAllAsRead() }) {
                    Text("mark_all_read".localized())
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                        .multilineTextAlignment(.trailing)
                }
                .frame(width: 44, height: 44)
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Bildirim Satırı
private struct NotificationRow: View {
    let notification: InAppNotificationResponse

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill((notification.isRead ? Color.appOutline(for: colorScheme) : Color.primaryBlue).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "bell.fill")
                    .font(.system(size: 16))
                    .foregroundColor(notification.isRead ? Color.appOnSurfaceVariant(for: colorScheme) : .primaryBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title ?? "")
                    .font(notification.isRead ? .sdBodyMedium : .sdBodyBold)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))

                if let body = notification.body, !body.isEmpty {
                    Text(body)
                        .font(.sdCaption)
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                        .lineLimit(3)
                }

                Text(DateUtils.formatRelative(isoString: notification.createdAt))
                    .font(.sdSmall)
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(16)
        // Okunmamış bildirimler hafif bir yüzey rengiyle vurgulanır.
        .background(notification.isRead ? Color.clear : Color.primaryBlue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Kaydırarak Silme
private struct SwipeToDeleteModifier: ViewModifier {
    let onDelete: () -> Void
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -80 {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = -500
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDelete()
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
    }
}

private extension View {
    func swipeToDelete(onDelete: @escaping () -> Void) -> some View {
        modifier(SwipeToDeleteModifier(onDelete: onDelete))
    }
}
