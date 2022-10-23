enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard
    
    var intValue: Int {
        switch self {
        case .easy:
            return 8
        case .medium:
            return 12
        case .hard:
            return 16
        }
    }
}
