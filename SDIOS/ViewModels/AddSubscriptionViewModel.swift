import SwiftUI
import Combine

@MainActor
class AddSubscriptionViewModel: ObservableObject {
    @Published var name = "" { didSet { nameError = nil } }
    @Published var amount = "" { didSet { amountError = nil } }
    @Published var icon: String? = nil
    @Published var selectedCategory: String = "" { didSet { categoryError = nil } }
    @Published var selectedBillingCycle: BillingCycle = .monthly { didSet { clearDateError() } }
    @Published var billingDay: Int = Calendar.current.component(.day, from: Date()) { didSet { clearDateError() } }
    @Published var billingMonth: Int? = nil { didSet { clearDateError() } }
    @Published var reminderEnabled = true { didSet { clearDateError() } }
    @Published var jointEmails: [String] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var responseMessage: String?
    
    @Published var nameError: String?
    @Published var amountError: String?
    @Published var categoryError: String?
    @Published var dateError: String?
    
    private let repository = SubscriptionRepository.shared
    private var editingSubscriptionId: String?
    
    struct QuickShortcut: Identifiable {
        let id = UUID()
        let name: String
        let icon: String?
        let category: String
        let defaultCost: Double?
        let color: Color
    }
    
    static let shortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Google", icon: "google", category: "category_software", defaultCost: nil, color: Color(hex: "4285F4")),
        QuickShortcut(name: "Cursor", icon: "cursor", category: "category_software", defaultCost: nil, color: Color(hex: "1A1A1A")),
        QuickShortcut(name: "Claude", icon: "claude", category: "category_software", defaultCost: nil, color: Color(hex: "D97757")),
        QuickShortcut(name: "Netflix", icon: "netflix", category: "category_streaming", defaultCost: nil, color: Color(hex: "E50914")),
        QuickShortcut(name: "Spotify", icon: "spotify", category: "category_streaming", defaultCost: nil, color: Color(hex: "1DB954")),
        QuickShortcut(name: "YouTube", icon: "youtube", category: "category_streaming", defaultCost: nil, color: Color(hex: "FF0000")),
        QuickShortcut(name: "Amazon", icon: "amazon", category: "category_shopping", defaultCost: nil, color: Color(hex: "00A8E1")),
        QuickShortcut(name: "HBO Max", icon: "hbomax", category: "category_streaming", defaultCost: nil, color: Color(hex: "5A2E81")),
    ]
    
    static let categories: [(key: String, label: String)] = [
        ("category_streaming", "category_streaming"),
        ("category_gaming", "category_gaming"),
        ("category_software", "category_software"),
        ("category_shopping", "category_shopping"),
        ("category_entertainment", "category_entertainment"),
        ("category_music", "category_music"),
        ("category_sports", "category_sports"),
        ("category_education", "category_education"),
        ("category_cloud", "category_cloud"),
        ("category_ecommerce", "category_ecommerce"),
        ("category_news", "category_news"),
        ("category_transport", "category_transport"),
        ("category_finance", "category_finance"),
        ("category_technology", "category_technology"),
        ("category_other", "category_other"),
    ]
    
    var isEditing: Bool {
        editingSubscriptionId != nil
    }
    
    func setupForEdit(subscription: Subscription) {
        editingSubscriptionId = subscription.id
        name = subscription.name
        amount = CurrencyFormatter.formatAmountWithoutSymbol(subscription.cost)
        icon = subscription.icon
        selectedCategory = subscription.category ?? "category_other"
        selectedBillingCycle = subscription.billingCycle
        billingDay = subscription.billingDay ?? Calendar.current.component(.day, from: Date())
        billingMonth = subscription.billingMonth ?? Calendar.current.component(.month, from: Date())
        reminderEnabled = subscription.reminderEnabled
        jointEmails = subscription.jointEmails ?? []
    }
    
    func applyShortcut(_ shortcut: QuickShortcut) {
        name = shortcut.name
        icon = shortcut.icon
        selectedCategory = shortcut.category
        if let cost = shortcut.defaultCost {
            amount = CurrencyFormatter.formatAmountWithoutSymbol(cost)
        }
    }
    
    func save(currency: Int, onSuccess: @escaping () -> Void) {
        guard validate() else { return }
        
        let costValue = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        Task {
            isLoading = true
            error = nil
            
            if let editId = editingSubscriptionId {
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
                    jointEmails: jointEmails.isEmpty ? nil : jointEmails
                )
                let result = await repository.updateSubscription(id: editId, request)
                switch result {
                case .success(let sub):
                    isLoading = false
                    responseMessage = sub.responseMessage
                    onSuccess()
                case .failure(let err):
                    isLoading = false
                    error = err.localizedDescription
                }
            } else {
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
                    jointEmails: jointEmails.isEmpty ? nil : jointEmails
                )
                let result = await repository.createSubscription(request)
                switch result {
                case .success(let sub):
                    isLoading = false
                    responseMessage = sub.responseMessage
                    onSuccess()
                case .failure(let err):
                    isLoading = false
                    error = err.localizedDescription
                }
            }
        }
    }
    
    func validate() -> Bool {
        nameError = nil
        amountError = nil
        categoryError = nil
        dateError = nil
        var isValid = true
        
        // Name Validation (@NotBlank)
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "error_name_required".localized()
            isValid = false
        }
        
        // Amount Validation (@NotNull & @DecimalMin(0.0))
        let cleanAmount = amount.replacingOccurrences(of: ",", with: ".")
        if amount.trimmingCharacters(in: .whitespaces).isEmpty {
            amountError = "error_amount_required".localized()
            isValid = false
        } else if let value = Double(cleanAmount) {
            if value <= 0 {
                amountError = "error_amount_invalid".localized()
                isValid = false
            }
        } else {
            amountError = "error_amount_invalid".localized()
            isValid = false
        }
        
        // Category Validation (@NotBlank)
        if selectedCategory.isEmpty {
            categoryError = "category".localized()
            isValid = false
        }
        
        // Date Validation (Billing Day/Month @NotNull)
        if selectedBillingCycle == .yearly && billingMonth == nil {
            dateError = "error_date_required".localized()
            isValid = false
        }
        
        return isValid
    }
    
    private func clearDateError() {
        dateError = nil
    }
    
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
        jointEmails = []
        error = nil
        responseMessage = nil
        nameError = nil
        amountError = nil
        categoryError = nil
    }
}
