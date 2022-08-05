import SwiftUI
import GoogleMobileAds

class AdController: NSObject, ObservableObject {
    @MainActor
    @Published var extraFlask = false
    @MainActor
    @Published var isDisplayingAd = false
    
    private var additionalFlaskAd: GADRewardedAd!
    
    private var newFlaskId: String {
        let test = "ca-app-pub-3940256099942544/1712485313"
        
        if inDebug {
            return test
        }
        
        guard let url = Bundle.main.url(forResource: "AdMob-Info", withExtension: "plist"),
              let plist = NSDictionary(contentsOf: url) else {
            return test
        }
        
        return (plist.object(forKey: "new_flask_key") as? String) ?? test
    }

    
    override init() {
        super.init()
        
        Task {
            do {
                try await refreshAd()
            } catch {
                nserror(error)
            }
        }
    }
    
    @MainActor
    func displayAd() throws {
        guard let additionalFlaskAd = additionalFlaskAd else {
            asyncRefreshAd()
            throw AppError.noData("Ad not yet loaded")
        }
        
        guard let rootVC = UIApplication.shared.rootViewController else {
            throw AppError.selfNil("Unable to get rootVC")
        }
        
        try additionalFlaskAd.canPresent(fromRootViewController: rootVC)
        
        additionalFlaskAd.present(fromRootViewController: rootVC) {
            print("Ad has been presented")
        }
    }
    
    @MainActor
    private func toggleDisplayingAd(_ bool: Bool? = nil) {
        guard let bool = bool else {
            isDisplayingAd.toggle()
            return
        }
        
        isDisplayingAd = bool
    }
    
    @MainActor
    private func addExtraFlask() {
        self.extraFlask = true
    }
    
    private func asyncRefreshAd() {
//        Task.detached {
//            do {
//                try await self.refreshAd()
//            } catch {
//                nserror(error)
//            }
//        }
    }
    
    private func refreshAd() async throws {
//        additionalFlaskAd = try await GADRewardedAd.load(withAdUnitID: newFlaskId, request: .init())
//        additionalFlaskAd.fullScreenContentDelegate = self
//        additionalFlaskAd.adMetadataDelegate = self
//        additionalFlaskAd.paidEventHandler = { value in
//            print("Ad value: \(value.value)")
//            print("Ad percision: \(value.precision)")
//        }
    }
}

extension AdController: GADFullScreenContentDelegate {
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        nslog("User clicked ad...")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        nslog("Displaying ad to user...")
        Task {
            await self.toggleDisplayingAd(false)
        }
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        nslog("Ad impression")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        nslog("Displaying ad to user...")
        Task {
            await self.toggleDisplayingAd(true)
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        nserror(error)
    }
}

extension AdController: GADAdMetadataDelegate {
    func adMetadataDidChange(_ ad: GADAdMetadataProvider) {
        print("Metadata changed:")
        
        guard let metadata = ad.adMetadata else {
            print("empty")
            return
        }
        
        metadata.forEach {
            print("\tkey: \($0.key)\n\tvalue: \($0.value)")
        }
    }
}
