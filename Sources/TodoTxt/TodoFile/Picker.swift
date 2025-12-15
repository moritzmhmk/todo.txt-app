import AppKit

@MainActor
enum TodoFilePicker {
    static func pick() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Choose your todo.txt file"
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        return panel.runModal() == .OK ? panel.url : nil
    }
}