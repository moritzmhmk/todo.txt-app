import SwiftUI

@main
struct TodoTxtApp: App {
    @StateObject private var appState: TodoAppState
    @StateObject private var viewModel: TodoListViewModel

    init() {
        let state = TodoAppState()
        _appState = StateObject(wrappedValue: state)
        _viewModel = StateObject(
            wrappedValue: TodoListViewModel(
                initialContents: state.contents
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
                .keyboardShortcut("n")

                Button("Open todo.txt…") {
                    appState.chooseFile()
                }
                .keyboardShortcut("o")
            }
        }
    }
}
