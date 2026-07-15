import Foundation

/// Bildirim kutusu (bell/badge) verilerini yöneten repository protokolü.
protocol NotificationRepositoryProtocol {
    func getNotifications(isRead: Bool?) async -> Result<[InAppNotificationResponse], Error>
    func getUnreadCount() async -> Result<Int, Error>
    func markAsRead(id: String) async -> Result<Void, Error>
    func markAllAsRead() async -> Result<Void, Error>
    func deleteNotification(id: String) async -> Result<Void, Error>
}
