import SwiftUI

struct FlaskEffect: ViewModifier {
    private let clipAmount: Double
    
    init(completion: Double) {
        self.clipAmount = completion
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(PartRectangle(
                verticalCompletion: clipAmount,
                alignedTo: .bottom
            ))
    }
}
