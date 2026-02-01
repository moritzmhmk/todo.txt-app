import SwiftUI
import TodoParser

struct TodoListView: View {
    let items: [TodoItem]

    let showDetails: Bool

    let onToggle: (Int) -> Void
    let onUpdate: (Int, String) -> Void
    let onDelete: (Int) -> Void
    let onAdd: (String) -> Void
    let onArchive: () -> Void

    @State private var selection = Set<Int>()

    @State private var searchText = ""
    @State private var focusSearch: Bool = false

    @State private var editingRow: Int? = nil
    @FocusState private var focusNewItem: Bool

    @State private var filters = TodoFilters()
    @State private var showFilters = false

    private var indexedItems: [(offset: Int, element: TodoItem)] {
        Array(items.enumerated())
    }
    private func matchesFilters(_ item: TodoItem) -> Bool {
        let projectsMatch =
            filters.projects.isEmpty || !filters.projects.isDisjoint(with: item.projectNames)
        let contextsMatch =
            filters.contexts.isEmpty || !filters.contexts.isDisjoint(with: item.contextNames)
        return projectsMatch && contextsMatch
    }
    private var filteredItems: [(offset: Int, element: TodoItem)] {
        indexedItems.filter { _, item in
            (searchText.isEmpty || item.description.localizedCaseInsensitiveContains(searchText))
                && matchesFilters(item)
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

    private var allProjects: [String] {
        Array(Set(items.flatMap(\.projectNames))).sorted()
    }

    private var allContexts: [String] {
        Array(Set(items.flatMap(\.contextNames))).sorted()
    }

    var body: some View {
        VStack {
            if showFilters {
                FilterSection(
                    filters: $filters,
                    projects: allProjects,
                    contexts: allContexts
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            listView
        }
    }
    private var listView: some View {
        ScrollViewReader { proxy in
            List(selection: $selection) {
                ForEach(sortedPriorities, id: \.self) { priority in
                    TodoPrioritySection(
                        priority: priority,
                        items: groupedItems[priority] ?? [],
                        showDetails: showDetails,
                        editingRow: editingRow,
                        cancelEditing: { editingRow = nil },
                        onToggle: onToggle,
                        onUpdate: { index, line in
                            onUpdate(index, line)
                            editingRow = nil
                        },
                        onDelete: onDelete
                    )
                }

                NewTodoItemRow(focused: $focusNewItem, onSubmit: onAdd)
            }
            .listStyle(.plain)
            .searchable(text: $searchText, isPresented: $focusSearch, placement: .toolbar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        onArchive()
                    } label: {
                        Image(systemName: "archivebox")
                    }
                    .accessibilityLabel("Archive completed tasks.")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation(.snappy) {
                            showFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .overlay(
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 7, height: 7)
                                    .offset(x: 8, y: -8)
                                    .opacity(filters.isActive ? 1 : 0)
                            )
                    }
                    .accessibilityLabel("Filters")
                }
            }
            .onChange(of: [filters.projects, filters.contexts]) {
                if let first = filteredItems.first?.offset {
                    proxy.scrollTo(first, anchor: .top)
                } else {
                    proxy.scrollTo("newItemRow", anchor: .top)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .focusSearch)) { _ in
                focusSearch = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .focusNewItem)) { _ in
                focusNewItem = true
                DispatchQueue.main.async {
                    withAnimation {
                        proxy.scrollTo("newItemRow", anchor: .bottom)
                    }
                }
            }
            .contextMenu(forSelectionType: Int.self) { indices in
                if !indices.isEmpty {
                    Button("Edit") {
                        if let index = indices.first {
                            editingRow = index
                        }
                    }
                    Button("Delete", role: .destructive) {
                        for index in indices {
                            onDelete(index)
                        }
                    }
                }
            } primaryAction: { indices in
                if let index = indices.first {
                    editingRow = index
                }
            }
            .onKeyPress { press in
                if focusNewItem || editingRow != nil { return .ignored }
                switch press.key {
                case .space:
                    for selected in selection {
                        onToggle(selected)
                    }
                case .return:
                    if let index = selection.first {
                        editingRow = index
                    }
                case .escape:
                    selection.removeAll()
                default:
                    return .ignored
                }
                return .handled
            }
            .onDeleteCommand {
                let indices = selection.sorted(by: >)
                for index in indices {
                    onDelete(index)
                }
                selection.removeAll()
            }
        }
    }
}
