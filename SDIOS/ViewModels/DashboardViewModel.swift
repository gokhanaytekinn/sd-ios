import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties (UI State)
    @Published var subscriptions: [Subscription] = []
    @Published var upcomingSubscriptions: [Subscription] = []
    @Published var stats: SubscriptionStats = SubscriptionStats()
    @Published var isLoading = true
    @Published var error: String?
    
    var freeTrialSubscriptions: [Subscription] {
        subscriptions
            .filter { $0.isFreeTrial == true }
            .sorted {
                let d1 = $0.getNextRenewalDate() ?? .distantFuture
                let d2 = $1.getNextRenewalDate() ?? .distantFuture
                return d1 < d2
            }
    }
    
    // MARK: - Use Cases (İş Mantığı Katmanları)
    // ViewModel artık repository ile değil, özelleşmiş iş mantığı sınıflarıyla konuşur.
    private let getSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol
    private let getUpcomingUseCase: GetUpcomingSubscriptionsUseCaseProtocol
    
    // MARK: - Core References
    // AuthViewModel, global uygulama durumu (örneğin giriş yapmış kullanıcı) için referans tutulur.
    var authViewModel: AuthViewModel?
    
    /// ViewModel Başlatıcısı (Dependency Injection - Bağımlılık Enjeksiyonu)
    /// Bu yapı sayesinde ViewModel'ı gerçek veriler veya test verileriyle kolayca başlatabiliriz.
    init(
        getSubscriptionsUseCase: GetSubscriptionsUseCaseProtocol? = nil,
        getUpcomingUseCase: GetUpcomingSubscriptionsUseCaseProtocol? = nil
    ) {
        self.getSubscriptionsUseCase = getSubscriptionsUseCase ?? GetSubscriptionsUseCase()
        self.getUpcomingUseCase = getUpcomingUseCase ?? GetUpcomingSubscriptionsUseCase()
    }
    
    /// Dashboard verilerini yükleyen ana fonksiyon.
    /// Hem tüm abonelikleri hem de yakında ödemesi olanları asenkron olarak çeker.
    func loadDashboard() {
        Task {
            isLoading = true
            error = nil
            
            // Performans için iki isteği paralel (concurrent) olarak başlatıyoruz.
            async let subsResult = getSubscriptionsUseCase.execute()
            async let upcomingResult = getUpcomingUseCase.execute()
            
            // Her iki sonucun da tamamlanmasını bekliyoruz.
            let (subs, upcoming) = await (subsResult, upcomingResult)
            
            // 1. Tüm aboneliklerin işlenmesi
            switch subs {
            case .success(let list):
                // Mevcut para birimini al (UserDefaults'tan)
                let currency = UserDefaults.standard.integer(forKey: "selectedCurrency")
                
                // Sadece aktif abonelikleri maliyete göre azalan sırada filtrele
                subscriptions = list.filter { $0.isActive }.sorted { $0.cost > $1.cost }
                
                // İstatistikleri hesapla (Toplam tutar vb.)
                stats = SubscriptionStats.calculate(from: list, targetCurrency: currency == 0 ? 1 : currency)
                
                // Toplam abonelik sayısını AuthViewModel (global state) ile senkronize et
                authViewModel?.subscriptionCount = list.count
                
                // Widget verilerini güncelle
                WidgetDataManager.shared.saveSnapshot(list)
                
            case .failure(let err):
                // Hata oluşursa kullanıcıya göstermek üzere 'error' değişkenine aktar
                error = err.localizedDescription
            }
            
            // 2. Yaklaşan ödemelerin (Upcoming) işlenmesi
            switch upcoming {
            case .success(let list):
                // Bugünden itibaren sonraki 10 günü hedefliyoruz
                let tenDaysFromNow = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
                
                upcomingSubscriptions = list.filter { sub in
                    guard let nextDate = sub.getNextRenewalDate() else { return false }
                    return nextDate <= tenDaysFromNow // 10 gün içinde olanlar
                }.sorted { 
                    // Tarihe göre artan sırada sırala (En yakın olan en üstte)
                    guard let d1 = $0.getNextRenewalDate(), let d2 = $1.getNextRenewalDate() else { return false }
                    return d1 < d2
                }
            case .failure:
                // Yaklaşanlar yüklenemezse sessizce devam ediyoruz (Dashboard'un ana işlevi değil)
                break
            }
            
            isLoading = false
        }
    }
}
