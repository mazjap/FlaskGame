import SwiftUI

struct VerticalLabelStyle: LabelStyle {
    enum Order {
        case iconThenTitle
        case titleThenIcon
    }
    
    private let order: Order
    
    init(ordered order: Order = .iconThenTitle) {
        self.order = order
    }
    
    static func vertical(ordered order: Order = .iconThenTitle) -> Self {
        VerticalLabelStyle(ordered: order)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            switch order {
            case .iconThenTitle:
                configuration.icon
                configuration.title
            case .titleThenIcon:
                configuration.title
                configuration.icon
            }
        }
        .font(.headline)
    }
}

extension LabelStyle where Self == VerticalLabelStyle {
    static func vertical(ordered order: VerticalLabelStyle.Order = .iconThenTitle) -> VerticalLabelStyle {
        VerticalLabelStyle(ordered: order)
    }
}
