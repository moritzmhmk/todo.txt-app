import SwiftUI
import TodoParser

struct TodoRowView: View {

    let item: TodoItem

    var body: some View {
        HStack {
            Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")

            Text(item.description)
                .strikethrough(item.completed)
        }
        .padding(.vertical, 4)
    }
}
