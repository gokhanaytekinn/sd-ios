import SwiftUI
import Combine

@MainActor
class AddSubscriptionViewModel: ObservableObject {
    // MARK: - Published Properties (UI State)
    @Published var name = "" { didSet { nameError = nil } }    // Abonelik adı
    @Published var amount = ""                                 // Kullanıcının girdiği formatlı tutar
    @Published var icon: String? = nil                         // Seçilen ikon (string key)
    @Published var selectedCategory: String = "" { didSet { categoryError = nil } } // Kategori
    @Published var selectedBillingCycle: BillingCycle = .monthly { didSet { clearDateError() } } // Ödeme periyodu
    @Published var billingDay: Int = Calendar.current.component(.day, from: Date()) { didSet { clearDateError() } } // Ödeme günü
    @Published var billingMonth: Int? = nil { didSet { clearDateError() } } // Ödeme ayı (Yıllık paketler için)
    @Published var reminderEnabled = true { didSet { clearDateError() } } // Hatırlatıcı aktif mi?
    @Published var isFreeTrial = false // Ücretsiz deneme mi?
    @Published var jointEmails: [String] = []                  // Paylaşımlı abonelik için eklenen e-postalar
    @Published var participants: [InvitationParticipant] = []  // Mevcut katılımcılar (düzenleme modunda)
    @Published var emailInput: String = ""                     // Yeni e-posta girişi için geçici değişken
    @Published var isLoading = false                           // İşlem devam ediyor mu?
    @Published var error: String?                               // Genel hata mesajı
    @Published var responseMessage: String?
    
    // MARK: - Validation Errors (Alan Bazlı Hatalar)
    @Published var nameError: String?
    @Published var amountError: String?
    @Published var categoryError: String?
    @Published var dateError: String?
    
    // MARK: - Use Cases (İş Mantığı Katmanları)
    private let createSubscriptionUseCase: CreateSubscriptionUseCaseProtocol
    private let updateSubscriptionUseCase: UpdateSubscriptionUseCaseProtocol
    
    // MARK: - Private state
    private var editingSubscriptionId: String? // Düzenleme modundaysak abonelik ID'si
    
    /// Yardımcı model: Hızlı seçim butonları için veri yapısı
    struct QuickShortcut: Identifiable {
        let id = UUID()
        let name: String
        let icon: String?
        let category: String
        let defaultCost: Double?
        let color: Color
    }
    
    // MARK: - Static Data (Kategoriler ve Kısayollar)
    
    static let shortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Google", icon: "google", category: "category_software", defaultCost: nil, color: Color(hex: "4285F4")),
        QuickShortcut(name: "Microsoft 365", icon: "microsoft365", category: "category_software", defaultCost: nil, color: Color(hex: "AB7FE4")),
        QuickShortcut(name: "Notion", icon: "notion", category: "category_software", defaultCost: nil, color: Color(hex: "000000")),
        QuickShortcut(name: "Canva", icon: "canva", category: "category_software", defaultCost: nil, color: Color(hex: "2E7BE1")),
        QuickShortcut(name: "Figma", icon: "figma", category: "category_software", defaultCost: nil, color: Color(hex: "FF671B")),
        QuickShortcut(name: "GitHub", icon: "github", category: "category_software", defaultCost: nil, color: Color(hex: "181717")),
        QuickShortcut(name: "JetBrains", icon: "jetbrains", category: "category_software", defaultCost: nil, color: Color(hex: "000000")),
        QuickShortcut(name: "ChatGPT", icon: "chatgpt", category: "category_software", defaultCost: nil, color: Color(hex: "10A37F")),
        QuickShortcut(name: "YouTube", icon: "youtube", category: "category_streaming", defaultCost: nil, color: Color(hex: "FF0000")),
        QuickShortcut(name: "Spotify", icon: "spotify", category: "category_streaming", defaultCost: nil, color: Color(hex: "1DB954")),
        QuickShortcut(name: "Netflix", icon: "netflix", category: "category_streaming", defaultCost: nil, color: Color(hex: "E50914")),
        QuickShortcut(name: "Amazon Prime", icon: "amazon", category: "category_shopping", defaultCost: nil, color: Color(hex: "FF9900")),
        QuickShortcut(name: "Trendyol", icon: "trendyol", category: "category_shopping", defaultCost: nil, color: Color(hex: "F27A1A")),
        QuickShortcut(name: "Hepsiburada", icon: "hepsiburada", category: "category_shopping", defaultCost: nil, color: Color(hex: "FF6000")),
        QuickShortcut(name: "HBO Max", icon: "hbomax", category: "category_streaming", defaultCost: nil, color: Color(hex: "000000")),
        
