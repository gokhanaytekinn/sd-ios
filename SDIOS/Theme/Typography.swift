import SwiftUI

extension Font {
    private static func scaledSize(_ size: CGFloat) -> CGFloat {
        let baselineWidth: CGFloat = 390 // iPhone 14/15 baseline
        let currentWidth = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? baselineWidth
        let scale = currentWidth / baselineWidth
        // Clamp scale between 0.85 and 1.2 to prevent extreme sizes
        let clampedScale = max(0.85, min(scale, 1.2))
        return size * clampedScale
    }
    
    static let sdTitle = Font.system(size: scaledSize(32), weight: .bold)
    static let sdHeadline = Font.system(size: scaledSize(24), weight: .bold)
    static let sdSubheadline = Font.system(size: scaledSize(20), weight: .bold)
    static let sdBody = Font.system(size: scaledSize(16), weight: .regular)
    static let sdBodyMedium = Font.system(size: scaledSize(16), weight: .medium)
    static let sdBodyBold = Font.system(size: scaledSize(16), weight: .bold)
    static let sdCaption = Font.system(size: scaledSize(14), weight: .regular)
    static let sdCaptionMedium = Font.system(size: scaledSize(14), weight: .medium)
    static let sdCaptionBold = Font.system(size: scaledSize(14), weight: .bold)
    static let sdSmall = Font.system(size: scaledSize(12), weight: .regular)
    static let sdSmallMedium = Font.system(size: scaledSize(12), weight: .medium)
    static let sdSmallSemibold = Font.system(size: scaledSize(12), weight: .semibold)
    static let sdLabel = Font.system(size: scaledSize(10), weight: .semibold)
    static let sdLabelSmall = Font.system(size: scaledSize(11), weight: .medium)
    static let sdHero = Font.system(size: scaledSize(36), weight: .black)
}
