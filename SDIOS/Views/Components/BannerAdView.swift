import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    @Binding var isLoaded: Bool
    
    class Coordinator: NSObject, BannerViewDelegate {
        var parent: BannerAdView
        
        init(_ parent: BannerAdView) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("AdMob: Banner ad received successfully.")
            DispatchQueue.main.async {
                self.parent.isLoaded = true
            }
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("AdMob: Banner ad failed to load with error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.parent.isLoaded = false
            }
        }

        func bannerViewDidRecordImpression(_ bannerView: BannerView) {
            print("AdMob: Banner ad impression recorded.")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> BannerView {
        // Use standard banner size for better compatibility
        let banner = BannerView(adSize: AdSizeBanner)
        
        banner.adUnitID = AdMobManager.bannerID
        banner.delegate = context.coordinator
        
        // Find the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootVC
        }
        
        banner.load(Request())
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
}
