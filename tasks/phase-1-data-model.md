# Phase 1: Data Model Foundation

## Goal
Replace the placeholder `Item` model with a proper `Note` model that has `title` and `body` fields, and handle the SwiftData schema migration so the app doesn't crash on launch with an existing database.

## Context
The Xcode template created `Item.swift` with just a `timestamp` field. Everything downstream (list view, detail view, search) depends on this model being correct first. Get this right before touching any UI.

SwiftData requires a `VersionedSchema` + `SchemaMigrationPlan` when you change an existing model's fields — skipping this causes a fatal crash on first launch after the schema change.

## Acceptance Criteria
- [x] `Item.swift` renamed to `Note.swift` with the class renamed to `Note`
- [x] `Note` has `var title: String`, `var body: String`, `var createdAt: Date`, `var modifiedAt: Date`
- [x] `Note` exposes a `touch()` method that sets `modifiedAt = .now` — callers invoke it after all mutations are done so SwiftData fires one observation notification per logical edit, not one per property changed
- [x] No `didSet` on model properties — `didSet` on an `@Model` property that mutates another `@Model` property causes a double observation notification on every keystroke, doubling SwiftUI re-render work on the main thread
- [x] For dev builds: delete the app from the simulator to clear the old `ZITEM` SQLite table before first run — no VersionedSchema needed until the app has real users with data to preserve
- [x] `core_notesApp.swift` updated to reference `Note.self` instead of `Item.self`
- [x] App builds and runs without warnings or crashes
- [x] Xcode preview in `ContentView.swift` still works with `inMemory: true`

## Files Likely Involved
- `core-notes/Item.swift` (rename → `Note.swift`)
- `core-notes/core_notesApp.swift`
- `core-notes/ContentView.swift` (update any `Item` references)

## Performance Notes
- Use `final class` (SwiftData requires class, not struct) but keep the model lean — no computed properties that trigger heavy work.
- `modifiedAt` sort will be the primary list sort in Phase 2; index it if SwiftData allows.
