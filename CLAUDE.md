# core-notes — Agent Guide

## Project Goal

A hyper-performant note-taking app built from the ground up for Apple Silicon. The north star is raw speed and minimal resource usage — not aesthetics, not feature breadth. Every architectural decision should be evaluated against: does this make it faster, lighter, or more reliable?

## Design Philosophy

- **Performance over UI polish** — functional is good enough; fast is required.
- **Minimal RAM footprint** — lazy load everything, release memory aggressively.
- **Background-friendly** — the app should run quietly, consume negligible CPU at rest, and not interfere with other processes.
- **No bloat** — no feature goes in unless it serves core note-taking. No animations for their own sake, no heavy dependencies.

## Tech Stack

- **Language**: Swift
- **UI**: SwiftUI (minimal — views should be lightweight and simple)
- **Persistence**: SwiftData
- **Platform**: macOS (Apple Silicon primary target)
- **Xcode version**: <!-- e.g. 16.x -->

## Project Structure

```
core-notes/
  core_notesApp.swift   # App entry point, SwiftData container setup
  ContentView.swift     # Main list view
  Item.swift            # SwiftData model
  Assets.xcassets/      # Images, colors, icons
tasks/                  # Agent task files
CLAUDE.md               # This file
```

## Data Model

- `Item` — currently just a timestamp; will become a Note with title + body.

## Performance Constraints

- Views must not hold data in memory beyond what is visible — use `@Query` with predicates and limits, not full table scans.
- No synchronous work on the main thread — disk I/O, model saves, and any heavy processing must be off-thread.
- Prefer value types (structs) over reference types where possible to reduce heap pressure.
- The app should idle at <50MB RAM when running in the background with no active window.

## Coding Conventions

- Keep views small and dumb — logic belongs in the model layer, not in views.
- All SwiftData mutations go through `modelContext`.
- No third-party dependencies without strong justification.
- No UIKit.

## What Agents Should Know

- This targets macOS on Apple Silicon — do not make iOS-only API choices.
- The `ModelContainer` is set up in `core_notesApp.swift` — don't create a second one.
- Previews use `inMemory: true` so they don't touch the real database.
- When in doubt, choose the approach that uses less memory and fewer CPU cycles at rest.

## Out of Scope

- iOS support (for now).
- Rich text, attachments, or embedded media.
- Sync / cloud features.
- Animations beyond system defaults.
- Any UI framework other than SwiftUI.

## Current Goals

- [ ] Add `title` and `body` fields to the `Item` model (rename to `Note`)
- [ ] Show note title in the list view
- [ ] Build a minimal detail/edit view
- [ ] Evaluate menu bar app vs. standard window app for background behavior
