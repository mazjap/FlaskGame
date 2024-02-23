import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPhone) private var isPhone
    @Environment(\.applicationName) private var appName
    @ObservedObject private var settings: SettingsController
    
    init(settings: SettingsController) {
        self._settings = .init(initialValue: settings)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section {
                        let animationDict: TwoWayDictionary<String, Bool?> = [
                            "On": true,
                            "Off": false,
                            "System": nil
                        ]
                        
                        Picker(
                            "Use Animations",
                            selection: $settings.usesAnimationsValue.map(
                                to: { animationDict[$0] ?? "" },
                                from: { animationDict[$0] ?? nil }
                            )
                        ) {
                            ForEach(animationDict.st.keys.sorted(), id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        let matchBackgroundBinding: Binding<Bool> = {
                            if let usesAnimations = settings.usesAnimationsValue {
                                return usesAnimations
                                ? $settings.backgroundMatchesFlaskValue
                                : .constant(false)
                            } else {
                                return Binding { !settings.lowPowerMode }
                            }
                        }()
                        
                        Toggle(isOn: matchBackgroundBinding) {
                            Text("Match Background Color")
                        }
                        .opacity(settings.shouldAnimate ? 1 : 0.75)
                        .disabled(!(settings.shouldAnimate))
                    } header: {
                        Text("Animations & Performance")
                    }
                    
//                    Section {
//
//                    } header: {
//                        Text("Theme")
//                    }
                    
                    Section {
                        Text("👋 I make free games and apps without In-App Purchases - aside from tips. Consider rating if you enjoy this game (or leave feedback if you don't)!")
                        
                        List(
                            [Thing.text(
                                "Give a Tip",
                                children: (settings.tips ?? [])
                                    .map { Thing.product($0) }
                            )],
                            children: \.children
                        ) {
                            switch $0 {
                            case let .text(txt, _):
                                Text(txt)
                            case let .product(product, _):
                                Button {
                                    Task {
                                        await settings.purchase(product)
                                    }
                                } label: {
                                    Text("$" + product.price.formatted())
                                }
                            }
                        }
                        
                        Button("Rate \(appName)") {
                            settings.requestReview()
                        }
                        
                        Button {
                            guard let str = "mailto:\(Constant.email)?subject=\(appName) Feedback"
                                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                  let url = URL(string: str) else {
                                print("Invalid email")
                                return
                            }
                            
                            openURL(url) { accepted in
                                nslog(accepted ? "Opened email url" : "Failed to open email url")
                            }
                        } label: {
                            Text("Leave Feedback")
                        }
                    } header: {
                        Text("Support")
                    }
                }
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Text("Done")
                            }
                        }
                    }
                }
                
                if let tip = settings.purchase {
                    Group {
                        Color.blue
                            .cornerRadius(20)
                            .opacity(0.8)
                        
                        VStack {
                            Text(tip.emoji)
                                .font(.system(size: 80))
                            
                            Text(tip.thankYou)
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    }
                    .frame(width: 200, height: 200)
                }
            }
        }
        .task {
            if settings.tips?.isEmpty ?? true {
                await settings.requestProducts()
            }
        }
    }
}

#Preview {
    SettingsView(settings: SettingsController(store: DummyStore()))
}

indirect
enum Thing: Identifiable {
    case text(String, children: [Thing]? = nil)
    case product(Product, children: [Thing]? = nil)
    
    var children: [Thing]? {
        switch self {
        case let .text(_, children):
            return children
        case let .product(_, children):
            return children
        }
    }
    
    var id: String {
        switch self {
        case let .text(text, _):
            return text
        case let .product(tip, _):
            return tip.id
        }
    }
}
