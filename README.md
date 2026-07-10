# Task To Do — Core Data + SwiftUI

A native iOS to-do app built to demonstrate practical Core Data integration in a modern SwiftUI app — full CRUD, live-updating fetches, and a polished UI, with no third-party persistence libraries.

## Tech Stack

- Swift, SwiftUI
- Core Data (`NSPersistentContainer`, `NSManagedObjectContext`, `NSFetchRequest`)
- `NavigationStack` / `NavigationPath` for programmatic, type-safe navigation

## Core Data Concepts Demonstrated

- **Custom persistence stack** — `PersistenceController` wrapping `NSPersistentContainer`, with the managed object context injected app-wide via SwiftUI's environment (`.environment(\.managedObjectContext, ...)`)
- **Live queries with `@FetchRequest`** — sorted results that update automatically the instant the store changes, no manual refresh
- **Full CRUD** — create and update share a single reusable form view; delete goes through `NSManagedObjectContext.delete(_:)` + `save()`, driven by both swipe-to-delete and a custom action
- **NavigationPath routing on a managed object** — pushing a specific `NSManagedObject` instance directly onto the navigation stack (`path.append(task)`) to drive an edit flow, relying on Core Data's built-in `Hashable`/`Identifiable` conformance
- **Correct error handling on save** — replaced silent `try?` with explicit `do/catch`, after tracing a real bug where a missing non-optional attribute value caused Core Data to silently fail validation on save

## What I Debugged Along the Way

Building this surfaced several real, non-obvious Core Data issues — the kind that show up in interviews as much as in production code:

- A `Codegen: Manual/None` misconfiguration that silently prevented Xcode from generating the managed object subclass at all
- A key path runtime crash caused by a mismatch between an entity's display name and its underlying Swift class name
- A naming collision between a custom model type and Swift's structured-concurrency `Task` type
- A model attribute named `description`, which silently shadowed the `NSObject`-inherited property instead of the intended optional field

## Setup

```bash
git clone https://github.com/hamzaahmedsiddiqui/core_data_Todo_iOS.git
open "Task to do.xcodeproj"
```

Requires Xcode 15+, iOS 17+ simulator or device. No dependencies to install.
