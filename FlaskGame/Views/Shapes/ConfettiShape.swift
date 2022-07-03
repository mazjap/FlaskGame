import SwiftUI

enum ConfettiShape: Hashable, Identifiable {
    case flask
    case ellipse(aspectRatio: Double)
    case rectangle(cornerRadius: Double = 0, aspectRatio: Double)
    case capsule(aspectRatio: Double)
    case sfSymbol(symbolName: String)
    
    var id: String {
        switch self {
        case .flask:
            return "shape:flask"
        case let .ellipse(aspectRatio):
            return "shape:ellipse:\(aspectRatio)"
        case let .rectangle(cornerRadius, aspectRatio):
            return "shape:roundedrectangle:\(cornerRadius):\(aspectRatio)"
        case let .capsule(aspectRatio):
            return "shape:capsule:\(aspectRatio)"
        case let .sfSymbol(symbolName):
            return "img:\(symbolName)"
        }
    }
    
    @ViewBuilder
    var stroked: some View {
        switch self {
        case .flask:
            FlaskShape()
                .stroke()
                .aspectRatio(0.4, contentMode: .fit)
        case let .ellipse(aspectRatio):
            Ellipse()
                .stroke()
                .aspectRatio(aspectRatio, contentMode: .fit)
        case let .capsule(aspectRatio):
            Capsule()
                .stroke()
                .aspectRatio(aspectRatio, contentMode: .fit)
        case let .rectangle(cornerRadius, aspectRatio):
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke()
                .aspectRatio(aspectRatio, contentMode: .fit)
        case let .sfSymbol(symbolName):
            Image(systemName: symbolName)
                .resizable()
                .scaledToFit()
        }
    }
    
    @ViewBuilder
    var filled: some View {
        switch self {
        case .flask:
            FlaskShape()
                .fill()
                .aspectRatio(0.4, contentMode: .fit)
        case let .ellipse(aspectRatio):
            Ellipse()
                .fill()
                .aspectRatio(aspectRatio, contentMode: .fit)
        case let .capsule(aspectRatio):
            Capsule()
                .fill()
                .aspectRatio(aspectRatio, contentMode: .fit)
        case let .rectangle(cornerRadius, aspectRatio):
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill()
                .aspectRatio(aspectRatio, contentMode: .fit)
        case let .sfSymbol(symbolName):
            Image(systemName: symbolName)
        }
    }
    
    static let circle = Self.ellipse(aspectRatio: 1)
    static let square = Self.rectangle(aspectRatio: 1)
    
    static func random(filled: Bool = false) -> ConfettiShape {
        allCases(filled: filled).randomElement() ?? .capsule(aspectRatio: 1.5)
    }
    
    static func allCases(filled: Bool = false) -> [ConfettiShape] {
        [
            .flask,
            .capsule(aspectRatio: 1.5),
            .sfSymbol(symbolName: "star" + (filled ? ".fill" : "")),
            .sfSymbol(symbolName: "moon" + (filled ? ".fill" : "")),
            .sfSymbol(symbolName: "drop" + (filled ? ".fill" : "")),
            .sfSymbol(symbolName: "heart" + (filled ? ".fill" : "")),
            .sfSymbol(symbolName: "rays")
        ]
    }
}

