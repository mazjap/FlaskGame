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
    
    @Published var backgroundMatchesFlaskValue: Bool {
        didSet {
            store.set(backgroundMatchesFlaskValue, for: Key.backgroundMatchesFlask.rawValue)
        }
    }
    
    @Published var usesAnimationsValue: Bool? {
        didSet {
            let key = Key.usesAnimations.rawValue
            guard let usesAnimations = usesAnimationsValue else {
                store.delete(key: key)
                return
            }
            
            store.set(usesAnimations, for: key)
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
        guard usesAnimationsValue != nil else {
            return !lowPowerMode
        }
        
        return backgroundMatchesFlaskValue
    }
    
    var lowPowerMode: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    var shouldAnimate: Bool {
        usesAnimationsValue ?? !lowPowerMode
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
        self.usesAnimationsValue = store.get(using: Key.usesAnimations.rawValue)
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
    
    func purchase(_ product: Product) async -> StoreKit.Transaction? {
        do {
            let result = try await product.purchase()
            return nil
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
