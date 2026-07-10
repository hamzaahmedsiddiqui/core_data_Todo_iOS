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
