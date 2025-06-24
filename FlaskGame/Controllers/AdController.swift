import SwiftUI
import GoogleMobileAds

protocol AdControllerDelegate: AnyObject {
    func giveReward()
}

class AdController: NSObject, ObservableObject {
    @MainActor
    @Published var isDisplayingAd = false
    
    weak var delegate: AdControllerDelegate?
    
    @MainActor
    private(set) var additionalFlaskAd: RewardedAd!
    
    private var newFlaskId: String {
        let test = "ca-app-pub-3940256099942544/1712485313"
        
        guard let url = Bundle.main.url(forResource: "AdMob-Info", withExtension: "plist"),
              let plist = NSDictionary(contentsOf: url) else {
            return test
        }
        
        return (plist.object(forKey: "new-flask-key") as? String) ?? test
    }
    
    @MainActor
    func displayAd() throws {
        guard let additionalFlaskAd = additionalFlaskAd else {
            asyncRefreshAd()
            throw AppError.noData("Ad not yet loaded")
        }
        
        try additionalFlaskAd.canPresent(from: nil)
        additionalFlaskAd.present(from: nil) {
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
    private func giveReward() {
        delegate?.giveReward()
    }
    
    func asyncRefreshAd(errorHandler: (@MainActor (Error) -> Void)? = nil) {
        Task.detached {
            do {
                try await self.refreshAd()
            } catch {
                let handler = errorHandler ?? { error in
                    nserror(error)
                }
                
                await handler(error)
            }
        }
    }
    
    func refreshAd(retryCount: UInt = 2) async throws {
        do {
            let newAd = try await RewardedAd.load(with: newFlaskId, request: .init())
            newAd.fullScreenContentDelegate = self
            newAd.adMetadataDelegate = self
            
            await MainActor.run {
                self.additionalFlaskAd = newAd
            }
        } catch {
            if retryCount > 0 {
                try await refreshAd(retryCount: retryCount - 1)
            } else if error.localizedDescription == "Request Error: No ad to show from all configured ad networks." {
                throw AppError.noAds("If you have an adblocker, try disabling it")
            } else {
                throw error
            }
        }
    }
}

extension AdController: FullScreenContentDelegate {
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        nslog("User clicked ad...")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        nslog("Dismissing ad")
        self.toggleDisplayingAd(false)
        self.asyncRefreshAd()
    }
    
    @MainActor
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        nslog("Ad was impressive")
        giveReward()
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        nslog("Displaying ad to user...")
        self.toggleDisplayingAd(true)
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        nserror(error)
    }
}

extension AdController: AdMetadataDelegate {
    func adMetadataDidChange(_ ad: AdMetadataProvider) {
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
