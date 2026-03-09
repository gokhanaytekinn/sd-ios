# 🏛️ SDIOS Proje Standartları ve Talimatları

Bu dosya, SDIOS projesinde çalışan tüm yapay zeka agent'ları için global kuralları tanımlar. Her agent bu kurallara istisnasız uymalıdır.

## 1. Mimari Prensipler (Clean Architecture)
- **Layered Structure:** Proje; View, ViewModel, Domain (Use Cases) ve Data (Repository/Network) katmanlarından oluşur.
- **Use Cases:** İş mantığı her zaman özel Use Case sınıflarında (örn. `LoginUseCase`) toplanmalıdır. ViewModel'lar repository'lere doğrudan erişmek yerine bu Use Case'leri kullanmalıdır.
- **Dependency Injection (DI):** Tüm bağımlılıklar protokoller üzerinden ve başlatıcı (initializer) aracılığıyla enjekte edilmelidir. Singleton (`shared`) kullanımı sadece varsayılan değerler için ve DI'ı destekleyecek şekilde (init gövdesi içinde) sınırlandırılmalıdır.

## 2. Swift 6 ve Concurrency
- **Strict Concurrency:** Kodlar Swift 6 standartlarına ve sıkı concurrency kurallarına uygun olmalıdır.
- **MainActor Isolation:** UI ile ilgili olan ViewModel'lar `@MainActor` ile işaretlenmelidir.
- **İzolasyon Hataları:** Başlatıcılarda "synchronous nonisolated context" hatalarını önlemek için Use Case örneklemeleri `init` gövdesi içinde yapılmalıdır.
- **Equatable:** Hata tipleri (`AppError`, `APIError`) için `Equatable` uyumluluğu, izolasyon çakışmalarını önlemek adına `nonisolated` olarak manuel uygulanmalıdır.

## 3. Kod Kalitesi ve Yazım Standartları
- **Yorum Satırları:** Kodun her bölümü (fonksiyonlar, değişkenler, karmaşık mantıklar) detaylı ve açıklayıcı **Türkçe** yorum satırları içermelidir. Amaç, kodun okunabilirliğini en üst düzeye çıkarmaktır.
- **Modular Networking:** API istekleri enum tabanlı (`APIEndpoint`) ve modüler bir yapıda (`ApiService`) yönetilmelidir.
- **Hata Yönetimi:** Hatalar `AppError` enum yapısı ile tip güvenli (type-safe) ve kullanıcı dostu mesajlarla yönetilmelidir.
- **Dil Politikası (Türkçe):** Agent, kullanıcıyla olan her türlü iletişiminde (sohbet, implementation planları, walkthrough raporları, görev özetleri vb.) her zaman **Türkçe** dilini kullanmalıdır. Kod içindeki yorumlar da Türkçe kalmalıdır.
- **Yükleme Standartları (Skeleton-Only):** Uygulama içerisinde kesinlikle **spinner (ProgressView)** kullanılmayacaktır. Tüm yükleme durumları (loading states) "Skeleton View" ile karşılanmalıdır. Ekran içi yüklemelerde ilgili alanın skeleton'u, ekranlar arası geçişlerde ise hedef ekranın skeleton yapısı gösterilmelidir.

## 4. Değişiklik Politikası
- **Tasarımsal ve İşlevsel Koruma:** Kullanıcı aksini belirtmedikçe, refaktör işlemleri sırasında uygulamanın mevcut tasarımı ve işlevselliği kesinlikle değiştirilmemelidir.
- **Dünya Standartları:** Yazılan kod her zaman profesyonel iOS geliştirme standartlarında (en üst kalite) olmalıdır.
