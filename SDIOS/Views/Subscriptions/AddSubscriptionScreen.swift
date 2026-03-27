import SwiftUI

struct AddSubscriptionScreen: View {
    @StateObject private var viewModel = AddSubscriptionViewModel()
    var editSubscription: Subscription? = nil
    let onSaved: () -> Void
    let onBack: () -> Void
    
    @FocusState private var focusedField: String?
    @State private var showAllShortcutsSheet = false
    @State private var allShortcutsQuery = ""
    
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
    private var sortedShortcuts: [AddSubscriptionViewModel.QuickShortcut] {
        AddSubscriptionViewModel.shortcuts.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
    
    private func normalizedShortcutName(_ name: String) -> String {
        name.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    private var previewShortcuts: [AddSubscriptionViewModel.QuickShortcut] {
        let preferredOrder = ["youtube", "netflix", "spotify", "chatgpt", "amazonprime", "cambly"]
        var result: [AddSubscriptionViewModel.QuickShortcut] = []
        
        // Keep requested order first.
        for key in preferredOrder {
            if let shortcut = AddSubscriptionViewModel.shortcuts.first(where: {
                normalizedShortcutName($0.name) == key
            }) {
                result.append(shortcut)
            }
        }
        
        // Complete to 6 with remaining shortcuts.
        if result.count < 6 {
            let existing = Set(result.map(\.name))
            let remaining = sortedShortcuts.filter { !existing.contains($0.name) }
            result.append(contentsOf: remaining.prefix(6 - result.count))
        }
        
        // If user selected outside top 6, show it as 7th.
        if let selected = AddSubscriptionViewModel.shortcuts.first(where: {
            viewModel.icon == $0.icon && viewModel.name == $0.name
        }), !result.contains(where: { $0.name == selected.name && $0.icon == selected.icon }) {
            result.append(selected)
        }
        
        return result
    }
    
    private func shortcutIconColor(_ shortcut: AddSubscriptionViewModel.QuickShortcut) -> Color {
        guard let icon = shortcut.icon?.lowercased() else { return shortcut.color }
        if icon == "github" || icon == "notion" || icon == "hbomax" || icon == "jetbrains" {
            return colorScheme == .dark ? .white : shortcut.color
        }
        return shortcut.color
    }
    
    private func hasFixedContrastBorder(_ shortcut: AddSubscriptionViewModel.QuickShortcut) -> Bool {
        guard let icon = shortcut.icon?.lowercased() else { return false }
        return icon == "github" || icon == "hbomax"
    }
    
    private func shortcutBorderColor(_ shortcut: AddSubscriptionViewModel.QuickShortcut) -> Color {
        if hasFixedContrastBorder(shortcut) {
            return colorScheme == .dark ? .white : .black
        }
        return shortcut.color
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                
                Spacer()
                
                Text(viewModel.isEditing ?
                     "edit_subscription".localized() :
                     "add_subscription".localized())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Spacer()
                
                // Invisible spacer for centering
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(16)
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer().frame(height: 4)
                        
                        // Service Name
                        SDOutlinedTextField(
                            title: "service_name".localized(),
                            placeholder: "service_name_placeholder".localized(),
                            text: $viewModel.name,
                            errorMessage: viewModel.nameError,
                            leadingIcon: "pencil",
                            focusBinding: $focusedField,
                            focusValue: "serviceName"
                        )
                        
                        // Category
                        VStack(alignment: .leading, spacing: 10) {
                            Text("category".localized())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(AddSubscriptionViewModel.categories, id: \.key) { category in
                                        categoryChip(category.key.localized(), key: category.key)
                                    }
                                }
                                .padding(2) // Extra padding for border visibility
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.categoryError != nil ? Color.errorColor : Color.clear, lineWidth: 1)
                            )
                            
                            if let error = viewModel.categoryError {
                                Text(error).font(.system(size: 12)).foregroundColor(.errorColor)
                            }
                        }
                        
