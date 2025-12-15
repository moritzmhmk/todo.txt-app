import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: TodoAppState

    var body: some View {
        Group {
            if appState.todoFileURL != nil {
                ScrollView {
                    Text(appState.contents)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)
                }
            } else {
                firstLaunchView
            }
        }
    }

    private var firstLaunchView: some View {
        VStack(spacing: 16) {
            Text("TodoTxt")
                .font(.title)

            Text("Choose or create a todo.txt file to get started.")
                .foregroundStyle(.secondary)

            HStack {
                Button("Choose existing…") {
                    appState.chooseFile()
                }

                Button("Create new…") {
                    appState.createFile()
                }
            }
            .keyboardShortcut(.defaultAction)
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}
