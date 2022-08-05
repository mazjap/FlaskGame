import SwiftUI
import FirebaseCore
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
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        GADMobileAds.sharedInstance()
            .requestConfiguration
            .testDeviceIdentifiers = ["8e22988cfc882ab43b0112b8a514d7d0"]
        GADMobileAds.sharedInstance().start { status in
            status.adapterStatusesByClassName.forEach { (key, value) in
                guard value.state == .notReady else { return }
                print(value.description)
                nslog("\(key) is not ready. Latency: \(value.latency)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GameView(flasks: flasks, settings: settings, namespace: nspace)
                .onChange(of: scenePhase) { newValue in
                    if newValue == .background {
                        flasks.save()
                    }
                }
        }
    }
}

// MARK: - Custom Environment Values

struct IsPhoneKey: EnvironmentKey {
    static let defaultValue = UIDevice.current.userInterfaceIdiom == .phone
}

struct ApplicationNameKey: EnvironmentKey {
    static var defaultValue: String { Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Flask Master"
    }
}

extension EnvironmentValues {
    var isPhone: Bool {
        get { self[IsPhoneKey.self] }
    }
    
    var applicationName: String {
        get { self[ApplicationNameKey.self] }
    }
}
