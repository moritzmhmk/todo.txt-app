import Foundation

@MainActor
final class TodoAppState: ObservableObject {
    @Published var todoFileURL: URL?
    @Published var doneFileURL: URL?

    @Published var todoContents: String = ""
    @Published var doneContents: String = ""

    private var todoWatcher: TodoFileWatcher?
    private var doneWatcher: TodoFileWatcher?

    init() {
        self.todoFileURL = TodoFileStore.load()
        if let url = todoFileURL {
            setFile(url)
        }
    }

    // MARK: - File selection

    func chooseFile() {
        if let url = TodoFilePicker.pick() {
            TodoFileStore.save(url)
            setFile(url)
        }
    }

    func createFile() {
        if let url = TodoFileCreator.create() {
            TodoFileStore.save(url)
            setFile(url)
        }
    }

    private func setFile(_ url: URL) {
        todoFileURL = url
        loadTodoContents(from: url)
        startWatchingTodo(url)

        doneFileURL = url.deletingLastPathComponent().appendingPathComponent("done.txt")
        if let url = doneFileURL {
            loadDoneContents(from: url)
            startWatchingDone(url)
        }
    }

    // MARK: - File IO

    private func loadTodoContents(from url: URL) {
        todoContents = (try? String(contentsOf: url)) ?? ""
    }

    private func loadDoneContents(from url: URL) {
        doneContents = (try? String(contentsOf: url)) ?? ""
    }

    // MARK: - Write

    func saveTodo(contents newContents: String) {
        guard let url = todoFileURL else { return }

        do {
            try newContents.write(to: url, atomically: true, encoding: .utf8)
            todoContents = newContents
        } catch {
            print("Failed to save todo.txt:", error)
        }
    }

    func saveDone(contents newContents: String) {
        guard let url = doneFileURL else { return }

        do {
            try newContents.write(to: url, atomically: true, encoding: .utf8)
            doneContents = newContents
        } catch {
            print("Failed to save done.txt:", error)
        }
    }

    // MARK: - File watching

    private func startWatchingTodo(_ url: URL) {
        todoWatcher?.stop()
        todoWatcher = TodoFileWatcher(url: url) { [weak self] in
            self?.loadTodoContents(from: url)
        }
    }

    private func startWatchingDone(_ url: URL) {
        doneWatcher?.stop()
        doneWatcher = TodoFileWatcher(url: url) { [weak self] in
            self?.loadDoneContents(from: url)
        }
    }
}
