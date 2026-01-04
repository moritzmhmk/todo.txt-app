import SwiftUI
import TodoParser

struct ContentView: View {

    @ObservedObject var appState: TodoAppState
    @ObservedObject var viewModel: TodoListViewModel

    let showTaskDetails: Bool

    var body: some View {
        Group {
            if appState.todoFileURL != nil {
                TodoListView(
                    items: viewModel.items,
                    showDetails: showTaskDetails,
                    onToggle: viewModel.toggleCompleted,
                    onUpdate: viewModel.updateItem,
                    onDelete: viewModel.removeItem,
                    onAdd: viewModel.addItem
                )
            } else {
                FirstLaunchView(appState: appState)
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }

}
