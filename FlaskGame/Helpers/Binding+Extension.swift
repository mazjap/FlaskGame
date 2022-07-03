import SwiftUI

extension Binding {
    init(_ get: @escaping () -> Value) {
        self.init(get: get, set: { _ in })
    }
    
    func tap(_ tap: @escaping (Value) -> Void) -> Self {
        Binding {
            tap(wrappedValue)
            return wrappedValue
        } set: {
            wrappedValue = $0
        }
    }
    
    func map<T>(
        to: @escaping (Value) -> T,
        from: ((T) -> Value)? = nil
    ) -> Binding<T> {
        Binding<T> {
            to(wrappedValue)
        } set: {
            guard let from = from else { return }
            wrappedValue = from($0)
        }
    }
}
