import SwiftUI

// MARK: - Help Center
struct HelpCenterScreen: View {
    let onBack: () -> Void
    
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    
    struct FAQItem: Identifiable {
        let id = UUID()
        let questionKey: String
        let answerKey: String
    }
    
    let faqs: [FAQItem] = [
        FAQItem(questionKey: "faq_q1", answerKey: "faq_a1"),
        FAQItem(questionKey: "faq_q2", answerKey: "faq_a2"),
        FAQItem(questionKey: "faq_q3", answerKey: "faq_a3"),
        FAQItem(questionKey: "faq_q4", answerKey: "faq_a4"),
        FAQItem(questionKey: "faq_q5", answerKey: "faq_a5"),
        FAQItem(questionKey: "faq_q6", answerKey: "faq_a6"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                        .frame(width: 44, height: 44)
                        .background(Color.appSurface(for: colorScheme))
                        .clipShape(Circle())
                }
                Spacer()
                Text("help_center_title".localized())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Search
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(Color.appOnBackground(for: colorScheme).opacity(0.4))
                        
                        TextField("help_search_placeholder".localized(), text: $searchText)
                            .font(.system(size: 16))
                            .foregroundColor(Color.appOnBackground(for: colorScheme))
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 45)
                    .background(Color.appSurface(for: colorScheme))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                    )
                    
                    // Popular Questions Label
                    Text("popular_questions".localized())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    // FAQ List
                    VStack(spacing: 12) {
                        let filteredFaqs = faqs.filter { faq in
                            searchText.isEmpty || 
                            faq.questionKey.localized().lowercased().contains(searchText.lowercased()) ||
                            faq.answerKey.localized().lowercased().contains(searchText.lowercased())
                        }
                        
                        ForEach(filteredFaqs) { faq in
                            DisclosureGroup {
                                Text(faq.answerKey.localized())
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                    .lineSpacing(4)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } label: {
                                Text(faq.questionKey.localized())
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                                    .multilineTextAlignment(.leading)
                                    .padding(.vertical, 4)
                            }
                            .accentColor(Color.appOnSurfaceVariant(for: colorScheme))
                            .padding(20)
                            .background(Color.appSurface(for: colorScheme))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.appOutline(for: colorScheme).opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        if filteredFaqs.isEmpty && !searchText.isEmpty {
                            VStack(spacing: 12) {
                                Spacer().frame(height: 40)
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                Text("no_results".localized())
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
}

// MARK: - Privacy Policy
struct PrivacyPolicyScreen: View {
    let onBack: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    struct PolicySection: Identifiable {
        let id = UUID()
        let order: Int
        let titleKey: String
        let contentKey: String
    }
    
    let sections: [PolicySection] = [
        PolicySection(order: 1, titleKey: "privacy_title_1", contentKey: "privacy_content_1"),
        PolicySection(order: 2, titleKey: "privacy_title_2", contentKey: "privacy_content_2"),
        PolicySection(order: 3, titleKey: "privacy_title_3", contentKey: "privacy_content_3"),
        PolicySection(order: 4, titleKey: "privacy_title_4", contentKey: "privacy_content_4"),
        PolicySection(order: 5, titleKey: "privacy_title_5", contentKey: "privacy_content_5"),
        PolicySection(order: 6, titleKey: "privacy_title_6", contentKey: "privacy_content_6"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                        .frame(width: 44, height: 44)
                        .background(Color.appSurface(for: colorScheme))
                        .clipShape(Circle())
                }
                Spacer()
                Text("privacy_policy_title".localized())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("privacy_last_updated".localized())
                        .font(.system(size: 14))
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    
                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.titleKey.localized())
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primaryBlue)
                            
                            Text(section.contentKey.localized())
                                .font(.system(size: 16))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .lineSpacing(6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    }
                    
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
}

// MARK: - Upcoming Subscriptions
struct UpcomingSubscriptionsScreen: View {
    @StateObject private var viewModel = SubscriptionsViewModel()
    @EnvironmentObject var notificationsViewModel: NotificationsViewModel
    
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
    let onNavigateToSubscriptionDetail: (String) -> Void
    let onNavigateToNotifications: () -> Void
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("upcoming_payments".localized())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    Spacer()
                    NotificationBellButton(
                        unreadCount: notificationsViewModel.unreadCount,
                        onTap: onNavigateToNotifications
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer().frame(height: 16)
                
                if viewModel.isLoading {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(0..<6, id: \.self) { _ in
                                SkeletonCard()
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            let tenDaysFromNow = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
                            let upcoming = viewModel.activeSubscriptions
                                .compactMap { sub -> (Subscription, Date)? in
                                    guard let date = sub.getNextRenewalDate() else { return nil }
                                    return (sub, date)
                                }
                                .filter { $0.1 <= tenDaysFromNow }
                                .sorted { $0.1 < $1.1 }
                            
                            if upcoming.isEmpty {
                                VStack(spacing: 12) {
                                    Spacer().frame(height: 60)
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                    Text("no_upcoming_payments".localized())
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                ForEach(upcoming, id: \.0.id) { (sub, _) in
                                    SubscriptionCard(
                                        subscription: sub,
                                        currency: currency,
                                        showCountdown: true,
                                        onTap: { onNavigateToSubscriptionDetail(sub.id) }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadSubscriptions()
        }
    }
}
