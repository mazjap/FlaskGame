import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

protocol AdControllerDelegate: AnyObject {
    func giveReward()
}

class AdController: NSObject, ObservableObject {
    @MainActor
    @Published var isDisplayingAd = false
    
    weak var delegate: AdControllerDelegate?
    
    @MainActor
    private(set) var additionalFlaskAd: RewardedAd?
    
    private var newFlaskId: String {
        let test = "ca-app-pub-3940256099942544/1712485313" // Test ad unit ID
        
        #if DEBUG
        return test
        #else
        guard let url = Bundle.main.url(forResource: "AdMob-Info", withExtension: "plist"),
              let plist = NSDictionary(contentsOf: url) else {
            return test
        }
        
        return (plist.object(forKey: "new-flask-key") as? String) ?? test
        #endif
    }
    
    @MainActor
    func displayAd() throws {
        guard let additionalFlaskAd = additionalFlaskAd else {
            asyncRefreshAd()
            throw AppError.noData("Ad not yet loaded")
        }
        
        guard let rootViewController = UIApplication.shared.rootViewController else {
            throw AppError.noData("No root view controller available")
        }
        
        // Check if we can present the ad
        do {
            try additionalFlaskAd.canPresent(from: rootViewController)
        } catch {
            throw AppError.noData("Cannot present ad: \(error.localizedDescription)")
        }
        
        additionalFlaskAd.present(from: rootViewController) {
            nslog("Ad has been presented")
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
        Task.detached { [weak self] in
            do {
                try await self?.refreshAd()
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
            
            await MainActor.run { [weak self] in
                self?.additionalFlaskAd = newAd
            }
            
            nslog("Ad loaded successfully")
        } catch {
            nslog("Ad load failed: \(error)")
            
            if retryCount > 0 {
                nslog("Retrying ad load. Attempts remaining: \(retryCount)")
                try await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds
                try await refreshAd(retryCount: retryCount - 1)
            } else {
                // Handle specific error cases
                if error.localizedDescription.contains("No ad to show") {
                    throw AppError.noAds("No ads available. If you have an adblocker, try disabling it")
                } else {
                    throw error
                }
            }
        }
    }
}

extension AdController: FullScreenContentDelegate {
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        nslog("User clicked ad")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        nslog("Ad dismissed")
        Task { @MainActor in
            self.toggleDisplayingAd(false)
        }
        
        // Preload next ad
        asyncRefreshAd()
    }
    
    @MainActor
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        nslog("Ad impression recorded")
        giveReward()
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        nslog("Ad will present")
        Task { @MainActor in
            self.toggleDisplayingAd(true)
        }
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        nserror("Ad failed to present: \(error)")
        Task { @MainActor in
            self.toggleDisplayingAd(false)
        }
    }
}

extension AdController: AdMetadataDelegate {
    func adMetadataDidChange(_ ad: AdMetadataProvider) {
        nslog("Ad metadata changed:")
        
        guard let metadata = ad.adMetadata else {
            nslog("No metadata available")
            return
        }
        
        metadata.forEach { key, value in
            nslog("Metadata - \(key): \(value)")
        }
    }
}
