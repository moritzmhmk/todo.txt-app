import Foundation

enum TodoFileStore {
    private static let key = "TodoFilePath"

    static func load() -> URL? {
        guard let path = UserDefaults.standard.string(forKey: key) else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    static func save(_ url: URL) {
        UserDefaults.standard.set(url.path, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}