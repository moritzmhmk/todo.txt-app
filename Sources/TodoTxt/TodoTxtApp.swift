import SwiftUI

@main
struct TodoTxtApp: App {
    @StateObject private var appState: TodoAppState
    @StateObject private var viewModel: TodoListViewModel

    @FocusState private var focusNewItem: Bool

    init() {
        let state = TodoAppState()
        _appState = StateObject(wrappedValue: state)
        _viewModel = StateObject(
            wrappedValue: TodoListViewModel(
                initialContents: state.contents,
                onSave: { state.save(contents: $0) }
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState, viewModel: viewModel)
                .onChange(of: appState.contents) { _, newValue in
                    viewModel.parse(contents: newValue)
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New todo.txt…") {
                    appState.createFile()
                }

                Button("Open todo.txt…") {
                    appState.chooseFile()
                }
            }
            CommandMenu("Todo") {
                Button("New Task") {
                    NotificationCenter.default.post(name: .focusNewItem, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
        }
    }
}

extension NSNotification.Name {
    static let focusNewItem = NSNotification.Name("focusNewItem")
}
