import SwiftUI

struct FlaskEffect: Animatable, ViewModifier {
    private var clipAmount: Double
    
    var animatableData: Double {
        get { clipAmount }
        set { clipAmount = newValue }
    }
    
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
