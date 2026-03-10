import SwiftUI
import Charts

struct AnalyticsScreen: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    // Calendar & Filtering States
    @State private var selectedDate = Date()
    @State private var calendarMonth = Date()
    @State private var selectedCalendarDay: Date?
    
    struct IdentifiableDate: Identifiable {
        let id: String
        let date: Date
    }
    @State private var popoverDay: IdentifiableDate?
    
    let onBack: () -> Void
    let onNavigateToPremium: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                if viewModel.isLoading {
                    AnalyticsSkeleton()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // 1. Category Selector
                            categorySelector
                            
                            // 2. Summary Card (Donut Chart & Totals)
                            chartSection
                            
                            // 3. Interactive Calendar
                            calendarSection
                            
                            // 5. Insights
                            insightsSection
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.bottom, 24)
                        .blur(radius: viewModel.isPremium ? 0 : 8)
                        .disabled(!viewModel.isPremium)
                    }
                }
            }
            
            if !viewModel.isPremium {
                premiumLockOverlay
            }
        }
        .sheet(item: $popoverDay) { item in
            calendarBubbleContent(for: item.date)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.authViewModel = authViewModel
            viewModel.loadAnalytics()
        }
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(spacing: 16) {
            if let breakdown = viewModel.summary?.categoryBreakdown, !breakdown.isEmpty {
                let data = breakdown.map { (key: $0.key, value: $0.value) }
                    .filter { $0.value > 0 }
                    .sorted(by: { $0.value > $1.value })
                
                if !data.isEmpty {
                    ZStack {
                        Chart(data, id: \.key) { item in
                            let isSelected = viewModel.selectedCategory == item.key
                            SectorMark(
                                angle: .value("Value", item.value),
                                innerRadius: .ratio(0.75),
                                angularInset: 2
                            )
                            .cornerRadius(10)
                            .foregroundStyle(AnalyticsViewModel.colorForCategory(item.key))
                            .opacity(viewModel.selectedCategory == "All" || isSelected ? 1.0 : 0.2)
                            .shadow(color: isSelected ? AnalyticsViewModel.colorForCategory(item.key).opacity(0.5) : Color.clear, radius: 10, x: 0, y: 0)
                        }
                        .frame(height: 220)
                        .chartAngleSelection(value: Binding(
                            get: { 0 }, // Value not used for tapping logic here as we'll use a better approach
                            set: { angle in
                                if let angle = angle {
                                    handleChartTap(angle: angle, data: data)
                                }
                            }
                        ))
                        
                        // Center Info
                        VStack(spacing: 4) {
                            Text(viewModel.selectedCategory == "All" ? "total".localized() : viewModel.selectedCategory.localized())
                                .font(.sdCaption)
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            
                            if let summary = viewModel.summary {
                                let amount = viewModel.selectedCategory == "All" ? summary.totalMonthlyCost : (breakdown[viewModel.selectedCategory] ?? 0)
                                Text(CurrencyFormatter.formatAmount(amount, currencyCode: summary.currency))
                                    .font(.sdHeadline)
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                            }
                        }
                    }
                    .transition(.opacity)
                } else {
                    emptyChartPlaceholder
                }
            } else {
                emptyChartPlaceholder
            }
        }
        .padding(.vertical, 8)
    }
    
    private var emptyChartPlaceholder: some View {
        ZStack {
            Circle()
                .stroke(Color.appOutline(for: colorScheme).opacity(0.15), lineWidth: 20)
                .frame(width: 160, height: 160)
            
            VStack(spacing: 8) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme).opacity(0.3))
                
                Text("no_data".localized())
                    .font(.sdCaption)
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
            }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
    }
    
    private func handleChartTap(angle: Double, data: [(key: String, value: Double)]) {
        let totalValue = data.reduce(0) { $0 + $1.value }
        var cumulativeValue: Double = 0
        
        for item in data {
            cumulativeValue += item.value
            if angle <= cumulativeValue {
                withAnimation {
                    if viewModel.selectedCategory == item.key {
                        viewModel.selectedCategory = "All"
                    } else {
                        viewModel.selectedCategory = item.key
                    }
                }
                break
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
            }
            
            Spacer()
            
            Text("analytics_title".localized())
                .font(.sdHeadline)
                .foregroundColor(Color.appOnBackground(for: colorScheme))
            
            Spacer()
            
            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Button(action: {
                        withAnimation {
                            viewModel.selectedCategory = category
                        }
                    }) {
                        Text(category.localized())
                            .font(.sdSmallSemibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedCategory == category ? Color.primaryBlue : Color.appSurface(for: colorScheme))
                            .foregroundColor(viewModel.selectedCategory == category ? .white : Color.appOnSurfaceVariant(for: colorScheme))
                            .cornerRadius(12)
                            .shadow(color: viewModel.selectedCategory == category ? Color.primaryBlue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appOutline(for: colorScheme), lineWidth: viewModel.selectedCategory == category ? 0 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var filteredEvents: [CalendarEvent] {
        guard let summary = viewModel.summary else { return [] }
        if viewModel.selectedCategory == "All" {
            return summary.calendarEvents
        }
        return summary.calendarEvents.filter { event in
            // To filter calendar events locally, we need the subscription's category.
            // We have allSubscriptions in the viewModel.
            if let sub = viewModel.allSubscriptions.first(where: { $0.id == event.subscriptionId }) {
                return sub.category == viewModel.selectedCategory
            }
            return false
        }
    }


    // MARK: - Calendar Section
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("renewal_calendar".localized())
                    .font(.sdSubheadlineSemibold)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Spacer()
                
                Button(action: { calendarMonth = calendar.date(byAdding: .month, value: -1, to: calendarMonth) ?? calendarMonth }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primaryBlue)
                }
                
                Text(monthYearString(from: calendarMonth))
                    .font(.sdSmallBold)
                    .frame(width: 100)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Button(action: { calendarMonth = calendar.date(byAdding: .month, value: 1, to: calendarMonth) ?? calendarMonth }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primaryBlue)
                }
            }
            
            let days = generateDaysInMonth(for: calendarMonth)
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map { $0.localized() }, id: \.self) { day in
                    Text(day)
                        .font(.sdLabel)
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                }
                
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        calendarDayCell(for: date)
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
    
    private func calendarDayCell(for date: Date) -> some View {
        let registrations = subscriptionsOnDay(date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = popoverDay.map { calendar.isDate($0.date, inSameDayAs: date) } ?? false
        
        return VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.sdLabelSemibold)
                .foregroundColor(isSelected ? .white : (isToday ? .primaryBlue : Color.appOnBackground(for: colorScheme)))
                .frame(width: 32, height: 32)
                .background(isSelected ? Color.primaryBlue : Color.clear)
                .clipShape(Circle())
            
            if !registrations.isEmpty {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            let registrations = subscriptionsOnDay(date)
            if !registrations.isEmpty {
                withAnimation {
                    popoverDay = IdentifiableDate(id: date.description, date: date)
                }
            }
        }
    }
    
    private func calendarBubbleContent(for date: Date) -> some View {
        let registrations = subscriptionsOnDay(date)
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(longDateString(from: date))
                    .font(.sdCaptionBold)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Text("\(registrations.count) \("renewals".localized())")
                    .font(.sdLabel)
                    .foregroundColor(.primaryBlue)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            if registrations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    Text("no_renewals_this_day".localized())
                        .font(.sdLabel)
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(registrations) { event in
                            if let subscription = getSubscription(for: event.subscriptionId) {
                                SubscriptionCard(
                                    subscription: subscription,
                                    showDate: false,
                                    onTap: { popoverDay = nil }
                                )
                            } else {
                                // Fallback if subscription object not found locally
                                registrationRow(for: event)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.appBackground(for: colorScheme))
    }
    
    private func getSubscription(for id: String) -> Subscription? {
        viewModel.allSubscriptions.first(where: { $0.id == id })
    }
    
    private func registrationRow(for event: CalendarEvent) -> some View {
        HStack {
            Text(event.icon ?? "📦")
            Text(event.subscriptionName)
                .font(.sdLabelSemibold)
            Spacer()
            if let summary = viewModel.summary {
                Text(CurrencyFormatter.formatAmount(event.amount, currencyCode: summary.currency))
                    .font(.sdSmallBold)
            }
        }
        .padding(12)
        .background(Color.appSurface(for: colorScheme))
        .cornerRadius(12)
    }

    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("smart_insights".localized())
                    .font(.sdSubheadlineSemibold)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.insights, id: \.self) { insightKey in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.primaryBlue)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(getLocalizedInsight(insightKey))
                            .font(.sdLabel)
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if insightKey != viewModel.insights.last {
                        Divider()
                    }
                }
            }
        }
        .padding(24)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.appOutline(for: colorScheme), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helper Functions
    
    private func subscriptionsOnDay(_ date: Date) -> [CalendarEvent] {
        let dateString = formatDateToISO(date)
        return filteredEvents.filter { $0.paymentDate == dateString }
    }
    
    private func formatDateToISO(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func longDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let daysInMonth = monthRange.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }

    private func getLocalizedInsight(_ key: String) -> String {
        if key.contains(":") {
            let parts = key.split(separator: ":")
            if parts.count == 2 {
                let baseKey = String(parts[0])
                let param = String(parts[1])
                return String(format: baseKey.localized(), param.localized())
            }
        }
        return key.localized()
    }
    
    // MARK: - Premium Lock Overlay
    private var premiumLockOverlay: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.primaryBlue)
            }
            
            VStack(spacing: 8) {
                Text("premium_analytics_locked".localized())
                    .font(.sdSubheadlineSemibold)
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                
                Text("premium_analytics_desc".localized())
                    .font(.sdCaption)
                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onNavigateToPremium) {
                Text("unlock_with_premium".localized())
                    .font(.sdBodyBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.primaryBlue)
                    .cornerRadius(16)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground(for: colorScheme).opacity(0.4))
    }
}
