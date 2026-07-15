import Foundation

/// Bildirim kutusu verilerini API ile iletişim kurarak yöneten Repository.
class NotificationRepository: NotificationRepositoryProtocol {
    /// Singleton örneği - Protokol üzerinden erişilir.
    static let shared: NotificationRepositoryProtocol = NotificationRepository()

    /// API servis bağımlılığı.
    private let api: ApiServiceProtocol

    /// Bağımlılık Enjeksiyonu destekli başlatıcı.
    init(api: ApiServiceProtocol = ApiService.shared) {
        self.api = api
    }

    /// Kullanıcının bildirimlerini (opsiyonel olarak okunma durumuna göre filtreli) getirir.
    func getNotifications(isRead: Bool?) async -> Result<[InAppNotificationResponse], Error> {
        do {
            let notifications = try await api.getNotifications(isRead: isRead)
            return .success(notifications)
        } catch {
            return .failure(error)
        }
    }

    /// Zil rozetinde gösterilecek okunmamış bildirim sayısını getirir.
    func getUnreadCount() async -> Result<Int, Error> {
        do {
            let count = try await api.getUnreadNotificationCount()
            return .success(count)
        } catch {
            return .failure(error)
        }
    }

    /// Tek bir bildirimi okundu olarak işaretler.
    func markAsRead(id: String) async -> Result<Void, Error> {
        do {
            try await api.markNotificationRead(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    /// Kullanıcının tüm bildirimlerini okundu olarak işaretler.
    func markAllAsRead() async -> Result<Void, Error> {
        do {
            try await api.markAllNotificationsRead()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    /// Bir bildirimi kalıcı olarak siler.
    func deleteNotification(id: String) async -> Result<Void, Error> {
        do {
            try await api.deleteNotification(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
