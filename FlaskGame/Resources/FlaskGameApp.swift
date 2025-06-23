import SwiftUI
import GoogleMobileAds

// MARK: - Application's entry point

@main
struct FlaskGameApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @Namespace private var nspace
    @StateObject private var settings = SettingsController()
    @StateObject private var flasks = FlaskController()
    
    init() {
        // Hides home indicator for app store screenshots (in debug only)
        UIViewController.swizzleIndicator()
        
        GADMobileAds.sharedInstance()
            .requestConfiguration
            .testDeviceIdentifiers = ["8e22988cfc882ab43b0112b8a514d7d0"]
        GADMobileAds.sharedInstance().start { status in
            status.adapterStatusesByClassName.forEach { (key, value) in
                guard value.state == .notReady else { return }
                
                nslog("\(key) is not ready. Latency: \(value.latency)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GameView(flasks: flasks, settings: settings, namespace: nspace)
                .onChange(of: scenePhase) { _ in
                    if scenePhase == .background {
                        flasks.save()
                    }
                }
        }
    }
}
