import SwiftUI

struct FilterSection: View {
    @Binding var filters: TodoFilters
    let projects: [String]
    let contexts: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if projects.isEmpty && contexts.isEmpty {
                Text("Add +projects or @contexts to enable filtering")
                    .font(.footnote)
                    .italic()
                    .foregroundStyle(.tertiary)
            }

            if !projects.isEmpty {
                FilterGroup(
                    title: "Projects",
                    prefix: "+",
                    items: projects,
                    selection: $filters.projects
                )
            }

            if !contexts.isEmpty {
                FilterGroup(
                    title: "Contexts",
                    prefix: "@",
                    items: contexts,
                    selection: $filters.contexts
                )
            }
        }
        .padding()
        .background(.bar)
        .overlay(Divider(), alignment: .bottom)
    }
}
