import Foundation
import TodoParser

@MainActor
final class TodoListViewModel: ObservableObject {

    @Published private(set) var items: [TodoItem] = []

    private let saveHandler: (String) -> Void

    init(
        initialContents: String,
        onSave: @escaping (String) -> Void
    ) {
        self.saveHandler = onSave
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
        save()
    }

    func addItem(from line: String) {
        let item = TodoParser.parse(line: line)
        items.append(item)
        save()
    }

    private func save() {
        let text =
            items
            .map { $0.description }
            .joined(separator: "\n")

        saveHandler(text)
    }
}
