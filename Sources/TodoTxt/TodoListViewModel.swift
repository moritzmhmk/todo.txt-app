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
        if items[index].completed {
            items[index].completed = false
            items[index].completionDate = nil
        } else {
            items[index].completed = true
            items[index].completionDate = items[index].creationDate != nil ? Date.now : nil
        }
        save()
    }

    func addItem(from line: String) {
        var item = TodoParser.parse(line: line)
        if item.creationDate == nil {
            item.creationDate = Date.now
        }
        items.append(item)
        save()
    }

    func updateItem(at index: Int, from line: String) {
        let item = TodoParser.parse(line: line)
        items[index] = item
        save()
    }

    func removeItem(at index: Int) {
        items.remove(at: index)
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
