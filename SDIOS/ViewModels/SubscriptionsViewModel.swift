import SwiftUI
import Combine

@MainActor
class SubscriptionsViewModel: ObservableObject {
    // MARK: - Published Properties (UI State)
    @Published var allSubscriptions: [Subscription] = []     // Tüm abonelik havuzu
    @Published var invitations: [SubscriptionInvitation] = [] // Bekleyen paylaşımlı abonelik davetleri
    @Published var stats: SubscriptionStats = SubscriptionStats() // İstatistik özetleri
    @Published var isLoading = true
    @Published var error: String?
    @Published var showingLimitAlert = false // Ücretsiz plan sınırı aşımı uyarısı kontrolü
    
    // MARK: - Use Cases (İş Mantığı Katmanları)
    private let getSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol
    private let getInvitationsUseCase: GetPendingInvitationsUseCaseProtocol
    private let acceptInvitationUseCase: AcceptInvitationUseCaseProtocol
    private let rejectInvitationUseCase: RejectInvitationUseCaseProtocol
    private let deleteSubscriptionUseCase: DeleteSubscriptionUseCaseProtocol
    private let cancelSubscriptionUseCase: CancelSubscriptionUseCaseProtocol
    private let reactivateSubscriptionUseCase: ReactivateSubscriptionUseCaseProtocol
    
    // MARK: - Global Context
    var authViewModel: AuthViewModel?
    
    // MARK: - Initializer (Dependency Injection)
    init(
        getSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol? = nil,
        getInvitationsUseCase: GetPendingInvitationsUseCaseProtocol? = nil,
        acceptInvitationUseCase: AcceptInvitationUseCaseProtocol? = nil,
        rejectInvitationUseCase: RejectInvitationUseCaseProtocol? = nil,
        deleteSubscriptionUseCase: DeleteSubscriptionUseCaseProtocol? = nil,
        cancelSubscriptionUseCase: CancelSubscriptionUseCaseProtocol? = nil,
        reactivateSubscriptionUseCase: ReactivateSubscriptionUseCaseProtocol? = nil
    ) {
        self.getSubscriptionsUseCase = getSubscriptionsUseCase ?? GetSubscriptionsUseCase()
        self.getInvitationsUseCase = getInvitationsUseCase ?? GetPendingInvitationsUseCase()
        self.acceptInvitationUseCase = acceptInvitationUseCase ?? AcceptInvitationUseCase()
        self.rejectInvitationUseCase = rejectInvitationUseCase ?? RejectInvitationUseCase()
        self.deleteSubscriptionUseCase = deleteSubscriptionUseCase ?? DeleteSubscriptionUseCase()
        self.cancelSubscriptionUseCase = cancelSubscriptionUseCase ?? CancelSubscriptionUseCase()
        self.reactivateSubscriptionUseCase = reactivateSubscriptionUseCase ?? ReactivateSubscriptionUseCase()
    }
    
    // MARK: - Computed Properties (Filtrelenmiş Listeler)
    
    /// Aktif (ödeme süreci devam eden) abonelikler
    var activeSubscriptions: [Subscription] {
        allSubscriptions.filter { $0.status == 1 }
    }
    
    /// Şüpheli veya onay bekleyen abonelikler
    var suspiciousSubscriptions: [Subscription] {
        allSubscriptions.filter { $0.isSuspicious || $0.status == 4 }
    }
    
    /// İptal edilmiş ve ödeme döngüsü bitmiş abonelikler
    var cancelledSubscriptions: [Subscription] {
        allSubscriptions.filter { $0.status == 3 }
    }
    
    // MARK: - Data Loading
    
    /// Abonelikleri ve davetleri sunucudan tazeleyen fonksiyon.
    func loadSubscriptions() {
        Task {
            isLoading = true
            error = nil
            
            // Paralel veri çekimi
            async let subsResult = getSubscriptionsUseCase.execute()
            async let invitationsResult = getInvitationsUseCase.execute()
            
            let (subs, inv) = await (subsResult, invitationsResult)
            
            switch subs {
            case .success(let list):
                allSubscriptions = list
                stats = SubscriptionStats.calculate(from: list)
                // Global abonelik sayısını güncelle
                authViewModel?.subscriptionCount = list.count
                
                // Widget verilerini güncelle
                WidgetDataManager.shared.saveSnapshot(list)
            case .failure(let err):
                error = err.localizedDescription
            }
            
            switch inv {
            case .success(let list):
                invitations = list
            case .failure:
                break
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Actions (Kullanıcı Etkileşimleri)
    
    /// Paylaşımlı bir abonelik davetini kabul eder.
    func acceptInvitation(id: String) {
        // Limit kontrolü (Ücretsiz kullanıcılar için)
        if authViewModel?.isSubscriptionLimitReached == true {
            showingLimitAlert = true
            return
        }
        
        Task {
            let result = await acceptInvitationUseCase.execute(id: id)
            if case .success = result {
                // Listeden kaldır ve verileri tazele
                invitations.removeAll { $0.id == id }
                loadSubscriptions()
            } else if case .failure(let err) = result {
                error = err.localizedDescription
            }
        }
    }
    
    /// Daveti reddeder.
    func rejectInvitation(id: String) {
        Task {
            let result = await rejectInvitationUseCase.execute(id: id)
            if case .success = result {
                invitations.removeAll { $0.id == id }
            }
        }
    }
    
    /// Bir aboneliği tamamen siler.
    func deleteSubscription(id: String) {
        Task {
            let result = await deleteSubscriptionUseCase.execute(id: id)
            if case .success = result {
                // Yerel listeden silerek anlık geri bildirim ver
                allSubscriptions.removeAll { $0.id == id }
            }
        }
    }
    
    /// Gelecek ödemeleri durdurmak için iptal eder.
    func cancelSubscription(id: String) {
        Task {
            let result = await cancelSubscriptionUseCase.execute(id: id)
            if case .success = result {
                // Durum değiştiği için listeyi tazele
                loadSubscriptions()
            }
        }
    }
    
    /// İptal edilmiş bir aboneliği geri döndürür.
    func reactivateSubscription(id: String) {
        Task {
            let result = await reactivateSubscriptionUseCase.execute(id: id)
            if case .success = result {
                loadSubscriptions()
            }
        }
    }
}
