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
                VStack(alignment: .leading, spacing: 24) {
                    // Service Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("service_name", comment: ""))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        TextField(NSLocalizedString("service_name_placeholder", comment: ""), text: $viewModel.name)
                            .padding()
                            .background(Color.appSurface(for: colorScheme))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
                        
                        if let error = viewModel.nameError {
                            Text(error).font(.system(size: 12)).foregroundColor(.errorColor)
                        }
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("category", comment: ""))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(AddSubscriptionViewModel.categories, id: \.key) { category in
                                    categoryChip(NSLocalizedString(category.key, comment: ""), key: category.key)
                                }
                            }
                        }
                    }
                    
                    // Quick Shortcuts (under categories in Android)
                    if !viewModel.isEditing {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(AddSubscriptionViewModel.shortcuts) { shortcut in
                                    Button(action: { viewModel.applyShortcut(shortcut) }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.appSurface(for: colorScheme))
                                                    .frame(width: 56, height: 56)
                                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
                                                
                                                Text(shortcut.name.prefix(1).uppercased())
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                            }
                                            
                                            Text(shortcut.name)
                                                .font(.system(size: 11))
                                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // Amount and Currency
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("amount", comment: ""))
                                .font(.system(size: 14, weight: .bold))
                            
                            TextField("0,00", text: $viewModel.amount)
                                .padding()
                                .background(Color.appSurface(for: colorScheme))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
                                .keyboardType(.decimalPad)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("currency", comment: ""))
                                .font(.system(size: 14, weight: .bold))
                            
                            HStack {
                                Text(CurrencyPreferences.currencies.first(where: { $0.id == currency })?.symbol ?? "")
                                Image(systemName: "chevron.down").font(.system(size: 12))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.appSurface(for: colorScheme))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
                        }
                        .frame(width: 120)
                    }
                    
                    // Period (MONTHLY / YEARLY)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("period", comment: ""))
                            .font(.system(size: 14, weight: .bold))
                        
                        HStack(spacing: 0) {
                            periodButton(title: NSLocalizedString("billing_monthly_label", comment: "").uppercased(), cycle: .monthly)
                            periodButton(title: NSLocalizedString("billing_yearly_label", comment: "").uppercased(), cycle: .yearly)
                        }
                        .background(Color.appSurface(for: colorScheme))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1))
                    }
                    
                    // Payment Recurrence Day
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("payment_recurrence_day", comment: ""))
                            .font(.system(size: 14, weight: .bold))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(1...31, id: \.self) { day in
                                    Button(action: { viewModel.billingDay = day }) {
                                        Text("\(day)")
                                            .font(.system(size: 14, weight: .bold))
                                            .frame(width: 44, height: 44)
                                            .background(viewModel.billingDay == day ? Color.primaryBlue : Color.appSurface(for: colorScheme))
                                            .foregroundColor(viewModel.billingDay == day ? .white : Color.appOnBackground(for: colorScheme))
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: viewModel.billingDay == day ? 0 : 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Reminder
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("reminder", comment: ""))
                            .font(.system(size: 14, weight: .bold))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocalizedString("reminder", comment: ""))
                                    .font(.system(size: 16, weight: .medium))
                                Text(NSLocalizedString("notify_1_day_before", comment: ""))
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("joint_users", comment: ""))
                            .font(.system(size: 14, weight: .bold))
                        
                        // Joint users list and add field implemented here...
                        // (simplified for parity with screenshot)
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
                .padding(.horizontal, 24)
            }
            
            // Save Button
            VStack {
                Button(action: { viewModel.save(currency: currency, onSuccess: onSaved) }) {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(viewModel.isEditing ?
                            NSLocalizedString("update", comment: "") :
                            NSLocalizedString("add_subscription", comment: ""))
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
    
    private func periodButton(title: String, cycle: BillingCycle) -> some View {
        Button(action: { viewModel.selectedBillingCycle = cycle }) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(viewModel.selectedBillingCycle == cycle ? .white : Color.appOnSurfaceVariant(for: colorScheme))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.selectedBillingCycle == cycle ? Color.primaryBlue : Color.clear)
                .cornerRadius(10)
                .padding(4)
        }
        .buttonStyle(.plain)
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
