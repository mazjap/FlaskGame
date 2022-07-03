import SwiftUI

// Src: (95% A11y) https://sashamaps.net/docs/resources/20-colors/
enum FlaskColor: String, CaseIterable, Identifiable {
    case apricot
    case beige
    case black
    case blue
    case brown
    case cyan
    case green
    case grey
    case levender
    case lime
    case magenta
    case maroon
    case mint
    case navy
    case olive
    case orange
    case pink
    case purple
    case red
    case teal
    case white
    case yellow
    
    var uiColor: UIColor {
        switch self {
        case .blue:
            return UIColor(hex: "#4363d8")!
        case .green:
            return UIColor(hex: "#3cb44b")!
        case .orange:
            return UIColor(hex: "#f58231")!
        case .purple:
            return UIColor(hex: "#911eb4")!
        case .red:
            return UIColor(hex: "#e6194b")!
        case .maroon:
            return UIColor(hex: "#800")!
        case .brown:
            return UIColor(hex: "#9A6324")!
        case .olive:
            return UIColor(hex: "#880")!
        case .teal:
            return UIColor(hex: "#469990")!
        case .navy:
            return UIColor(hex: "#000075")!
        case .black:
            return UIColor(hex: "#00")!
        case .yellow:
            return UIColor(hex: "#ffe119")!
        case .lime:
            return UIColor(hex: "#bfef45")!
        case .cyan:
            return UIColor(hex: "#42d4f4")!
        case .magenta:
            return UIColor(hex: "#f032e6")!
        case .grey:
            return UIColor(hex: "#a9")!
        case .pink:
            return UIColor(hex: "#fabed4")!
        case .apricot:
            return UIColor(hex: "#ffd8b1")!
        case .beige:
            return UIColor(hex: "#fffac8")!
        case .mint:
            return UIColor(hex: "#afc")!
        case .levender:
            return UIColor(hex: "#dcbeff")!
        case .white:
            return UIColor(hex: "#ff")!
        }
    }
    
    var color: Color {
        .init(uiColor: uiColor)
    }
    
    var id: String {
        rawValue
    }
    
    static var random: Self {
        allCases.randomElement() ?? .green
    }
    
    static var subsetRandom: Self {
        subsetCases.randomElement() ?? .green
        
    }
    
    static var subsetCases: [Self] {
        [
            .red,
            .green,
            .blue,
            .purple,
            .orange
        ]
    }
}
