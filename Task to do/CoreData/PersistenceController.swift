//
//  PersistenceController.swift
//  Task to do
//
//  Created by hamza Ahmed on 2026-07-07.
//

import Foundation
import CoreData

struct PersistenceController{
    let container: NSPersistentContainer
    
    init(){
        self.container = NSPersistentContainer(name: "CoreDataDemo")
        self.container.loadPersistentStores { _ , error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }
}

//extension PersistenceController {
//    func importTasks(_ items: [(title: String, scheduleDate: Date)]) {
//        container.performBackgroundTask { backgroundContext in
//            for item in items {
//                let task = TaskItem(context: backgroundContext)
//                task.id = UUID()
//                task.title = item.title
//                task.scheduleDate = item.scheduleDate
//                task.completed = false
//            }
//
//            do {
//                try backgroundContext.save()
//            } catch {
//                print("Import failed: \(error)")
//            }
//        }
//    }
//}
