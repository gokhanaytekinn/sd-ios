import SwiftUI

struct AddSubscriptionScreen: View {
    @StateObject private var viewModel = AddSubscriptionViewModel()
    var editSubscription: Subscription? = nil
    let onSaved: () -> Void
    let onBack: () -> Void
    
    @FocusState private var focusedField: String?
    
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
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
                    VStack(alignment: .leading, spacing: 24) {
                        // Service Name
                        SDOutlinedTextField(
                            title: "service_name".localized(),
                            placeholder: "service_name_placeholder".localized(),
                            text: $viewModel.name,
                            errorMessage: viewModel.nameError,
                            focusBinding: $focusedField,
                            focusValue: "serviceName"
                        )
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
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
                                    ForEach(AddSubscriptionViewModel.shortcuts) { shortcut in
                                        let isSelected = viewModel.icon == shortcut.icon && viewModel.name == shortcut.name
                                        Button(action: { viewModel.applyShortcut(shortcut) }) {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(isSelected ? shortcut.color.opacity(0.2) : shortcut.color.opacity(0.1))
                                                        .frame(width: 56, height: 56)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(isSelected ? shortcut.color : shortcut.color.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                                                        )
                                                    
                                                    if let iconName = shortcut.icon {
                                                        BrandIconView(name: iconName, color: shortcut.color)
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
                                text: $viewModel.amount,
                                errorMessage: viewModel.amountError,
                                keyboardType: .decimalPad,
                                focusBinding: $focusedField,
                                focusValue: "amount"
                            )
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("done_btn".localized()) {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
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
                                    HStack {
                                        Text(CurrencyPreferences.currencies.first(where: { $0.id == currency })?.symbol ?? "")
                                        Image(systemName: "chevron.down").font(.system(size: 12))
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .background(Color.clear)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(1), lineWidth: 1))
                                }
                            }
                            .frame(width: 120)
                        }
                        
                        // Period (MONTHLY / YEARLY)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("period".localized())
                                .font(.system(size: 14, weight: .bold))
                            
                            HStack(spacing: 0) {
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
                        
                        // Payment Recurrence Day
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.selectedBillingCycle == .monthly ? 
                                 "payment_recurrence_day".localized() : 
                                 "payment_recurrence_day_month".localized())
                                .font(.system(size: 14, weight: .bold))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(1...31, id: \.self) { day in
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

                        // Payment Recurrence Month (Only for Yearly)
                        if viewModel.selectedBillingCycle == .yearly {
                            VStack(alignment: .leading, spacing: 8) {

                                
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
                        VStack(alignment: .leading, spacing: 8) {
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
                        
                        // Joint Users
                        VStack(alignment: .leading, spacing: 12) {
                            Text("joint_users".localized())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            SDOutlinedTextField(
                                title: "",
                                placeholder: "add_email_placeholder".localized(),
                                text: $viewModel.emailInput,
                                errorMessage: nil,
                                keyboardType: .emailAddress,
                                trailingIcon: "plus",
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
                                        .background(Color.appSurface(for: colorScheme))
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 16)
                        
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
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(viewModel.isEditing ?
                                        "update".localized() :
                                        "add_subscription_btn".localized())
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.primaryBlue)
                            .cornerRadius(12)
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
            HStack(spacing: 8) {
                Image(systemName: "play.fill") // Placeholder for category icon
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(viewModel.selectedCategory == key ? Color.primaryBlue : Color.appSurface(for: colorScheme))
            .foregroundColor(viewModel.selectedCategory == key ? .white : Color.appOnBackground(for: colorScheme))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: viewModel.selectedCategory == key ? 0 : 1)
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
