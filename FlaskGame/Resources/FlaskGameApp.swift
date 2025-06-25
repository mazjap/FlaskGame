import SwiftUI
import GoogleMobileAds

// MARK: - Application's entry point

enum TrackingDisclosureStage: String, CaseIterable {
    case displayingATTInformation
    case presentingATTAuth
    case displayingUMPInformation
    case presentingUMPAuth
    case complete
    
    var isATT: Bool {
        switch self {
        case .displayingATTInformation, .presentingATTAuth: true
        default: false
        }
    }
    
    var isUMP: Bool {
        switch self {
        case .displayingUMPInformation, .presentingUMPAuth: true
        default: false
        }
    }
}

@main
struct FlaskGameApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @Namespace private var nspace
    @StateObject private var settings = SettingsController()
    @StateObject private var flasks = FlaskController()
    @AppStorage(.adDisclosureStage) private var disclosureStage: TrackingDisclosureStage = .displayingATTInformation
    
    init() {
        // Hides home indicator for app store screenshots (in debug only)
        UIViewController.swizzleIndicator()
        
        // Configure test devices
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["06e99044b53a4003ade2a294e299fe0d"]
        
        // Start Google Mobile Ads
        MobileAds.shared.start { status in
            status.adapterStatusesByClassName.forEach { (key, value) in
                
                guard value.state == .notReady else { return }
                nslog("\(key) is not ready. Latency: \(value.latency)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if disclosureStage == .complete {
                    GameView(flasks: flasks, settings: settings, namespace: nspace)
                } else {
                    AdConsentView(disclosureStage: $disclosureStage)
                }
            }
            .onChange(of: scenePhase) { _ in
                if scenePhase == .background {
                    flasks.save()
                }
            }
            .onChange(of: disclosureStage) { _ in
                nslog("Disclosure stage changed to: \(disclosureStage)")
            }
        }
    }
}