                        // Quick Shortcuts (under categories in Android)
                        if !viewModel.isEditing {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(previewShortcuts) { shortcut in
                                        let isSelected = viewModel.icon == shortcut.icon && viewModel.name == shortcut.name
                                        Button(action: { viewModel.applyShortcut(shortcut) }) {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.clear)
                                                        .frame(width: 56, height: 56)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(
                                                                    shortcutBorderColor(shortcut).opacity(
                                                                        hasFixedContrastBorder(shortcut) ? 1 : (isSelected ? 1 : 0.3)
                                                                    ),
                                                                    lineWidth: isSelected ? 2 : 1
                                                                )
                                                        )
                                                    
                                                    if let iconName = shortcut.icon {
                                                        BrandIconView(name: iconName, color: shortcutIconColor(shortcut))
                                                            .frame(width: 24, height: 24)
                                                    } else {
                                                        Text(shortcut.name.prefix(1).uppercased())
                                                            .font(.system(size: 24, weight: .bold))
                                                            .foregroundColor(shortcut.color)
                                                    }
                                                }
                                                .scaleEffect(isSelected ? 1.08 : 1.0)
                                                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
                                                
                                                Text(shortcut.name)
                                                    .font(.system(size: 11, weight: isSelected ? .bold : .regular))
                                                    .foregroundColor(isSelected ? shortcut.color : Color.appOnSurfaceVariant(for: colorScheme))
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    Button(action: { showAllShortcutsSheet = true }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.clear)
                                                    .frame(width: 56, height: 56)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                                                    )
                                                
                                                Image(systemName: "ellipsis")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.7))
                                                    .frame(width: 56, height: 56, alignment: .center)
                                            }
                                            
                                            Text(" ")
                                                .font(.system(size: 11))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 6)
                            }
                        }
                        
                        // Amount and Currency
                        HStack(alignment: .top, spacing: 12) {
                            SDOutlinedTextField(
                                title: "amount".localized(),
                                placeholder: "0,00",
                                text: Binding(
                                    get: { viewModel.amount },
                                    set: { viewModel.handleAmountChange($0) }
                                ),
                                errorMessage: viewModel.amountError,
                                keyboardType: .decimalPad,
                                leadingIcon: "banknote",
                                focusBinding: $focusedField,
                                focusValue: "amount"
                            )
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("currency".localized())
                                    .font(.system(size: 14, weight: .bold))
                                
                                Menu {
                                    ForEach(CurrencyPreferences.currencies, id: \.id) { cur in
                                        Button(action: { currency = cur.id }) {
                                            Text("\(cur.symbol) \(cur.code)")
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "dollarsign.circle")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.4))
                                        
                                        Text(CurrencyPreferences.currencies.first(where: { $0.id == currency })?.symbol ?? "")
                                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.4))
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 45)
                                    .background(Color.clear)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                                    )
                                }
                            }
                            .frame(width: 140)
                        }
                        
                        // Period (DAILY / WEEKLY / MONTHLY / YEARLY)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("period".localized())
                                .font(.system(size: 14, weight: .bold))
                            
                            HStack(spacing: 0) {
                                periodButton(title: dailyCycleLabel, cycle: .daily)
                                periodButton(title: "billing_weekly_label".localized(), cycle: .weekly)
                                periodButton(title: "billing_monthly_label".localized(), cycle: .monthly)
                                periodButton(title: "billing_yearly_label".localized(), cycle: .yearly)
                            }
                            .background(Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                            )
                        }
                        
                        // Payment recurrence selections are hidden for daily cycles.
                        if viewModel.selectedBillingCycle != .daily {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(viewModel.isFreeTrial ? "trial_end_date".localized() :
                                        (viewModel.selectedBillingCycle == .yearly
                                         ? "payment_recurrence_day_month".localized()
                                         : "payment_recurrence_day".localized()))
                                    .font(.system(size: 14, weight: .bold))
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(1...maxBillingDayForSelectedCycle, id: \.self) { day in
                                            Button(action: { viewModel.billingDay = day }) {
                                                Text("\(day)")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .padding(.horizontal, 16)
                                                    .frame(height: 44)
                                                    .background(viewModel.billingDay == day ? Color.primaryBlue : Color.appSurface(for: colorScheme))
                                                    .foregroundColor(viewModel.billingDay == day ? .white : Color.appOnBackground(for: colorScheme))
                                                    .cornerRadius(22)
                                                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: viewModel.billingDay == day ? 0 : 1))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }

                        // Payment Recurrence Month (Only for Yearly)
                        if viewModel.selectedBillingCycle == .yearly {
                            VStack(alignment: .leading, spacing: 10) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(1...12, id: \.self) { month in
                                            Button(action: { viewModel.billingMonth = month }) {
                                                Text("month_\(month)".localized())
                                                    .font(.system(size: 14, weight: .bold))
                                                    .padding(.horizontal, 16)
                                                    .frame(height: 44)
                                                    .background(viewModel.billingMonth == month ? Color.primaryBlue : Color.appSurface(for: colorScheme))
                                                    .foregroundColor(viewModel.billingMonth == month ? .white : Color.appOnBackground(for: colorScheme))
                                                    .cornerRadius(22)
                                                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: viewModel.billingMonth == month ? 0 : 1))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        if let error = viewModel.dateError {
                            Text(error).font(.system(size: 12)).foregroundColor(.errorColor)
                        }
                        
                        // Reminder
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("reminder".localized())
                                        .font(.system(size: 16, weight: .medium))
                                    Text("notify_1_day_before".localized())
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                Spacer()
                                Toggle("", isOn: $viewModel.reminderEnabled)
                                    .tint(.primaryBlue)
                                    .labelsHidden()
                            }
                        }
                        
                        // Free Trial
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("free_trial".localized())
                                        .font(.system(size: 16, weight: .medium))
                                    Text("free_trial_desc".localized())
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                Spacer()
                                Toggle("", isOn: $viewModel.isFreeTrial)
                                    .tint(.primaryBlue)
                                    .labelsHidden()
                            }
                        }
                        
                        // Joint Users
                        SDOutlinedTextField(
                            title: "joint_users".localized(),
                            placeholder: "add_email_placeholder".localized(),
                            text: $viewModel.emailInput,
                            errorMessage: nil,
                            keyboardType: .emailAddress,
                            leadingIcon: "envelope",
                            onTrailingIconTap: { viewModel.addJointEmail() },
                            focusBinding: $focusedField,
                            focusValue: "emailInput"
                        )
    
                            let combinedEmails = viewModel.jointEmails.map { (email: $0, status: String?.none, name: String?.none) }
                            let participantEmails = viewModel.participants.map { (email: $0.email, status: String?($0.status), name: $0.name) }
                            let allEmails = participantEmails + combinedEmails
                            if !allEmails.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(allEmails, id: \.email) { item in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                if let name = item.name {
                                                    Text(name)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                                                }
                                                Text(item.email)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                            }
                                            
                                            Spacer()
                                            
                                            if let status = item.status {
                                                StatusIcon(status: status)
                                            }
                                            
                                            Button(action: { viewModel.removeJointEmail(item.email) }) {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                                    .padding(8)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.clear)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(1.0), lineWidth: 1))
                                    }
                                }
                            }
                        
                        
                        // Save Button
                        VStack {
                            Button(action: { 
                                viewModel.save(currency: currency, onSuccess: onSaved)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if viewModel.nameError != nil {
                                        focusedField = "serviceName"
                                    } else if viewModel.amountError != nil {
                                        focusedField = "amount"
                                    }
                                }
                            }) {
                                Group {
                                    if viewModel.isLoading {
                                        Text("loading".localized())
                                            .font(.sdBodyBold)
                                            .foregroundColor(.primaryBlue)
                                    } else {
                                        Text(viewModel.isEditing ?
                                            "update".localized() :
                                            "add_subscription_btn".localized())
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.primaryBlue)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                                .background(Color.appSurface(for: colorScheme).opacity(0.001))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                    }
                    .padding(.horizontal, 24)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear {
            if let sub = editSubscription {
                viewModel.setupForEdit(subscription: sub)
            }
        }
        .withErrorDialog(errorMessage: $viewModel.error) {
            viewModel.clearGeneralError()
        }
        .sheet(isPresented: $showAllShortcutsSheet) {
            AllShortcutsSheet(
                query: $allShortcutsQuery,
                colorScheme: colorScheme,
                onSelect: { shortcut in
                    viewModel.applyShortcut(shortcut)
                    showAllShortcutsSheet = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .onAppear { allShortcutsQuery = "" }
        }
    }
    
    private func periodButton(title: String, cycle: BillingCycle) -> some View {
        Button(action: { viewModel.selectedBillingCycle = cycle }) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(viewModel.selectedBillingCycle == cycle ? .white : Color.appOnSurfaceVariant(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(viewModel.selectedBillingCycle == cycle ? Color.primaryBlue : Color.appSurface(for: colorScheme).opacity(0.001))
                .cornerRadius(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var maxBillingDayForSelectedCycle: Int {
        viewModel.selectedBillingCycle == .weekly ? 7 : 31
    }
    
    private var dailyCycleLabel: String {
        "billing_daily_label".localized()
    }
    
    struct StatusIcon: View {
        let status: String
        
        var body: some View {
            let config = statusConfig
            Image(systemName: config.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(config.color)
        }
        
        private var statusConfig: (icon: String, color: Color) {
            switch status {
            case "ACCEPTED":
                return ("checkmark.circle.fill", .green)
            case "REJECTED":
                return ("xmark.circle.fill", .red)
            default:
                return ("clock.fill", .gray)
            }
        }
    }
    
    private func categoryChip(_ title: String, key: String) -> some View {
        Button(action: { viewModel.selectedCategory = key }) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(viewModel.selectedCategory == key ? Color.primaryBlue : Color.clear)
                .foregroundColor(viewModel.selectedCategory == key ? .white : Color.appOnBackground(for: colorScheme))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(viewModel.selectedCategory == key ? Color.clear : Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout for Categories
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}

private struct AllShortcutsSheet: View {
    @Binding var query: String
    let colorScheme: ColorScheme
    let onSelect: (AddSubscriptionViewModel.QuickShortcut) -> Void
    
    private var sortedShortcuts: [AddSubscriptionViewModel.QuickShortcut] {
        AddSubscriptionViewModel.shortcuts.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
    
    private var filtered: [AddSubscriptionViewModel.QuickShortcut] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return sortedShortcuts }
        return sortedShortcuts.filter { $0.name.lowercased().contains(q) }
    }
    
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 88, maximum: 120), spacing: 16, alignment: .top)
    ]
    
    private func shortcutIconColor(_ shortcut: AddSubscriptionViewModel.QuickShortcut) -> Color {
        guard let icon = shortcut.icon?.lowercased() else { return shortcut.color }
        if icon == "github" || icon == "notion" || icon == "hbomax" || icon == "jetbrains" {
            return colorScheme == .dark ? .white : shortcut.color
        }
        return shortcut.color
    }
    
    private func hasFixedContrastBorder(_ shortcut: AddSubscriptionViewModel.QuickShortcut) -> Bool {
        guard let icon = shortcut.icon?.lowercased() else { return false }
        return icon == "github" || icon == "hbomax"
    }
    
    private func shortcutBorderColor(_ shortcut: AddSubscriptionViewModel.QuickShortcut) -> Color {
        if hasFixedContrastBorder(shortcut) {
            return colorScheme == .dark ? .white : .black
        }
        return shortcut.color
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.4))
                
                TextField("search".localized(), text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 16))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Color.appSurface(for: colorScheme).opacity(0.001))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appOutline(for: colorScheme).opacity(0.35), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 32)
            .padding(.bottom, 12)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filtered) { shortcut in
                        Button(action: { onSelect(shortcut) }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.clear)
                                        .frame(width: 56, height: 56)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    shortcutBorderColor(shortcut).opacity(
                                                        hasFixedContrastBorder(shortcut) ? 1 : 0.3
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                    
                                    if let iconName = shortcut.icon {
                                        BrandIconView(name: iconName, color: shortcutIconColor(shortcut))
                                            .frame(width: 24, height: 24)
                                    } else {
                                        Text(shortcut.name.prefix(1).uppercased())
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(shortcut.color)
                                    }
                                }
                                
                                Text(shortcut.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
}
