import SwiftUI

struct AddSubscriptionScreen: View {
    @StateObject private var viewModel = AddSubscriptionViewModel()
    var editSubscription: Subscription? = nil
    let onSaved: () -> Void
    let onBack: () -> Void
    
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
                     NSLocalizedString("edit_subscription", comment: "") :
                     NSLocalizedString("add_subscription", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Spacer()
                
                // Invisible spacer for centering
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Quick Shortcuts (only for new subscriptions)
                    if !viewModel.isEditing {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(AddSubscriptionViewModel.shortcuts) { shortcut in
                                    Button(action: { viewModel.applyShortcut(shortcut) }) {
                                        HStack(spacing: 6) {
                                            Text(shortcut.name.prefix(1).uppercased())
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.primaryBlue)
                                                .frame(width: 24, height: 24)
                                                .background(Color.primaryBlue.opacity(0.1))
                                                .clipShape(Circle())
                                            
                                            Text(shortcut.name)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            viewModel.name == shortcut.name ?
                                            Color.primaryBlue.opacity(0.1) :
                                            Color.appSurface(for: colorScheme)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    viewModel.name == shortcut.name ?
                                                    Color.primaryBlue : Color.appOutline(for: colorScheme).opacity(0.3),
                                                    lineWidth: 1
                                                )
                                        )
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // Service Name
                    SDOutlinedTextField(
                        title: NSLocalizedString("service_name", comment: ""),
                        placeholder: NSLocalizedString("service_name_placeholder", comment: ""),
                        text: $viewModel.name,
                        error: viewModel.nameError
                    )
                    
                    // Amount
                    SDOutlinedTextField(
                        title: NSLocalizedString("amount", comment: ""),
                        placeholder: "0,00",
                        text: $viewModel.amount,
                        error: viewModel.amountError,
                        keyboardType: .decimalPad
                    )
                    
                    // Billing Cycle
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("billing_cycle", comment: ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        HStack(spacing: 8) {
                            billingCycleChip(NSLocalizedString("billing_monthly_label", comment: ""), cycle: .monthly)
                            billingCycleChip(NSLocalizedString("billing_yearly_label", comment: ""), cycle: .yearly)
                            billingCycleChip(NSLocalizedString("billing_weekly_label", comment: ""), cycle: .weekly)
                        }
                    }
                    
                    // Billing Day
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.selectedBillingCycle == .yearly ?
                             NSLocalizedString("payment_recurrence_day_month", comment: "") :
                             NSLocalizedString("payment_recurrence_day", comment: ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        HStack(spacing: 12) {
                            // Day Picker
                            Picker("", selection: $viewModel.billingDay) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                            .clipped()
                            
                            // Month Picker (yearly only)
                            if viewModel.selectedBillingCycle == .yearly {
                                Picker("", selection: $viewModel.billingMonth) {
                                    ForEach(1...12, id: \.self) { month in
                                        Text(DateFormatter().monthSymbols[month - 1]).tag(month)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                                .clipped()
                            }
                        }
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("category", comment: ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        if let error = viewModel.categoryError {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(.errorColor)
                        }
                        
                        FlowLayout(spacing: 8) {
                            ForEach(AddSubscriptionViewModel.categories, id: \.key) { category in
                                categoryChip(
                                    NSLocalizedString(category.key, comment: ""),
                                    key: category.key
                                )
                            }
                        }
                    }
                    
                    // Reminder
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("reminder", comment: ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.primaryBlue)
                            
                            VStack(alignment: .leading) {
                                Text(viewModel.reminderEnabled ? NSLocalizedString("set_reminder", comment: "") : NSLocalizedString("turn_off_reminder", comment: ""))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                
                                Text(NSLocalizedString("reminder_desc", comment: ""))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $viewModel.reminderEnabled)
                                .tint(.primaryBlue)
                                .labelsHidden()
                        }
                        .padding(12)
                        .background(Color.appSurface(for: colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    
                    // Joint Users
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("joint_users", comment: ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        ForEach(viewModel.jointEmails.indices, id: \.self) { index in
                            HStack {
                                Text(viewModel.jointEmails[index])
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                
                                Spacer()
                                
                                Button(action: { viewModel.jointEmails.remove(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.errorColor)
                                }
                            }
                            .padding(10)
                            .background(Color.appSurface(for: colorScheme))
                            .cornerRadius(8)
                        }
                        
                        HStack {
                            @State var newEmail = ""
                            TextField(NSLocalizedString("add_email_placeholder", comment: ""), text: $newEmail)
                                .font(.system(size: 14))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            Button(action: {
                                if !newEmail.isEmpty {
                                    viewModel.jointEmails.append(newEmail)
                                    newEmail = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 24)
            }
            
            // Save Button
            VStack {
                SDButton(
                    title: viewModel.isEditing ?
                        NSLocalizedString("save_changes", comment: "") :
                        NSLocalizedString("add_subscription", comment: ""),
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.save(currency: currency, onSuccess: onSaved)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.appBackground(for: colorScheme))
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
        .onAppear {
            if let sub = editSubscription {
                viewModel.setupForEdit(subscription: sub)
            }
        }
        .alert(NSLocalizedString("error", comment: ""), isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button(NSLocalizedString("close", comment: ""), role: .cancel) { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
    }
    
    private func billingCycleChip(_ title: String, cycle: BillingCycle) -> some View {
        Button(action: { viewModel.selectedBillingCycle = cycle }) {
            Text(title)
                .font(.system(size: 14, weight: viewModel.selectedBillingCycle == cycle ? .bold : .medium))
                .foregroundColor(viewModel.selectedBillingCycle == cycle ? .white : Color.appOnBackground(for: colorScheme))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(viewModel.selectedBillingCycle == cycle ? Color.primaryBlue : Color.appSurface(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            viewModel.selectedBillingCycle == cycle ? Color.primaryBlue : Color.appOutline(for: colorScheme).opacity(0.3),
                            lineWidth: 1
                        )
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func categoryChip(_ title: String, key: String) -> some View {
        Button(action: { viewModel.selectedCategory = key }) {
            Text(title)
                .font(.system(size: 13, weight: viewModel.selectedCategory == key ? .bold : .regular))
                .foregroundColor(viewModel.selectedCategory == key ? .white : Color.appOnBackground(for: colorScheme))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(viewModel.selectedCategory == key ? Color.primaryBlue : Color.appSurface(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            viewModel.selectedCategory == key ? Color.primaryBlue : Color.appOutline(for: colorScheme).opacity(0.3),
                            lineWidth: 1
                        )
                )
                .cornerRadius(8)
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
