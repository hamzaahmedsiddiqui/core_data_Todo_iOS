import SwiftUI
import CoreData

struct TaskListView: View {
    @Binding var path: NavigationPath
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.scheduleDate, ascending: true)])
    private var tasksFetched: FetchedResults<TaskItem>

    var body: some View {
        List {
            ForEach(tasksFetched) { task in
                TaskRow(
                    task: task,
                    accentColor: accentColor(for: task.id),
                    onComplete: complete,
                    onTap: { _ in path.append(task) }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    )
                )
            }
            .onDelete(perform: deleteTask)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.10), Color.blue.opacity(0.06), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .overlay {
            if tasksFetched.isEmpty {
                emptyState
            }
        }
        .navigationTitle("To Task")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    path.append("addTask")
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 34, height: 34)
                            .shadow(color: .purple.opacity(0.4), radius: 6, y: 2)

                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(BounceButtonStyle())
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 84, height: 84)
                    .shadow(color: .purple.opacity(0.35), radius: 12, y: 6)

                Image(systemName: "checklist")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 4) {
                Text("No Tasks Yet")
                    .font(.title3.bold())
                Text("Tap the + button to add your first task.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func accentColor(for id: UUID?) -> Color {
        let palette: [Color] = [.blue, .purple, .pink, .orange, .green, .teal, .indigo]
        guard let id else { return .blue }
        let index = abs(id.hashValue) % palette.count
        return palette[index]
    }

    private func complete(_ task: TaskItem) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            viewContext.delete(task)
            save()
        }
    }

    private func deleteTask(at offset: IndexSet) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            offset.map { tasksFetched[$0] }.forEach(viewContext.delete)
            save()
        }
    }

    private func save() {
        do {
            try viewContext.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
}


struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}
