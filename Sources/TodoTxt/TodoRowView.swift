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

            tokensView(item.tokens)
        }
        .padding(.vertical, 4)
    }
}

func tokensView(_ tokens: [Token]) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 6) {
        ForEach(tokens, id: \.description) { token in
            switch token {
            case .context(let s):
                Text("+\(s)").font(.system(size: 12, weight: .light)).foregroundColor(.secondary)

            case .project(let s):
                Text("@\(s)").font(.system(size: 12, weight: .light)).foregroundColor(.secondary)

            case .keyValue(let key, let value):
                keyValueView(key: key, value: value)

            case .word(let s):
                Text(s)
            }
        }
    }
}

private func keyValueView(key: String, value: String) -> some View {
    HStack(spacing: 1) {
        Text("\(key)")
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color(nsColor: .tertiarySystemFill))

        Text(value)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(nsColor: .secondarySystemFill))
    }
    .font(.system(size: 12))
    .foregroundColor(.secondary)
    .clipShape(RoundedRectangle(cornerRadius: 4))
}
