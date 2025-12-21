import Foundation
import TodoParser

@MainActor
final class TodoListViewModel: ObservableObject {

    @Published private(set) var items: [TodoItem] = []

    init(
        initialContents: String
    ) {
        parse(contents: initialContents)
    }

    func parse(contents: String) {
        items =
            contents
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .map { TodoParser.parse(line: $0) }
    }

    func toggleCompleted(at index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].completed.toggle()
    }
}
