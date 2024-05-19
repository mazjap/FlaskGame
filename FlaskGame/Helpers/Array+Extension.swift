extension Array {
    func split(at index: Index) -> (SubSequence, SubSequence) {
        guard index >= startIndex, index < endIndex else { return (self[...], self[0...0]) }
        
        return (self[0..<index], self[index...])
    }
}
