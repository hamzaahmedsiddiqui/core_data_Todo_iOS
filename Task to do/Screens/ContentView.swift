//
//  ContentView.swift
//  Task to do
//
//  Created by hamza Ahmed on 2026-07-06.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            TaskListView(path: $path)
                .navigationDestination(for: String.self) { route in
                    if route == "addTask" {
                        AddTaskView(onSave: { path.removeLast() })
                    }
                }
                .navigationDestination(for: TaskItem.self) { task in
                    AddTaskView(existingTask: task, onSave: { path.removeLast() })
                }
        }
    }
}

#Preview {
    ContentView()
}
