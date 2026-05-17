# Phase 2: List View

## Goal
Replace the timestamp-only list with a proper note list: title on top, body preview below, sorted by most recently modified. Add a search bar that filters without loading the full dataset into memory.

## Context
Depends on Phase 1 being complete (`Note` model with `title`, `body`, `modifiedAt`).

The current list does a full table scan via `@Query private var items: [Item]` with no sort or predicate. For a notes app that could have thousands of entries, this is fine at small scale but sets a bad precedent. Use `@Query` with an explicit sort descriptor from the start.

## Acceptance Criteria
- [x] List shows note `title` as the primary label
- [x] List shows first ~60 characters of `body` as a secondary line (truncated, no newlines)
- [x] List is sorted by `modifiedAt` descending (newest first)
- [x] A `searchText` state variable filters the list using a `@Query` predicate — not client-side `.filter()`
- [x] Empty state: when no notes exist, show a simple "No notes" message (no heavy placeholder UI)
- [x] "Add Note" toolbar button creates a `Note` with empty title/body and immediately navigates to the detail view
- [x] Delete still works via swipe/Edit mode
- [x] Keyboard shortcut `Cmd+N` creates a new note

## Files Likely Involved
- `core-notes/ContentView.swift`

## Performance Notes
- The `@Query` predicate runs in SQLite — never pull all rows and filter in Swift.
- Body preview should be computed in the list row view, not stored as a separate field on the model.
- Keep the row view as a separate `NoteRowView` struct so SwiftUI can diff it cheaply.
