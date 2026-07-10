//
//  TaskRow.swift
//  Task to do
//
//  Created by hamza Ahmed on 2026-07-11.
//
import SwiftUI

struct TaskRow: View {
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
