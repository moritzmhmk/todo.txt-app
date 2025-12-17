enum Token: Equatable, CustomStringConvertible {
    case context(String)
    case project(String)
    case keyValue(key: String, value: String)
    case word(String)

    var description: String {
        switch self {
        case .context(let s):
            return "@\(s)"

        case .project(let s):
            return "+\(s)"

        case .keyValue(let key, let value):
            return "\(key):\(value)"

        case .word(let s):
            return s
        }
    }
}
