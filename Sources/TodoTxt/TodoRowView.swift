import SwiftUI
import TodoParser

struct TodoRowView: View {

    let item: TodoItem
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.plain)

            Text(item.description)
                .strikethrough(item.completed)
        }
        .padding(.vertical, 4)
    }
}
