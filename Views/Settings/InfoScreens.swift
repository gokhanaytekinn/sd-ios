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
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
                Text(NSLocalizedString("help_center_title", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                        TextField(NSLocalizedString("help_search_placeholder", comment: ""), text: $searchText)
                    }
                    .padding(12)
                    .background(Color.appSurface(for: colorScheme))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
                    )
                    
                    // Popular Questions
                    Text(NSLocalizedString("popular_questions", comment: ""))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                    
                    // Quick info cards
                    HStack(spacing: 12) {
                        infoCard(
                            icon: "plus.circle.fill",
                            title: NSLocalizedString("how_to_add", comment: ""),
                            desc: NSLocalizedString("how_to_add_desc", comment: "")
                        )
                        infoCard(
                            icon: "xmark.circle.fill",
                            title: NSLocalizedString("cancel_anytime", comment: ""),
                            desc: NSLocalizedString("cancel_anytime_desc", comment: "")
                        )
                    }
                    
                    // FAQ List
                    ForEach(faqs) { faq in
                        DisclosureGroup {
                            Text(NSLocalizedString(faq.answerKey, comment: ""))
                                .font(.system(size: 14))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .padding(.top, 8)
                        } label: {
                            Text(NSLocalizedString(faq.questionKey, comment: ""))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                        }
                        .padding(16)
                        .background(Color.appSurface(for: colorScheme))
                        .cornerRadius(12)
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
    
    private func infoCard(icon: String, title: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.primaryBlue)
            
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color.appOnBackground(for: colorScheme))
                .lineLimit(2)
            
            Text(desc)
                .font(.system(size: 11))
                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface(for: colorScheme))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appOutline(for: colorScheme).opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Privacy Policy
struct PrivacyPolicyScreen: View {
    let onBack: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    struct PolicySection: Identifiable {
        let id = UUID()
        let titleKey: String
        let contentKey: String
    }
    
    let sections: [PolicySection] = [
        PolicySection(titleKey: "privacy_title_1", contentKey: "privacy_content_1"),
        PolicySection(titleKey: "privacy_title_2", contentKey: "privacy_content_2"),
        PolicySection(titleKey: "privacy_title_3", contentKey: "privacy_content_3"),
        PolicySection(titleKey: "privacy_title_4", contentKey: "privacy_content_4"),
        PolicySection(titleKey: "privacy_title_5", contentKey: "privacy_content_5"),
        PolicySection(titleKey: "privacy_title_6", contentKey: "privacy_content_6"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appOnBackground(for: colorScheme))
                }
                Spacer()
                Text(NSLocalizedString("privacy_policy_title", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("privacy_last_updated", comment: ""))
                        .font(.system(size: 12))
                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                    
                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString(section.titleKey, comment: ""))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.appOnBackground(for: colorScheme))
                            
                            Text(NSLocalizedString(section.contentKey, comment: ""))
                                .font(.system(size: 14))
                                .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appSurface(for: colorScheme))
                        .cornerRadius(12)
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground(for: colorScheme).ignoresSafeArea())
    }
}

// MARK: - Upcoming Subscriptions
struct UpcomingSubscriptionsScreen: View {
    @StateObject private var viewModel = SubscriptionsViewModel()
    
    @AppStorage("selectedCurrency") private var currency: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
    let onNavigateToSubscriptionDetail: (String) -> Void
    
    var body: some View {
        ZStack {
            Color.appBackground(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text(NSLocalizedString("upcoming_payments", comment: ""))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.appOnBackground(for: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                Spacer().frame(height: 16)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(.primaryBlue)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            let upcoming = viewModel.activeSubscriptions
                                .compactMap { sub -> (Subscription, Date)? in
                                    guard let date = sub.getNextRenewalDate() else { return nil }
                                    return (sub, date)
                                }
                                .sorted { $0.1 < $1.1 }
                            
                            if upcoming.isEmpty {
                                VStack(spacing: 12) {
                                    Spacer().frame(height: 60)
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color.appOnSurfaceVariant(for: colorScheme))
                                    Text(NSLocalizedString("no_upcoming_payments", comment: ""))
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
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadSubscriptions()
        }
    }
}
