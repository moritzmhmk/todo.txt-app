import Foundation

struct TodoItem {
    var completed: Bool = false
    var priority: Character? = nil
    var completionDate: Date? = nil
    var creationDate: Date? = nil
    var tokens: [Token] = []
}
