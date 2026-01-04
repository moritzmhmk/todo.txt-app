import SwiftUI

struct FilterGroup: View {
    let title: String
    let prefix: String
    let items: [String]
    @Binding var selection: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                if !selection.isEmpty {
                    Button("Clear") {
                        selection.removeAll()
                    }
                    .font(.footnote)
                    .buttonStyle(.plain)
                    .foregroundStyle(.tertiary)
                }
            }

            PillFlowLayout {
                ForEach(items, id: \.self) { item in
                    FilterPill(
                        label: "\(prefix)\(item)",
                        isSelected: selection.contains(item)
                    ) {
                        toggle(item)
                    }
                }
            }
        }
    }

    private func toggle(_ item: String) {
        if selection.contains(item) {
            selection.remove(item)
        } else {
            selection.insert(item)
        }
    }
}
