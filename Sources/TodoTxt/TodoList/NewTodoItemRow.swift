import SwiftUI

struct NewTodoItemRow: View {
    @State private var text = ""

    var focused: FocusState<Bool>.Binding

    let onSubmit: (String) -> Void

    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .foregroundStyle(Color.primary.opacity(0.25))

            TextField("New task…", text: $text)
                .textFieldStyle(.plain)
                .focused(focused)
                .onSubmit {
                    let trimmed = text.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    text = ""
                    onSubmit(trimmed)
                }
        }
        .padding(.vertical, 4)
    }
}
