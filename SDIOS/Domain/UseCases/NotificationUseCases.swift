import Foundation

// MARK: - Get Notifications Use Case
protocol GetNotificationsUseCaseProtocol {
    func execute(isRead: Bool?) async -> Result<[InAppNotificationResponse], Error>
}

class GetNotificationsUseCase: GetNotificationsUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol
    init(repository: NotificationRepositoryProtocol = NotificationRepository.shared) {
        self.repository = repository
    }
    func execute(isRead: Bool? = nil) async -> Result<[InAppNotificationResponse], Error> {
        return await repository.getNotifications(isRead: isRead)
    }
}

// MARK: - Get Unread Notification Count Use Case
protocol GetUnreadNotificationCountUseCaseProtocol {
    func execute() async -> Result<Int, Error>
}

class GetUnreadNotificationCountUseCase: GetUnreadNotificationCountUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol
    init(repository: NotificationRepositoryProtocol = NotificationRepository.shared) {
        self.repository = repository
    }
    func execute() async -> Result<Int, Error> {
        return await repository.getUnreadCount()
    }
}

// MARK: - Mark Notification Read Use Case
protocol MarkNotificationReadUseCaseProtocol {
    func execute(id: String) async -> Result<Void, Error>
}

class MarkNotificationReadUseCase: MarkNotificationReadUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol
    init(repository: NotificationRepositoryProtocol = NotificationRepository.shared) {
        self.repository = repository
    }
    func execute(id: String) async -> Result<Void, Error> {
        return await repository.markAsRead(id: id)
    }
}

// MARK: - Mark All Notifications Read Use Case
protocol MarkAllNotificationsReadUseCaseProtocol {
    func execute() async -> Result<Void, Error>
}

class MarkAllNotificationsReadUseCase: MarkAllNotificationsReadUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol
    init(repository: NotificationRepositoryProtocol = NotificationRepository.shared) {
        self.repository = repository
    }
    func execute() async -> Result<Void, Error> {
        return await repository.markAllAsRead()
    }
}

// MARK: - Delete Notification Use Case
protocol DeleteNotificationUseCaseProtocol {
    func execute(id: String) async -> Result<Void, Error>
}

class DeleteNotificationUseCase: DeleteNotificationUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol
    init(repository: NotificationRepositoryProtocol = NotificationRepository.shared) {
        self.repository = repository
    }
    func execute(id: String) async -> Result<Void, Error> {
        return await repository.deleteNotification(id: id)
    }
}
