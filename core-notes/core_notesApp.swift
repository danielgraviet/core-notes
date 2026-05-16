//
//  core_notesApp.swift
//  core-notes
//
//  Created by Daniel Graviet on 5/15/26.
//

import SwiftUI
import SwiftData

@main
struct core_notesApp: App {
    var sharedModelContainer: ModelContainer = {
        // When this schema changes in a shipping app, add a VersionedSchema +
        // SchemaMigrationPlan here. For now (dev only, no users), deleting the
        // app from the simulator clears the old SQLite store cleanly.
        let schema = Schema([
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