        // Dizi & Film & Müzik
        QuickShortcut(name: "Disney+", icon: "disneyplus", category: "category_streaming", defaultCost: nil, color: Color(hex: "11AAB4")),
        QuickShortcut(name: "Apple TV+", icon: "appletvplus", category: "category_streaming", defaultCost: nil, color: Color(hex: "F4F4F4")),
        QuickShortcut(name: "Apple Music", icon: "applemusic", category: "category_streaming", defaultCost: nil, color: Color(hex: "FF1943")),

        QuickShortcut(name: "Xbox Game Pass", icon: "xboxgamepass", category: "category_gaming", defaultCost: nil, color: Color(hex: "0F7C11")),
        QuickShortcut(name: "PlayStation Plus", icon: "playstationplus", category: "category_gaming", defaultCost: nil, color: Color(hex: "02429C")),
        QuickShortcut(name: "Ubisoft+", icon: "ubisoftplus", category: "category_gaming", defaultCost: nil, color: Color(hex: "455A64")),
        QuickShortcut(name: "GeForce NOW", icon: "geforcenow", category: "category_gaming", defaultCost: nil, color: Color(hex: "89C049")),
        QuickShortcut(name: "Discord Nitro", icon: "discordnitro", category: "category_gaming", defaultCost: nil, color: Color(hex: "5165F6")),
        
