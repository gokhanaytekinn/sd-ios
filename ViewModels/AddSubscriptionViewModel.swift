import SwiftUI

@MainActor
class AddSubscriptionViewModel: ObservableObject {
    @Published var name = ""
    @Published var amount = ""
    @Published var icon: String? = nil
    @Published var selectedCategory: String = ""
    @Published var selectedBillingCycle: BillingCycle = .monthly
    @Published var billingDay: Int = Calendar.current.component(.day, from: Date())
    @Published var billingMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var reminderEnabled = true
    @Published var jointEmails: [String] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var responseMessage: String?
    
    @Published var nameError: String?
    @Published var amountError: String?
    @Published var categoryError: String?
    
    private let repository = SubscriptionRepository.shared
    private var editingSubscriptionId: String?
    
    struct QuickShortcut: Identifiable {
        let id = UUID()
        let name: String
        let icon: String?
        let category: String
        let defaultCost: Double?
    }
    
    static let shortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Netflix", icon: "netflix", category: "category_streaming", defaultCost: nil),
        QuickShortcut(name: "Spotify", icon: "spotify", category: "category_streaming", defaultCost: nil),
        QuickShortcut(name: "YouTube", icon: "youtube", category: "category_streaming", defaultCost: nil),
        QuickShortcut(name: "Amazon", icon: "amazon", category: "category_shopping", defaultCost: nil),
        QuickShortcut(name: "Google", icon: "google", category: "category_software", defaultCost: nil),
        QuickShortcut(name: "HBO Max", icon: "hbomax", category: "category_streaming", defaultCost: nil),
        QuickShortcut(name: "Cursor", icon: "cursor", category: "category_software", defaultCost: nil),
        QuickShortcut(name: "Claude", icon: "claude", category: "category_software", defaultCost: nil),
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
        var isValid = true
        
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = NSLocalizedString("error_name_required", comment: "")
            isValid = false
        }
        
        if amount.trimmingCharacters(in: .whitespaces).isEmpty {
            amountError = NSLocalizedString("error_amount_required", comment: "")
            isValid = false
        } else if Double(amount.replacingOccurrences(of: ",", with: ".")) == nil {
            amountError = NSLocalizedString("error_amount_invalid", comment: "")
            isValid = false
        }
        
        if selectedCategory.isEmpty {
            categoryError = NSLocalizedString("category", comment: "")
            isValid = false
        }
        
        return isValid
    }
    
    func reset() {
        editingSubscriptionId = nil
        name = ""
        amount = ""
        icon = nil
        selectedCategory = ""
        selectedBillingCycle = .monthly
        billingDay = Calendar.current.component(.day, from: Date())
        billingMonth = Calendar.current.component(.month, from: Date())
        reminderEnabled = true
        jointEmails = []
        error = nil
        responseMessage = nil
        nameError = nil
        amountError = nil
        categoryError = nil
    }
}
