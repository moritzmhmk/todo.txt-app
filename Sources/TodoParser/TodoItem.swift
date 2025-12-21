import Foundation

public struct TodoItem {
    public var completed: Bool = false
    public var priority: Character? = nil
    public var completionDate: Date? = nil
    public var creationDate: Date? = nil
    public var tokens: [Token] = []

    public var description: String {
        var parts: [String] = []

        if completed {
            parts.append("x")
        }

        if let priority = priority {
            parts.append("(\(priority))")
        }

        if let completionDate = completionDate {
            // TODO handle case of completionDate when creationDate is nil
            parts.append(format(completionDate))
        }

        if let creationDate = creationDate {
            parts.append(format(creationDate))
        }

        parts.append(contentsOf: tokens.map(\.description))

        return parts.joined(separator: " ")
    }

    private func format(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

extension TodoItem: Comparable {
    public static func < (lhs: TodoItem, rhs: TodoItem) -> Bool {
        func priorityRank(_ t: TodoItem) -> UInt8 {
            if let p = t.priority?.asciiValue {
                return p
            }
            return UInt8.max
        }

        let lp = priorityRank(lhs)
        let rp = priorityRank(rhs)
        if lp != rp { return lp < rp }

        // same priority: sort by creation date
        switch (lhs.creationDate, rhs.creationDate) {
        case let (l?, r?):
            if l != r { return l < r }
        case (nil, .some):
            return false
        case (.some, nil):
            return true
        default:
            break
        }

        // same priority and creation date: sort by description
        return lhs.description < rhs.description
    }

    public static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.completed == rhs.completed && lhs.priority == rhs.priority
            && lhs.completionDate == rhs.completionDate && lhs.creationDate == rhs.creationDate
            && lhs.tokens.map(\.description) == rhs.tokens.map(\.description)
    }
}