        // Eğitim
        QuickShortcut(name: "Udemy", icon: "udemy", category: "category_education", defaultCost: nil, color: Color(hex: "A435F0")),
        QuickShortcut(name: "Coursera Plus", icon: "courseraplus", category: "category_education", defaultCost: nil, color: Color(hex: "0056D2")),
        QuickShortcut(name: "Duolingo Super", icon: nil, category: "category_education", defaultCost: nil, color: Color(hex: "58CC02")),
        QuickShortcut(name: "LinkedIn Learning", icon: nil, category: "category_education", defaultCost: nil, color: Color(hex: "0A66C2")),
        QuickShortcut(name: "Cambly", icon: nil, category: "category_education", defaultCost: nil, color: Color(hex: "22B8CF")),
        QuickShortcut(name: "Skillshare", icon: nil, category: "category_education", defaultCost: nil, color: Color(hex: "00FF84")),
    ]
    
    static let categories: [(key: String, label: String)] = [
        ("category_streaming", "category_streaming"),
        ("category_gaming", "category_gaming"),
        ("category_software", "category_software"),
        ("category_shopping", "category_shopping"),
        ("category_education", "category_education"),
        ("category_transport", "category_transport"),
        ("category_other", "category_other"),
    ]
    
    // MARK: - Initializer (Dependency Injection)
    init(
        createSubscriptionUseCase: CreateSubscriptionUseCaseProtocol? = nil,
        updateSubscriptionUseCase: UpdateSubscriptionUseCaseProtocol? = nil
    ) {
        self.createSubscriptionUseCase = createSubscriptionUseCase ?? CreateSubscriptionUseCase()
        self.updateSubscriptionUseCase = updateSubscriptionUseCase ?? UpdateSubscriptionUseCase()
    }
    
    // Düzenleme modunda olup olmadığımızı kontrol eden yardımcı mülk
    var isEditing: Bool {
        editingSubscriptionId != nil
    }
    
    // MARK: - Setup Logic (Veri Hazırlama)
    
    /// Mevcut bir aboneliği düzenleme ekranı için verileri doldurur.
    func setupForEdit(subscription: Subscription) {
        editingSubscriptionId = subscription.id
        name = subscription.name
        // Tutar bilgisini bankacılık formatına çevirerek input alanına yazarız.
        amount = CurrencyFormatter.formatAmountWithoutSymbol(subscription.cost)
        icon = subscription.icon
        selectedCategory = subscription.category ?? "category_other"
        selectedBillingCycle = subscription.billingCycle
        billingDay = subscription.billingDay ?? Calendar.current.component(.day, from: Date())
        billingMonth = subscription.billingMonth ?? Calendar.current.component(.month, from: Date())
        reminderEnabled = subscription.reminderEnabled
        isFreeTrial = subscription.isFreeTrial ?? false
        jointEmails = subscription.jointEmails ?? []
        participants = subscription.participants ?? []
    }
    
    // MARK: - Joint Email Logic (Ortak Üyelik Yönetimi)
    
    /// Listeye yeni bir katılımcı e-postası ekler.
    func addJointEmail() {
        let email = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else { return }
        
        // Temel e-posta validasyonu (RegEx)
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            error = "error_email_invalid".localized()
            return
        }
        
        // Mükerrer kayıt kontrolü
        if !jointEmails.contains(email) && !participants.contains(where: { $0.email == email }) {
            jointEmails.append(email)
            emailInput = "" // Giriş alanını temizle
        } else {
            // "Email already added" mesajı UI'da gösterilir.
            error = "Email already added"
        }
    }
    
    /// Katılımcı e-postasını listeden çıkarır.
    func removeJointEmail(_ email: String) {
        jointEmails.removeAll { $0 == email }
        participants.removeAll { $0.email == email }
    }
    
    // MARK: - Helpers (Yardımcı Araçlar)
    
    /// Hızlı seçim butonlarından (Google, Netflix vb.) gelen verileri forma uygular.
    func applyShortcut(_ shortcut: QuickShortcut) {
        name = shortcut.name
        icon = shortcut.icon
        selectedCategory = shortcut.category
        if let cost = shortcut.defaultCost {
            amount = CurrencyFormatter.formatAmountWithoutSymbol(cost)
        }
    }
    
    // MARK: - Banking Amount Formatting (Canlı Tutar Formatlama)
    
    /// Kullanıcı yazdıkça binlik ayraçlı (nokta) ve ondalıklı (virgül) formatı uygular.
    func handleAmountChange(_ newValue: String) {
        let formatted = formatBankingAmount(newText: newValue)
        
        // KRİTİK: SwiftUI'nın TextField iç durumunu zorla senkronize etmek için bir sonraki run loop'ta güncelliyoruz.
        // Bu sayede karakter karakter yazarken imleç takılması yaşanmaz.
        DispatchQueue.main.async {
            if formatted != self.amount {
                self.amount = formatted
            }
        }
        amountError = nil
    }
    
    /// Bankacılık tarzı formatlama mantığı.
    private func formatBankingAmount(newText: String) -> String {
        if newText.isEmpty { return "" }
        
        // 1. Gruplama ayraçlarını (noktaları) temizle
        let cleanedInput = newText.replacingOccurrences(of: ".", with: "")
        
        // 2. Sadece rakamları ve İLK virgül/noktayı kabul et
        var filtered = ""
        var hasComma = false
        
        for char in cleanedInput {
            if char == "," || char == "." {
                if !hasComma {
                    filtered.append(",")
                    hasComma = true
                }
            } else if char.isNumber {
                filtered.append(char)
            }
        }
        
        if filtered.isEmpty { return "" }
        
        // Tam sayı ve ondalık kısımlara ayır
        let parts = filtered.split(separator: ",", omittingEmptySubsequences: false)
        let integerPartString = String(parts.first ?? "")
        var decimalPartString = parts.count > 1 ? String(parts[1]) : ""
        
        // Ondalık kısmı 2 basamakla sınırla
        if decimalPartString.count > 2 {
            decimalPartString = String(decimalPartString.prefix(2))
        }
        
        // Tam sayı kısmını binlik ayraçla (nokta) formatla
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        var formattedInteger = ""
        if integerPartString.isEmpty {
            if parts.count > 1 {
                formattedInteger = "0"
            } else {
                return ""
            }
        } else {
            let integerNumber = Int64(integerPartString) ?? 0
            formattedInteger = formatter.string(from: NSNumber(value: integerNumber)) ?? integerPartString
        }
        
        if parts.count > 1 {
            return formattedInteger + "," + decimalPartString
        } else {
            return formattedInteger
        }
    }
    
    // MARK: - Save Logic (Kayıt İşlemi)
    
    /// Formu kaydeder (Yeni oluşturma veya Güncelleme).
    func save(currency: Int, onSuccess: @escaping () -> Void) {
        // Form validasyonu yap
        guard validate() else { return }
        
        // Bankacılık formatlı string'i sayısal değere (Double) çevir
        let costValue = CurrencyFormatter.parseBankingAmount(amount)
        
        Task {
            isLoading = true
            error = nil
            
            if let editId = editingSubscriptionId {
                // GÜNCELLEME MODU
                let request = SubscriptionUpdateRequest(
                    name: name,
                    icon: icon,
                    category: selectedCategory,
                    tier: nil,
                    amount: costValue,
                    currency: currency,
                    billingCycle: selectedBillingCycle.rawValue,
                    billingDay: billingDay,
                    billingMonth: selectedBillingCycle == .yearly ? billingMonth : nil,
                    reminderEnabled: reminderEnabled,
                    isFreeTrial: isFreeTrial,
                    jointEmails: jointEmails.isEmpty ? nil : jointEmails
                )
                let result = await updateSubscriptionUseCase.execute(id: editId, request: request)
                handleResult(result, onSuccess: onSuccess)
            } else {
                // YENİ EKLEME MODU
                let request = SubscriptionRequest(
                    name: name,
                    icon: icon,
                    category: selectedCategory,
                    tier: nil,
                    amount: costValue,
                    currency: currency,
                    billingCycle: selectedBillingCycle.rawValue,
                    billingDay: billingDay,
                    billingMonth: selectedBillingCycle == .yearly ? billingMonth : nil,
                    reminderEnabled: reminderEnabled,
                    isFreeTrial: isFreeTrial,
                    jointEmails: jointEmails.isEmpty ? nil : jointEmails
                )
                let result = await createSubscriptionUseCase.execute(request: request)
                handleResult(result, onSuccess: onSuccess)
            }
        }
    }
    
    /// API sonucunu yöneten yardımcı fonksiyon.
    private func handleResult<T>(_ result: Result<T, Error>, onSuccess: @escaping () -> Void) {
        isLoading = false
        switch result {
        case .success:
            onSuccess()
        case .failure(let err):
            error = err.localizedDescription
        }
    }
    
    // MARK: - Validation (Alan Kontrolleri)
    
    /// Formun geçerli olup olmadığını kontrol eder.
    func validate() -> Bool {
        // Hataları sıfırla
        nameError = nil
        amountError = nil
        categoryError = nil
        dateError = nil
        var isValid = true
        
        // İsim Kontrolü
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "error_name_required".localized()
            isValid = false
        }
        
        // Tutar Kontrolü
        if amount.trimmingCharacters(in: .whitespaces).isEmpty {
            amountError = "error_amount_required".localized()
            isValid = false
        } else {
            let value = CurrencyFormatter.parseBankingAmount(amount)
            if value <= 0 {
                amountError = "error_amount_invalid".localized()
                isValid = false
            }
        }
        
        // Kategori Kontrolü
        if selectedCategory.isEmpty {
            categoryError = "error_category_required".localized()
            isValid = false
        }
        
        // Tarih Kontrolü (Yıllık döngülerde ay seçimi zorunludur)
        if selectedBillingCycle == .yearly && billingMonth == nil {
            dateError = "error_date_required".localized()
            isValid = false
        }
        
        return isValid
    }
    
    // MARK: - Utility (Yardımcılar)
    
    private func clearDateError() {
        dateError = nil
    }
    
    func clearGeneralError() {
        error = nil
    }
    
    /// Formu başlangıç durumuna döndürür.
    func reset() {
        editingSubscriptionId = nil
        name = ""
        amount = ""
        icon = nil
        selectedCategory = ""
        selectedBillingCycle = .monthly
        billingDay = Calendar.current.component(.day, from: Date())
        billingMonth = nil
        reminderEnabled = true
        isFreeTrial = false
        jointEmails = []
        participants = []
        emailInput = ""
        error = nil
        responseMessage = nil
        nameError = nil
        amountError = nil
        categoryError = nil
    }
}
