struct TodoFilters: Equatable {
    var projects: Set<String> = []
    var contexts: Set<String> = []

    var isActive: Bool {
        !projects.isEmpty || !contexts.isEmpty
    }
}
