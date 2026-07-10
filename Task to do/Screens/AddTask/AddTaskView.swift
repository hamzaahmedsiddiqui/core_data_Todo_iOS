import SwiftUI
import CoreData

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    var existingTask: TaskItem?
    var onSave: () -> Void

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var scheduleDate: Date = Date()
    @FocusState private var focusedField: Field?

    enum Field { case title, description }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespaces)
    }

    private var isEditing: Bool {
        existingTask != nil
    }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "textformat")
                        .foregroundStyle(.blue)
                        .frame(width: 22)
                    TextField("Task title", text: $title)
                        .focused($focusedField, equals: .title)
                        .font(.headline)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .description }
                }

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "text.alignleft")
                        .foregroundStyle(.pink)
                        .frame(width: 22)
                    TextField("Add description...", text: $description, axis: .vertical)
                        .focused($focusedField, equals: .description)
                        .lineLimit(3...8)
                }
            } header: {
                Label("Details", systemImage: "doc.text.fill")
                    .foregroundStyle(.blue)
            }

            Section {
                DatePicker(
                    "Scheduled for",
                    selection: $scheduleDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .tint(.orange)
            } header: {
                Label("Time", systemImage: "clock.fill")
                    .foregroundStyle(.orange)
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.08), Color.blue.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle(isEditing ? "Edit Task" : "New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .tint(.red)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "Update" : "Save") { save() }
                    .fontWeight(.semibold)
                    .buttonStyle(BounceButtonStyle())
                    .tint(.green)
                    .disabled(trimmedTitle.isEmpty)
                    .animation(.easeInOut, value: trimmedTitle.isEmpty)
            }
        }
        .onAppear {
            if let existingTask {
                title = existingTask.title ?? ""
                description = existingTask.taskDescription ?? ""
                scheduleDate = existingTask.scheduleDate ?? Date()
            }
            focusedField = .title
        }
    }

    private func save() {
        guard !trimmedTitle.isEmpty else { return }

        let task = existingTask ?? TaskItem(context: viewContext)
        if existingTask == nil {
            task.id = UUID()
            task.completed = false
        }
        task.title = trimmedTitle
        task.taskDescription = description
        task.scheduleDate = scheduleDate

        do {
            try viewContext.save()
        } catch {
            print("Save failed: \(error)")
        }

        onSave()
        dismiss()
    }
}
