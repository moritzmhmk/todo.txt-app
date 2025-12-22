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
            // Group items by priority
            let indexed = Array(viewModel.items.enumerated())
            let grouped = Dictionary(grouping: indexed) { _, item in
                item.priority ?? "-"  // use "-" for no priority
            }

            let sortedGroups = grouped.keys.sorted { lhs, rhs in
                if lhs == "-" { return false }  // no priority goes last
                if rhs == "-" { return true }
                return lhs < rhs
            }

            ForEach(sortedGroups, id: \.self) { priorityChar in
                Section {
                    let itemsInGroup = grouped[priorityChar]!.sorted { $0.element < $1.element }
                    ForEach(itemsInGroup, id: \.offset) { index, item in
                        TodoRowView(
                            item: item,
                            onToggle: { viewModel.toggleCompleted(at: index) }
                        ).opacity(item.completed ? 0.25 : 1.0)
                    }
                } header: {
                    let label: String =
                        (priorityChar == "-") ? "No Priority" : "Priority \(priorityChar)"
                    Text(label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)

                }
            }
        }
        .listStyle(.plain)
    }
}
