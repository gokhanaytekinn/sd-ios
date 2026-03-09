import Foundation

/// Abonelik verilerini yöneten ve API ile iletişim kuran Repository.
class SubscriptionRepository: SubscriptionRepositoryProtocol {
    /// Singleton örneği - Protokol üzerinden erişilir.
    static let shared: SubscriptionRepositoryProtocol = SubscriptionRepository()
    
    /// API servis bağımlılığı.
    private let api: ApiServiceProtocol
    
    /// Bağımlılık Enjeksiyonu destekli başlatıcı.
    init(api: ApiServiceProtocol = ApiService.shared) {
        self.api = api
    }
    
    /// Tüm aktif abonelikleri getirir.
    func getSubscriptions() async -> Result<[Subscription], Error> {
        do {
            let responses = try await api.getSubscriptions()
            // API modellerini domain modellerine (Subscription) dönüştürür.
            return .success(responses.map { $0.toSubscription() })
        } catch {
            return .failure(error)
        }
    }
    
    /// Belirli bir aboneliğin detaylarını getirir.
    func getSubscription(id: String) async -> Result<Subscription, Error> {
        do {
            let response = try await api.getSubscription(id: id)
            return .success(response.toSubscription())
        } catch {
            return .failure(error)
        }
    }
    
    /// Yeni bir abonelik oluşturur.
    func createSubscription(_ request: SubscriptionRequest) async -> Result<Subscription, Error> {
        do {
            let response = try await api.createSubscription(request)
            return .success(response.toSubscription())
        } catch {
            return .failure(error)
        }
    }
    
    /// Mevcut bir aboneliği günceller.
    func updateSubscription(id: String, _ request: SubscriptionUpdateRequest) async -> Result<Subscription, Error> {
        do {
            let response = try await api.updateSubscription(id: id, request)
            return .success(response.toSubscription())
        } catch {
            return .failure(error)
        }
    }
    
    /// Bir aboneliği siler.
    func deleteSubscription(id: String) async -> Result<Void, Error> {
        do {
            try await api.deleteSubscription(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    /// Şüpheli (beklenmedik artış gösteren) abonelikleri getirir.
    func getSuspiciousSubscriptions() async -> Result<[Subscription], Error> {
        do {
            let responses = try await api.getSuspiciousSubscriptions()
            return .success(responses.map { $0.toSubscription() })
        } catch {
            return .failure(error)
        }
    }
    
    /// Bekleyen bir aboneliği onaylar.
    func approveSubscription(id: String) async -> Result<Subscription, Error> {
        do {
            let response = try await api.approveSubscription(id: id)
            return .success(response.toSubscription())
        } catch {
            return .failure(error)
        }
    }
    
    /// Bir aboneliği iptal eder.
    func cancelSubscription(id: String) async -> Result<Void, Error> {
        do {
            try await api.cancelSubscription(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    /// İptal edilmiş bir aboneliği tekrar aktif eder.
    func reactivateSubscription(id: String) async -> Result<Void, Error> {
        do {
            try await api.reactivateSubscription(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    /// Yaklaşan abonelik ödemelerini getirir.
    func getUpcomingSubscriptions() async -> Result<[Subscription], Error> {
        do {
            let responses = try await api.getUpcomingSubscriptions()
            return .success(responses.map { $0.toSubscription() })
        } catch {
            return .failure(error)
        }
    }
    
    /// İşlem (ödeme) geçmişini sayfalı olarak getirir.
    func getTransactions(page: Int = 0, size: Int = 20) async -> Result<PageTransactionResponse, Error> {
        do {
            let response = try await api.getTransactions(page: page, size: size)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    /// Bekleyen paylaşımlı abonelik davetlerini getirir.
    func getPendingInvitations() async -> Result<[SubscriptionInvitation], Error> {
        do {
            let invitations = try await api.getPendingInvitations()
            return .success(invitations)
        } catch {
            return .failure(error)
        }
    }
    
    /// Bir abonelik davetini kabul eder.
    func acceptInvitation(id: String) async -> Result<Void, Error> {
        do {
            try await api.acceptInvitation(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    /// Bir abonelik davetini reddeder.
    func rejectInvitation(id: String) async -> Result<Void, Error> {
        do {
            try await api.rejectInvitation(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    /// Paylaşımlı bir abonelikten bir katılımcıyı çıkarır.
    func removeParticipant(subscriptionId: String, email: String) async -> Result<Void, Error> {
        do {
            try await api.removeParticipant(subscriptionId: subscriptionId, email: email)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
