import SwiftUI

struct FilterPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color.accentColor
                        : Color.secondary.opacity(0.2)
                )
                .foregroundColor(
                    isSelected ? .white : .primary
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
