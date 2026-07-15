import Foundation
import Combine
import UserNotifications

/// Bildirim kutusunu (zil + rozet) yöneten paylaşılan ViewModel.
/// `SDiOSApp` içinde tek bir örnek olarak tutulur ve tüm ana sekmelere
/// `environmentObject` ile aktarılır, böylece rozet sayısı her yerde senkron kalır.
@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [InAppNotificationResponse] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Use Cases (İş Mantığı Katmanları)
    private let getNotificationsUseCase: GetNotificationsUseCaseProtocol
    private let getUnreadCountUseCase: GetUnreadNotificationCountUseCaseProtocol
    private let markAsReadUseCase: MarkNotificationReadUseCaseProtocol
    private let markAllAsReadUseCase: MarkAllNotificationsReadUseCaseProtocol
    private let deleteNotificationUseCase: DeleteNotificationUseCaseProtocol

    init(
        getNotificationsUseCase: GetNotificationsUseCaseProtocol? = nil,
        getUnreadCountUseCase: GetUnreadNotificationCountUseCaseProtocol? = nil,
        markAsReadUseCase: MarkNotificationReadUseCaseProtocol? = nil,
        markAllAsReadUseCase: MarkAllNotificationsReadUseCaseProtocol? = nil,
        deleteNotificationUseCase: DeleteNotificationUseCaseProtocol? = nil
    ) {
        self.getNotificationsUseCase = getNotificationsUseCase ?? GetNotificationsUseCase()
        self.getUnreadCountUseCase = getUnreadCountUseCase ?? GetUnreadNotificationCountUseCase()
        self.markAsReadUseCase = markAsReadUseCase ?? MarkNotificationReadUseCase()
        self.markAllAsReadUseCase = markAllAsReadUseCase ?? MarkAllNotificationsReadUseCase()
        self.deleteNotificationUseCase = deleteNotificationUseCase ?? DeleteNotificationUseCase()
    }

    /// Sadece rozet sayısını yeniler. Zil ikonu her sekmede göründüğü için hafif tutulur.
    func refreshUnreadCount() {
        Task {
            let result = await getUnreadCountUseCase.execute()
            if case .success(let count) = result {
                unreadCount = count
                await syncAppIconBadge()
            }
            // Rozet sayımı sessizce başarısız olabilir; UI'ı bozmaya değmez.
        }
    }

    /// Bildirim listesi ekranı açıldığında tam listeyi çeker.
    func loadNotifications() {
        Task {
            isLoading = true
            error = nil

            let result = await getNotificationsUseCase.execute(isRead: nil)
            switch result {
            case .success(let list):
                notifications = list
                unreadCount = list.filter { !$0.isRead }.count
                await syncAppIconBadge()
            case .failure(let err):
                error = err.localizedDescription
            }

            isLoading = false
        }
    }

    func markAsRead(_ notification: InAppNotificationResponse) {
        guard !notification.isRead else { return }
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }

        // Optimistic update: sunucu cevabını beklemeden UI'ı güncelle.
        notifications[index] = notification.markingAsRead()
        unreadCount = max(0, unreadCount - 1)

        Task {
            _ = await markAsReadUseCase.execute(id: notification.id)
            await syncAppIconBadge()
        }
    }

    func markAllAsRead() {
        guard unreadCount > 0 else { return }
        notifications = notifications.map { $0.markingAsRead() }
        unreadCount = 0

        Task {
            _ = await markAllAsReadUseCase.execute()
            await syncAppIconBadge()
        }
    }

    func delete(_ notification: InAppNotificationResponse) {
        notifications.removeAll { $0.id == notification.id }
        if !notification.isRead {
            unreadCount = max(0, unreadCount - 1)
        }

        Task {
            _ = await deleteNotificationUseCase.execute(id: notification.id)
            await syncAppIconBadge()
        }
    }

    /// Uygulama simgesi üzerindeki rozeti okunmamış sayı ile senkronlar.
    private func syncAppIconBadge() async {
        try? await UNUserNotificationCenter.current().setBadgeCount(unreadCount)
    }
}

private extension InAppNotificationResponse {
    /// Değişmez (immutable) modelde tek alanı değiştirilmiş bir kopya döner.
    func markingAsRead() -> InAppNotificationResponse {
        InAppNotificationResponse(
            id: id,
            title: title,
            body: body,
            data: data,
            isRead: true,
            createdAt: createdAt
        )
    }
}
