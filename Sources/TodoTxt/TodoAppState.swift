import Foundation

@MainActor
final class TodoAppState: ObservableObject {
    @Published var todoFileURL: URL?
    @Published var contents: String = ""

    private var watcher: TodoFileWatcher?

    init() {
        self.todoFileURL = TodoFileStore.load()
        if let url = todoFileURL {
            loadContents(from: url)
            startWatching(url)
        }
    }

    // MARK: - File selection

    func chooseFile() {
        if let url = TodoFilePicker.pick() {
            setFile(url)
        }
    }

    func createFile() {
        if let url = TodoFileCreator.create() {
            setFile(url)
        }
    }

    private func setFile(_ url: URL) {
        TodoFileStore.save(url)
        todoFileURL = url
        loadContents(from: url)
        startWatching(url)
    }

    // MARK: - File IO

    private func loadContents(from url: URL) {
        contents = (try? String(contentsOf: url)) ?? ""
    }

    // MARK: - Write

    func save(contents newContents: String) {
        guard let url = todoFileURL else { return }

        do {
            try newContents.write(to: url, atomically: true, encoding: .utf8)
            contents = newContents
        } catch {
            print("Failed to save todo.txt:", error)
        }
    }

    // MARK: - File watching

    private func startWatching(_ url: URL) {
        watcher?.stop()
        watcher = TodoFileWatcher(url: url) { [weak self] in
            self?.loadContents(from: url)
        }
    }
}
