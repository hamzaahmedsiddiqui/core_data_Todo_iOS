//
//  Task_to_doApp.swift
//  Task to do
//
//  Created by hamza Ahmed on 2026-07-05.
//

import SwiftUI
import CoreData

@main
struct Task_to_doApp: App {
    let persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, self.persistenceController.container.viewContext)
        }
    }
}
