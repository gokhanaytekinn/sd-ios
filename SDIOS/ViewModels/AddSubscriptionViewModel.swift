import SwiftUI
import Combine

@MainActor
class AddSubscriptionViewModel: ObservableObject {
    @Published var name = "" { didSet { nameError = nil } }
    @Published var amount = ""
    @Published var icon: String? = nil
    @Published var selectedCategory: String = "" { didSet { categoryError = nil } }
    @Published var selectedBillingCycle: BillingCycle = .monthly { didSet { clearDateError() } }
    @Published var billingDay: Int = Calendar.current.component(.day, from: Date()) { didSet { clearDateError() } }
    @Published var billingMonth: Int? = nil { didSet { clearDateError() } }
    @Published var reminderEnabled = true { didSet { clearDateError() } }
    @Published var jointEmails: [String] = []
    @Published var participants: [InvitationParticipant] = []
    @Published var emailInput: String = ""
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
        QuickShortcut(name: "YouTube", icon: "youtube", category: "category_streaming", defaultCost: nil, color: Color(hex: "FF0000")),
        QuickShortcut(name: "Spotify", icon: "spotify", category: "category_streaming", defaultCost: nil, color: Color(hex: "1DB954")),
        QuickShortcut(name: "Netflix", icon: "netflix", category: "category_streaming", defaultCost: nil, color: Color(hex: "E50914")),
        QuickShortcut(name: "Amazon", icon: "amazon", category: "category_shopping", defaultCost: nil, color: Color(hex: "FF9900")),
        QuickShortcut(name: "HBO Max", icon: "hbomax", category: "category_streaming", defaultCost: nil, color: Color(hex: "000000")),
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
        participants = subscription.participants ?? []
    }
    
    func addJointEmail() {
        let email = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else { return }
        
        // Simple email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            error = "error_email_invalid".localized()
            return
        }
        
        if !jointEmails.contains(email) && !participants.contains(where: { $0.email == email }) {
            jointEmails.append(email)
            emailInput = ""
        } else {
            error = "Email already added" // Consider adding to Localizable.strings if needed
        }
    }
    
    func removeJointEmail(_ email: String) {
        jointEmails.removeAll { $0 == email }
        participants.removeAll { $0.email == email }
    }
    
    func applyShortcut(_ shortcut: QuickShortcut) {
        name = shortcut.name
        icon = shortcut.icon
        selectedCategory = shortcut.category
        if let cost = shortcut.defaultCost {
            amount = CurrencyFormatter.formatAmountWithoutSymbol(cost)
        }
    }
    
    func handleAmountChange(_ newValue: String) {
        let formatted = formatBankingAmount(newText: newValue)
        
        // CRITICAL: We update on the next run loop to force SwiftUI to re-sync the TextField internal state
        // with the formatted value, ensuring "live" character-by-character formatting.
        DispatchQueue.main.async {
            if formatted != self.amount {
                self.amount = formatted
            }
        }
        amountError = nil
    }
    
    private func formatBankingAmount(newText: String) -> String {
        if newText.isEmpty { return "" }
        
        // 1. Remove grouping separators (dots) to handle intended value correctly
        let cleanedInput = newText.replacingOccurrences(of: ".", with: "")
        
        // 2. Filter characters: only digits and the FIRST comma/dot
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
        
        // Split into integer and decimal parts
        let parts = filtered.split(separator: ",", omittingEmptySubsequences: false)
        let integerPartString = String(parts.first ?? "")
        var decimalPartString = parts.count > 1 ? String(parts[1]) : ""
        
        // Limit decimal to 2 digits
        if decimalPartString.count > 2 {
            decimalPartString = String(decimalPartString.prefix(2))
        }
        
        // Format integer part with thousands separators (dots)
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
    
    func save(currency: Int, onSuccess: @escaping () -> Void) {
        guard validate() else { return }
        
        let costValue = CurrencyFormatter.parseBankingAmount(amount)
        
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
                case .success(_):
                    isLoading = false
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
                case .success(_):
                    isLoading = false
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
        
        if selectedCategory.isEmpty {
            categoryError = "error_category_required".localized()
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
    
    func clearGeneralError() {
        error = nil
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
        participants = []
        emailInput = ""
        error = nil
        responseMessage = nil
        nameError = nil
        amountError = nil
        categoryError = nil
    }
}
