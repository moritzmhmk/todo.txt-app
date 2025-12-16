enum Token: Equatable, CustomStringConvertible {
    case word(String)

    var description: String {
        switch self {
        case .word(let s): return s
        }
    }
}
