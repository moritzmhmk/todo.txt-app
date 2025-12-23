import SwiftUI
import TodoParser

struct ContentView: View {

    @ObservedObject var appState: TodoAppState
    @ObservedObject var viewModel: TodoListViewModel

    @State private var searchText = ""
    @State private var newItemText = ""
    @FocusState var focusNewItem: Bool

    @Binding var selection: Set<Int>

    private var indexedItems: [(offset: Int, element: TodoItem)] {
        Array(viewModel.items.enumerated())
    }
    private var filteredItems: [(offset: Int, element: TodoItem)] {
        indexedItems.filter { _, item in
            searchText.isEmpty
                || item.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    private var groupedItems: [Character: [(offset: Int, element: TodoItem)]] {
        Dictionary(grouping: filteredItems) { _, item in
            item.priority ?? "-"
        }
    }
    private var sortedPriorities: [Character] {
        groupedItems.keys.sorted { lhs, rhs in
            if lhs == "-" { return false }
            if rhs == "-" { return true }
            return lhs < rhs
        }
    }

    var body: some View {
        Group {
            if appState.todoFileURL != nil {
                todoList.onDeleteCommand {
                    let indices = selection.sorted(by: >)
                    for index in indices {
                        viewModel.removeItem(at: index)
                    }
                    selection.removeAll()
                }.onExitCommand {
                    selection.removeAll()
                }
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
            List(selection: $selection) {
                ForEach(sortedPriorities, id: \.self) { priority in
                    TodoPrioritySection(
                        priority: priority,
                        items: groupedItems[priority] ?? [],
                        onToggle: viewModel.toggleCompleted,
                        onDelete: viewModel.removeItem
                    )
                }

                newItemRow
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

    private var newItemRow: some View {
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

    private func addNewItem() {
        let text = newItemText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        newItemText = ""
        viewModel.addItem(from: text)
    }
}

struct TodoPrioritySection: View {
    let priority: Character
    let items: [(offset: Int, element: TodoItem)]
    let onToggle: (Int) -> Void
    let onDelete: (Int) -> Void

    var body: some View {
        Section {
            ForEach(sortedItems, id: \.offset) { index, item in
                TodoRowView(
                    item: item,
                    onToggle: { onToggle(index) }
                )
                .opacity(item.completed ? 0.25 : 1.0)
                .id("\(index)-\(item.description)")
                .tag(index)
                .contextMenu {
                    Button(role: .destructive) {
                        onDelete(index)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        onDelete(index)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        } header: {
            Text(headerLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color(for: priority))
                .padding(.vertical, 4)
        }
    }

    private var sortedItems: [(offset: Int, element: TodoItem)] {
        items.sorted { $0.element < $1.element }
    }

    private var headerLabel: String {
        priority == "-" ? "No Priority" : "Priority \(priority)"
    }
}
