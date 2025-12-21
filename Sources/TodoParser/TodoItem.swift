import Foundation

public struct TodoItem {
    public var completed: Bool = false
    public var priority: Character? = nil
    public var completionDate: Date? = nil
    public var creationDate: Date? = nil
    public var tokens: [Token] = []

    public var description: String {
        tokens.map(\.description).joined(separator: " ")
    }
}
