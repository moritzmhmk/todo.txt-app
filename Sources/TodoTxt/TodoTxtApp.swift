import SwiftUI

@main
struct TodoTxtApp: App {
    @StateObject private var appState = TodoAppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
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
