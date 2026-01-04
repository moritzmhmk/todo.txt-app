import SwiftUI
import TodoParser

struct TodoPrioritySection: View {
    let priority: Character
    let items: [(offset: Int, element: TodoItem)]
    let showDetails: Bool
    var editingRow: Int?
    let cancelEditing: () -> Void
    let onToggle: (Int) -> Void
    let onUpdate: (Int, String) -> Void
    let onDelete: (Int) -> Void

    var body: some View {
        Section {
            ForEach(sortedItems, id: \.offset) { index, item in
                TodoRowView(
                    item: item,
                    showDetails: showDetails,
                    isEditing: editingRow == index,
                    cancelEditing: cancelEditing,
                    onToggle: { onToggle(index) },
                    onUpdate: { line in onUpdate(index, line) }
                )
                .opacity(item.completed ? 0.25 : 1.0)
                .id("\(index)-\(item.description)")
                .tag(index)
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
