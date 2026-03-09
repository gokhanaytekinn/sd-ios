import SwiftUI
import WidgetKit

struct WidgetBackground: View {
    var body: some View {
        Color.black.opacity(0.8) // Darker, more neutral background
    }
}

struct SubscriptionWidgetRow: View {
    let name: String
    let cost: String
    let date: String?
    let icon: String?
    let cycle: BillingCycle
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            brandIconView
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let date = date {
                    Text(date)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(cost)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(cycle == .monthly ? "Aylık" : "Yıllık")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var brandIconView: some View {
        if let info = getBrandIconInfo(name) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(info.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(info.color.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 36, height: 36)
                BrandIconView(name: info.icon, color: info.color)
                    .frame(width: 20, height: 20)
            }
        } else {
            let brandColor = getBrandColor(name)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(brandColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(brandColor.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 36, height: 36)
                Text(name.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(brandColor)
            }
        }
    }
    
    private func getBrandIconInfo(_ name: String) -> (icon: String, color: Color)? {
        let map: [String: (String, Color)] = [
            "netflix":  ("netflix",  Color(hex: "E50914")),
            "spotify":  ("spotify",  Color(hex: "1DB954")),
            "youtube":  ("youtube",  Color(hex: "FF0000")),
            "google":   ("google",   Color(hex: "4285F4")),
            "amazon":   ("amazon",   Color(hex: "00A8E1")),
            "hbo max":  ("hbomax",   Color(hex: "5A2E81")),
            "cursor":   ("cursor",   Color.white),
            "claude":   ("claude",   Color(hex: "E56038")),
        ]
        return map[name.lowercased()]
    }
    
    private func getBrandColor(_ name: String) -> Color {
        let hash = name.lowercased().hashValue
        let colors: [Color] = [.blue, .purple, .orange, .pink, .teal, .indigo]
        let index = abs(hash) % colors.count
        return colors[index]
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

