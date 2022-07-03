import SwiftUI

extension Edge {
    var isTopOrBottom: Bool {
        switch self {
        case .top, .bottom:
            return true
        default:
            return false
        }
    }
}

/// A rectangle that is partly drawn for animation purposes
struct PartRectangle: Shape {
    var completion: Double
    let vertical: Bool?
    let edge: Edge?
    let wavy: Bool = true
    
    var animatableData: Double {
        get { completion }
        set { completion = newValue }
    }
    
    init(completion: Double, alignedTo edge: Edge? = nil) {
        self.completion = minmax(0, 1, completion)
        self.vertical = nil
        self.edge = edge
    }
    
    init(verticalCompletion: Double, alignedTo edge: Edge? = nil) {
        self.completion = minmax(0, 1, verticalCompletion)
        self.vertical = true
        self.edge = edge
    }
    
    init(horizontalCompletion: Double, alignedTo edge: Edge? = nil) {
        self.completion = minmax(0, 1, horizontalCompletion)
        self.vertical = false
        self.edge = edge
    }
    
    func path(in rect: CGRect) -> Path {
        let newSize: CGSize = {
            var newSize = rect.size
            
            if let vertical = vertical {
                if vertical {
                    newSize.height *= completion
                } else {
                    newSize.width *= completion
                }
            } else {
                newSize.width *= completion
                newSize.height *= completion
            }
            
            return newSize
        }()
        
        let newOrigin: CGPoint = {
            let dx = (rect.width - newSize.width) / 2
            let dy = (rect.height - newSize.height) / 2
            
            var newOrigin = rect.origin
            
            switch edge {
            case .none:
                newOrigin.x += dx
                newOrigin.y += dy
            case .bottom:
                newOrigin.y += dy * 2
            case .trailing:
                newOrigin.x += dx * 2
            case .leading, .top:
                break
            }
            
            return newOrigin
        }()
        
        var path = Path()
        
        path.addRect(CGRect(origin: newOrigin, size: newSize))
        
        return path
    }
}

struct PartRectangle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PartRectangle(completion: 0.5)
                .stroke(Color.red)
                .background(Color.gray.clipShape(Rectangle()))
            
            PartRectangle(verticalCompletion: 0.5, alignedTo: .bottom)
                .stroke(Color.red)
                .background(Color.gray.clipShape(Rectangle()))
            
            PartRectangle(verticalCompletion: 0.5, alignedTo: .top)
                .stroke(Color.red)
                .background(Color.gray.clipShape(Rectangle()))
        }
    }
}
