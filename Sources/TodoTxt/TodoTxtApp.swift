import SwiftUI

@main
struct TodoTxtApp: App {
    @StateObject private var appState: TodoAppState
    @StateObject private var viewModel: TodoListViewModel

    @AppStorage("showTaskDetails") private var showTaskDetails = false
    @State private var selection = Set<Int>()

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
            ContentView(
                appState: appState, viewModel: viewModel,
                showTaskDetails: showTaskDetails, selection: $selection
            )
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
                Button("Find Task") {
                    NotificationCenter.default.post(name: .focusSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
                Toggle("Show Task Details", isOn: $showTaskDetails)
                    .keyboardShortcut("i", modifiers: .command)
            }
        }
    }
}

extension NSNotification.Name {
    static let focusNewItem = NSNotification.Name("focusNewItem")
    static let focusSearch = NSNotification.Name("focusSearch")
}
