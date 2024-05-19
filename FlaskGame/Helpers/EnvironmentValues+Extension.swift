import SwiftUI

struct IsPhoneKey: EnvironmentKey {
    static let defaultValue = UIDevice.current.userInterfaceIdiom == .phone
}

struct ApplicationNameKey: EnvironmentKey {
    static var defaultValue: String { AppConstants.name ?? "Flask Master" }
}

extension EnvironmentValues {
    var isPhone: Bool {
        get { self[IsPhoneKey.self] }
    }
    
    var applicationName: String {
        get { self[ApplicationNameKey.self] }
    }
}
