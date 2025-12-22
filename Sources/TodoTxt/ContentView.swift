import SwiftUI

struct ContentView: View {

    @ObservedObject var appState: TodoAppState
    @ObservedObject var viewModel: TodoListViewModel

    @State private var searchText = ""
    @State private var newItemText = ""
    @FocusState var focusNewItem: Bool

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
        ScrollViewReader { proxy in
            List {
                // Group items by priority
                let indexed = Array(viewModel.items.enumerated())
                let filtered = indexed.filter { _, item in
                    searchText.isEmpty
                        || item.description.localizedCaseInsensitiveContains(searchText)
                }
                let grouped = Dictionary(grouping: filtered) { _, item in
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
                            .foregroundStyle(color(for: priorityChar))
                            .padding(.vertical, 4)

                    }
                }

                // New item input
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(Color.primary.opacity(0.25))
                    TextField("New task…", text: $newItemText)
                        .textFieldStyle(.plain)
                        .focused($focusNewItem)
                        .onSubmit { addNewItem() }
                }
                .id("newItemRow")
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .toolbar)
            .onReceive(NotificationCenter.default.publisher(for: .focusNewItem)) { _ in
                focusNewItem = true
                DispatchQueue.main.async {
                    withAnimation {
                        proxy.scrollTo("newItemRow", anchor: .bottom)
                    }
                }
            }
        }
    }

    private func addNewItem() {
        let text = newItemText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        newItemText = ""
        viewModel.addItem(from: text)
    }
}
