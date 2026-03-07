import Foundation
import GoogleMobileAds
import UIKit

class AdMobManager: NSObject, FullScreenContentDelegate {
    static let shared = AdMobManager()
    
    // Ad Unit IDs
    #if DEBUG
    private let isTestMode = true
    private let interstitialID = "ca-app-pub-3940256099942544/4411468910" // iOS Test ID
    static let bannerID = "ca-app-pub-3940256099942544/2934735716" // iOS Test ID
    #else
    // IMPORTANT: These MUST be iOS-specific IDs from AdMob console. 
    // Android IDs will cause "Ad unit doesn't match format" errors.
    private let isTestMode = false 
    private let interstitialID = "ca-app-pub-9378769298209012/5204853779"
    static let bannerID = "ca-app-pub-9378769298209012/4825075246"
    #endif
    
    private var interstitial: InterstitialAd?
    private var subscriptionCount = 0
    private let threshold = 3
    
    private override init() {
        super.init()
        loadInterstitial()
    }
    
    func setup() {
        print("AdMob: isTestMode = \(isTestMode)")
        #if DEBUG
        print("AdMob: Build Configuration = DEBUG")
        #else
        print("AdMob: Build Configuration = RELEASE")
        #endif
        
        MobileAds.shared.start(completionHandler: nil)
        
        // Add test device ID from logs
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["9400471256a1432f84713ae88484e034"]
        print("AdMob setup completed with test device ID.")
    }
    
    func loadInterstitial() {
        print("AdMob: Attempting to load interstitial with ID: \(interstitialID)")
        let request = Request()
        InterstitialAd.load(with: interstitialID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    func incrementSubscriptionCount(from viewController: UIViewController, isPremium: Bool) {
        guard !isPremium else { return }
        
        subscriptionCount += 1
        print("Subscription count: \(subscriptionCount)")
        
        if subscriptionCount >= threshold {
            showInterstitial(from: viewController)
            subscriptionCount = 0
        }
    }
    
    private func showInterstitial(from viewController: UIViewController) {
        if let interstitial = interstitial {
            print("Presenting interstitial ad...")
            interstitial.present(from: viewController)
        } else {
            print("Interstitial ad wasn't ready to present. Loading again...")
            loadInterstitial()
        }
    }
    
    // MARK: - FullScreenContentDelegate
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        loadInterstitial() // Load next one
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
        loadInterstitial()
    }
}
