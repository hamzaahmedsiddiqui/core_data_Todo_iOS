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

private struct TaskRow: View {
    @ObservedObject var task: TaskItem
    var accentColor: Color
    var onComplete: (TaskItem) -> Void
    var onTap: (TaskItem) -> Void

    @State private var isCompleting = false

    private var resolvedDate: Date {
        task.scheduleDate ?? Date()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(accentColor.gradient)
                .frame(width: 5)
                .padding(.vertical, 4)

            HStack(alignment: .top, spacing: 12) {
                Button {
                    complete()
                } label: {
                    Image(systemName: isCompleting ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isCompleting ? .green : accentColor)
                        .scaleEffect(isCompleting ? 1.25 : 1.0)
                }
                .buttonStyle(BounceButtonStyle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title ?? "")
                        .font(.headline)

                    if let description = task.taskDescription, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Label(resolvedDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(resolvedDate < Date() ? .red : accentColor)
                }
                .contentShape(Rectangle())
                .onTapGesture { onTap(task) }

                Spacer()
            }
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.12), Color(.secondarySystemBackground)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: accentColor.opacity(0.15), radius: 8, y: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .scaleEffect(isCompleting ? 0.96 : 1)
        .opacity(isCompleting ? 0.4 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleting)
    }

    private func complete() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isCompleting = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onComplete(task)
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
