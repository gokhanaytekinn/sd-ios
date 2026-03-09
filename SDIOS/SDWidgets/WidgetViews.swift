import SwiftUI
import WidgetKit

struct WidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(hex: "0F172A"), Color(hex: "1E293B")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct SubscriptionWidgetRow: View {
    let name: String
    let cost: String
    let date: String?
    let icon: String?
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                if let icon = icon, !icon.isEmpty {
                    Text(icon)
                        .font(.system(size: 16))
                } else {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let date = date {
                    Text(date)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text(cost)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
}

struct WidgetHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
}

