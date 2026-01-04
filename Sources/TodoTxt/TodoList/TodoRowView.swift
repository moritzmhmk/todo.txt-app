import SwiftUI
import TodoParser

/// Presentation-only token used for rendering todo text in the UI.
enum DisplayToken: CustomStringConvertible {
    case text(String)
    case project(String)
    case context(String)
    case keyValue(String, String)

    /// Creates presentation tokens from parser tokens.
    ///
    /// This is a view-layer transformation that may merge multiple consecutive
    /// `.word` tokens into a single `.text` token to ensure natural spacing
    /// and wrapping in SwiftUI.
    static func from(_ tokens: [Token]) -> [DisplayToken] {
        tokens.reduce(into: []) { result, token in
            let display: DisplayToken

            // convert
            switch token {
            case .word(let s):
                display = .text(s)
            case .project(let s):
                display = .project(s)
            case .context(let s):
                display = .context(s)
            case .keyValue(let k, let v):
                display = .keyValue(k, v)
            }

            // concat
            if case .text(let current) = display,
                case .text(let last)? = result.last
            {
                result[result.count - 1] = .text(last + " " + current)
            } else {
                result.append(display)
            }
        }
    }

    var description: String {
        switch self {
        case .context(let s):
            return "@\(s)"

        case .project(let s):
            return "+\(s)"

        case .keyValue(let key, let value):
            return "\(key):\(value)"

        case .text(let s):
            return s
        }
    }
}

struct TodoRowView: View {

    let item: TodoItem
    let showDetails: Bool
    var isEditing: Bool
    let cancelEditing: () -> Void
    let onToggle: () -> Void
    let onUpdate: (String) -> Void

    @State private var localEditingText: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            if isEditing {
                TextField("", text: $localEditingText)
                    .focused($focused)
                    .onAppear {
                        localEditingText = item.description
                        focused = true
                    }
                    .onSubmit {
                        onUpdate(localEditingText)
                    }
                    .onChange(of: focused) { _, newFocusValue in
                        if newFocusValue == false {
                            cancelEditing()
                        }
                    }
            } else {
                Button(action: onToggle) {
                    Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(color(for: item.priority))
                }
                .buttonStyle(.plain)

                if showDetails {
                    if let completionDate = item.completionDate {
                        Text(TodoItem.format(completionDate)).font(
                            .system(size: 10, weight: .ultraLight, design: .monospaced)
                        )
                        .foregroundColor(.primary)
                    }
                    if let creationDate = item.creationDate {
                        Text(TodoItem.format(creationDate)).font(
                            .system(size: 10, weight: .ultraLight, design: .monospaced)
                        )
                        .foregroundColor(.secondary)
                    }
                }

                tokensView(DisplayToken.from(item.tokens))
            }
        }
        .padding(.vertical, 4)
    }
}

func tokensView(_ tokens: [DisplayToken]) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 6) {
        ForEach(tokens, id: \.description) { token in
            switch token {
            case .context(let s):
                Text("@\(s)").font(.system(size: 12, weight: .light)).foregroundColor(.secondary)

            case .project(let s):
                Text("+\(s)").font(.system(size: 12, weight: .light)).foregroundColor(.secondary)

            case .keyValue(let key, let value):
                keyValueView(key: key, value: value)

            case .text(let s):
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

public func color(for priority: Character?) -> Color {
    switch priority {
    case "A": return Color.red
    case "B": return Color.orange
    case "C": return Color.yellow
    default: return Color.primary
    }
}
