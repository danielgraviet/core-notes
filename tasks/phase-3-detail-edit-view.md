# Phase 3: Detail / Edit View

## Goal
Build a minimal `NoteDetailView` where the user can read and edit a note's title and body. Auto-save on every keystroke — no save button, no confirmation dialogs.

## Context
Depends on Phase 2. The `NavigationSplitView` detail column is currently a placeholder `Text("Select an item")`. This phase replaces it with a real editor.

The design philosophy is speed over polish. The editor should be a plain `TextEditor` — no rich text, no formatting toolbar, no markdown rendering. The fastest editor is the one with the fewest layers.

## Acceptance Criteria
- [ ] Selecting a note in the list loads `NoteDetailView` in the detail column
- [ ] `NoteDetailView` has a `TextField` for the title at the top and a `TextEditor` for the body below
- [ ] Changes are written to SwiftData immediately on each change (via `.onChange` or `@Binding`) — no explicit save button
- [ ] `modifiedAt` is updated on every save
- [ ] When no note is selected, the detail column shows a minimal "Select a note" placeholder (plain text, nothing else)
- [ ] Focus moves to the title field automatically when a new note is created
- [ ] `Cmd+W` or `Esc` dismisses focus back to the list (standard macOS behavior — don't fight it)
- [ ] The view works correctly in the Xcode preview with an in-memory container

## Files Likely Involved
- `core-notes/NoteDetailView.swift` (new file)
- `core-notes/ContentView.swift` (wire up the NavigationLink detail)

## Performance Notes
- Do not use `@State` to hold a copy of the note's body for editing and then sync back — bind directly to the `@Model` object's properties. SwiftData tracks changes automatically.
- `TextEditor` on macOS is backed by `NSTextView` which is already highly optimized. Don't wrap it unnecessarily.
- Auto-save via SwiftData's implicit save (happens on run-loop idle) is fine — no need for explicit `try modelContext.save()` on every keystroke.
