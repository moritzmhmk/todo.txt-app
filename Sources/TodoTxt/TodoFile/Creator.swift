import AppKit

@MainActor
enum TodoFileCreator {
    static func create() -> URL? {
        let panel = NSSavePanel()
        panel.title = "Create a new todo.txt file"
        panel.nameFieldStringValue = "todo.txt"
        panel.allowedContentTypes = [.plainText]

        guard panel.runModal() == .OK, let url = panel.url else {
            return nil
        }

        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: Data())
        }

        return url
    }
}