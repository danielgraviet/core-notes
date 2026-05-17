//
//  core_notesApp.swift
//  core-notes
//
//  Created by Daniel Graviet on 5/15/26.
//

import SwiftUI

@main
struct core_notesApp: App {
    // AppDelegate owns the ModelContainer, NSStatusItem (menu bar icon),
    // NSPopover (quick-capture panel), and the Carbon global hotkey
    // (Cmd+Shift+Space). See AppDelegate.swift for the rationale.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
        }
        .modelContainer(appDelegate.sharedModelContainer)
        .defaultSize(width: 720, height: 500)
    }
}
