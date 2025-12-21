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
