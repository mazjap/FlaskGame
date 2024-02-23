import Foundation

private enum BundleConstantKey: String {
    case applicationName
    case applicationVersion
    case applicationBuild
    case id
    
    var rawValue: String {
        switch self {
        case .applicationName:
            kCFBundleNameKey as String
        case .applicationVersion:
            "CFBundleShortVersionString"
        case .applicationBuild:
            kCFBundleVersionKey as String
        case .id:
            kCFBundleIdentifierKey as String
        }
    }
}

enum AppConstants {
    private static let infoDict = Bundle.main.infoDictionary ?? [:]
    
    static private let versionString = {
        infoDict[BundleConstantKey.applicationVersion.rawValue] as? String
    }()
    
    static let name = {
        infoDict[BundleConstantKey.applicationName.rawValue] as? String
    }()
    
    static let bundleId = {
        infoDict[BundleConstantKey.id.rawValue] as? String
    }()
    
    static let version: (major: Int, minor: Int, patch: Int)? = {
        guard let versionString else { return nil }
        
        let subVersionStrings = versionString.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".")
        let subVersions = subVersionStrings.map { Int($0) }
        let subVersionCount = subVersions.count
        
        guard subVersionCount >= 1, let major = subVersions[0] else { return nil }
        
        return (major, subVersions.at(1) ?? 0, subVersions.at(2) ?? 0)
    }()
}

extension Array {
    /// Access element of array at index.
    /// Safely returns nil if index is out of range
    func at(_ index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        
        return self[index]
    }
    
    func at<T>(_ index: Int) -> T? where Element == T? {
        guard index >= 0, index < count else { return nil }
        
        return self[index]
    }
}
