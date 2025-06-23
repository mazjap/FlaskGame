import SwiftUI

struct FlaskView: View {
    @Binding private var offsetWave: Bool
    
    let flask: Flask
    let isSelected: Bool
    
    init(flask: Flask, isSelected: Bool = false, offsetWave: Binding<Bool> = .constant(false)) {
        self.flask = flask
        self.isSelected = isSelected
        
        self._offsetWave = offsetWave
    }
    
    private var colors: some View {
        VStack(spacing: 0) {
            ForEach(
                flask.colors
                    .reversed()
                    .enumerated()
                    .map { ($0.offset, $0.element) },
                id: \.0
            ) { (position, color) in
                color.color
            }
        }
        .allowsHitTesting(true)
        .labelStyle(.iconOnly)
    }
    
    var body: some View {
        let shape = FlaskShape()
        let aspectRatio: Double = if case .normal = flask { 0.25 } else { 1 }
        
        shape
            .stroke(.black, lineWidth: isSelected ? 6 : 2)
            .overlay {
                shape
                .stroke(isSelected ? .white : .black, lineWidth: isSelected ? 2 : 0)
            }
            .background(
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(Material.regular)
                        
                        VStack(spacing: 0) {
                            let colorsScale: Double =
                                if case .normal = flask {
                                    min(1, Double(flask.colors.count) / 4)
                                } else {
                                    1
                                }
                            
                            
                            colors
                                .frame(height: geometry.size.height * colorsScale)
                                .clipShape(Waves(offset: offsetWave ? .pi / 8 : 0))
                        }
                    }
                }
                .clipShape(shape)
            )
            .contentShape(shape)
            .transition(.identity)
            .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

struct FlaskView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            FlaskView(flask: .normal(.init(colors: [.red, .green, .grey, .blue])))
            FlaskView(flask: .tiny(.init(.orange)))
        }
    }
}
