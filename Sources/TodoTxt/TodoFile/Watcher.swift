import Foundation

final class TodoFileWatcher {
    private var source: DispatchSourceFileSystemObject?
    private let url: URL
    private let onChange: @MainActor () -> Void

    init(url: URL, onChange: @escaping @MainActor () -> Void) {
        self.url = url
        self.onChange = onChange
        start()
    }

    private func start() {
        let fd = open(url.path, O_EVTONLY)
        guard fd != -1 else { return }

        let queue = DispatchQueue(label: "TodoFileWatcher")
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename],
            queue: queue
        )

        source?.setEventHandler { [onChange] in
            Task { @MainActor in
                onChange()
            }
        }

        source?.setCancelHandler {
            close(fd)
        }

        source?.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
    }

    deinit {
        stop()
    }
}
