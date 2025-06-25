import SwiftUI
import Combine
import StoreKit

protocol SettingsStore {
    func get<T>(using key: String) -> T? where T: Decodable
    func set<T>(_ value: T?, for key: String) where T: Encodable
    func delete(key: String)
}

struct DummyStore: SettingsStore {
    func get<T>(using key: String) -> T? where T: Decodable { nil }
    func set<T>(_ value: T?, for key: String) where T: Encodable {}
    func delete(key: String) {}
}

extension UserDefaults: SettingsStore {
    func set<T>(_ t: T?, for key: String) where T: Encodable {
        let value = t as Any?
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                nserror(AppError.selfNil())
                return
            }
            
            self.set(value, forKey: key)
        }
    }
    
    func get<T>(using key: String) -> T? where T: Decodable {
        value(forKey: key) as? T
    }
    
    func delete(key: String) {
        removeObject(forKey: key)
    }
}

enum Tip: String, CaseIterable {
    case generous = "com.tip.1"
    case veryGenerous = "com.tip.3"
    case extremelyGenerous = "com.tip.5"
    case generousityOverload = "com.tip.10"
    
    var displayName: String {
        switch self {
        case .generous:
            return "$1 Tip"
        case .veryGenerous:
            return "$3 Tip"
        case .extremelyGenerous:
            return "$5 Tip"
        case .generousityOverload:
            return "$10 Tip"
        }
    }
    
    var thankYou: String {
        switch self {
        case .generous: return "Thank you for your support!"
        case .veryGenerous: return "You make the world a better place"
        case .extremelyGenerous: return "You're an absolute legend!"
        case .generousityOverload: return "Your generosity means the world to me!"
        }
    }
    
    var emoji: String {
        switch self {
        case .generous: return "😀"
        case .veryGenerous: return "🥹"
        case .extremelyGenerous: return "🫵"
        case .generousityOverload: return "😮"
        }
    }
}

enum AnimationUsageOption: String, CaseIterable {
    case on
    case off
    case system
    
    fileprivate var storage: Bool? {
        switch self {
        case .on: true
        case .off: false
        case .system: nil
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
}

extension AnimationUsageOption {
    fileprivate init(rawValue: Bool?) {
        self = switch rawValue {
        case .some(true): .on
        case .some(false): .off
        case .none: .system
        }
    }
}

class SettingsController: ObservableObject {
    private enum Key: String {
        case backgroundMatchesFlask
        case usesAnimations
        case theme
    }
    
    // MARK: - Properties
    
    // Public
    @MainActor
    @Published var tips: [Product]? = nil
    
    @MainActor
    @Published var purchase: Tip?
    
    @Published var backgroundMatchesFlaskValue: Bool {
        didSet {
            store.set(backgroundMatchesFlaskValue, for: Key.backgroundMatchesFlask.rawValue)
        }
    }
    
    @Published var animationUsageOption: AnimationUsageOption {
        didSet {
            let key = Key.usesAnimations.rawValue
            store.set(animationUsageOption.storage, for: key)
        }
    }
    
    @Published var theme: String {
        didSet {
            store.set(theme, for: Key.theme.rawValue)
        }
    }
    
    // Private
    private let store: SettingsStore
    private var subscriptions = Set<AnyCancellable>()
    
    
    // Convenience
    var backgroundMatchesFlask: Bool {
        guard animationUsageOption != .system else {
            return !lowPowerMode
        }
        
        return backgroundMatchesFlaskValue
    }
    
    var lowPowerMode: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    var shouldAnimate: Bool {
        animationUsageOption.storage ?? !lowPowerMode
    }
    
    // Theme Colors
    var primaryBackgroundColor: Color {
        Color(theme + "_primary_background")
    }
    
    var secondaryBackgroundColor: Color {
        Color(theme + "_secondary_background")
    }
    
    var tertiaryBackgroundColor: Color {
        Color(theme + "_tertiary_background")
    }
    
    var primaryLabelColor: Color {
        Color(theme + "_primary_label")
    }
    
    var secondaryLabelColor: Color {
        Color(theme + "_secondary_label")
    }
    
    var tertiaryLabelColor: Color {
        Color(theme + "_tertiary_label")
    }
    
    // MARK: - Initializers
    
    init(store: SettingsStore = UserDefaults.standard) {
        self.store = store
        
        self.backgroundMatchesFlaskValue = store.get(using: Key.backgroundMatchesFlask.rawValue) ?? true
        self.animationUsageOption = .init(rawValue: store.get(using: Key.usesAnimations.rawValue))
        self.theme = store.get(using: Key.theme.rawValue) ?? "std"
        
        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] notification in
                self.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Functions
    
    @MainActor
    func requestProducts() async {
        do {
            let productArr = try await Product.products(for: Tip.allCases.map(\.rawValue))
            self.tips = productArr.sorted(by: { $0.price < $1.price })
        } catch {
            nserror(error)
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async -> StoreKit.Transaction? {
        do {
            switch try await product.purchase() {
            case let .success(verification):
                if let tip = Tip(rawValue: product.id) {
                    withAnimation {
                        self.purchase = tip
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.purchase = nil
                        }
                    }
                }
                return try verification.payloadValue
            default:
                return nil
            }
        } catch {
            nserror(error)
            return nil
        }
    }
    
    func requestReview() {
        if let current = UIWindowScene.current {
            SKStoreReviewController.requestReview(in: current)
        } else {
            nserror("Unable to get current window scene.")
        }
    }
}
