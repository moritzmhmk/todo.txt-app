import SwiftUI

struct ContentView: View {

    @ObservedObject var appState: TodoAppState
    @ObservedObject var viewModel: TodoListViewModel

    var body: some View {
        Group {
            if appState.todoFileURL != nil {
                todoList
            } else {
                firstLaunchView
            }
        }
        .frame(minWidth: 400, minHeight: 300)
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
        }
        .padding()
    }

    private var todoList: some View {
        List {
            ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                TodoRowView(
                    item: item
                )
            }
        }
    }
}
