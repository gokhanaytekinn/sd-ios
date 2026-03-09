import Foundation

// MARK: - Get Subscriptions Use Case
protocol GetSubscriptionsUseCaseProtocol {
    func execute() async -> Result<[Subscription], Error>
}

class GetSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute() async -> Result<[Subscription], Error> {
        return await repository.getSubscriptions()
    }
}

// MARK: - Create Subscription Use Case
protocol CreateSubscriptionUseCaseProtocol {
    func execute(request: SubscriptionRequest) async -> Result<Subscription, Error>
}

class CreateSubscriptionUseCase: CreateSubscriptionUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute(request: SubscriptionRequest) async -> Result<Subscription, Error> {
        return await repository.createSubscription(request)
    }
}

// MARK: - Update Subscription Use Case
protocol UpdateSubscriptionUseCaseProtocol {
    func execute(id: String, request: SubscriptionUpdateRequest) async -> Result<Subscription, Error>
}

class UpdateSubscriptionUseCase: UpdateSubscriptionUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute(id: String, request: SubscriptionUpdateRequest) async -> Result<Subscription, Error> {
        return await repository.updateSubscription(id: id, request)
    }
}

// MARK: - Delete Subscription Use Case
protocol DeleteSubscriptionUseCaseProtocol {
    func execute(id: String) async -> Result<Void, Error>
}

class DeleteSubscriptionUseCase: DeleteSubscriptionUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute(id: String) async -> Result<Void, Error> {
        return await repository.deleteSubscription(id: id)
    }
}

// MARK: - Get Upcoming Subscriptions Use Case
protocol GetUpcomingSubscriptionsUseCaseProtocol {
    func execute() async -> Result<[Subscription], Error>
}

class GetUpcomingSubscriptionsUseCase: GetUpcomingSubscriptionsUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute() async -> Result<[Subscription], Error> {
        return await repository.getUpcomingSubscriptions()
    }
}

// MARK: - Get Pending Invitations Use Case
protocol GetPendingInvitationsUseCaseProtocol {
    func execute() async -> Result<[SubscriptionInvitation], Error>
}

class GetPendingInvitationsUseCase: GetPendingInvitationsUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute() async -> Result<[SubscriptionInvitation], Error> {
        return await repository.getPendingInvitations()
    }
}

// MARK: - Accept Invitation Use Case
protocol AcceptInvitationUseCaseProtocol {
    func execute(id: String) async -> Result<Void, Error>
}

class AcceptInvitationUseCase: AcceptInvitationUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute(id: String) async -> Result<Void, Error> {
        return await repository.acceptInvitation(id: id)
    }
}

// MARK: - Reject Invitation Use Case
protocol RejectInvitationUseCaseProtocol {
    func execute(id: String) async -> Result<Void, Error>
}

class RejectInvitationUseCase: RejectInvitationUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute(id: String) async -> Result<Void, Error> {
        return await repository.rejectInvitation(id: id)
    }
}

// MARK: - Cancel Subscription Use Case
protocol CancelSubscriptionUseCaseProtocol {
    func execute(id: String) async -> Result<Void, Error>
}

class CancelSubscriptionUseCase: CancelSubscriptionUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute(id: String) async -> Result<Void, Error> {
        return await repository.cancelSubscription(id: id)
    }
}

// MARK: - Reactivate Subscription Use Case
protocol ReactivateSubscriptionUseCaseProtocol {
    func execute(id: String) async -> Result<Void, Error>
}

class ReactivateSubscriptionUseCase: ReactivateSubscriptionUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute(id: String) async -> Result<Void, Error> {
        return await repository.reactivateSubscription(id: id)
    }
}

// MARK: - Get Transactions Use Case
protocol GetTransactionsUseCaseProtocol {
    func execute(page: Int, size: Int) async -> Result<PageTransactionResponse, Error>
}

class GetTransactionsUseCase: GetTransactionsUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository.shared) {
        self.repository = repository
    }
    func execute(page: Int, size: Int) async -> Result<PageTransactionResponse, Error> {
        return await repository.getTransactions(page: page, size: size)
    }
}
