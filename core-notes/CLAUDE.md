# core-notes — Agent Guide

## Project Overview

<!-- Describe what this app does in 2-3 sentences. -->
A notes app for iOS built with SwiftUI and SwiftData.

## Tech Stack

- **Language**: Swift
- **UI**: SwiftUI
- **Persistence**: SwiftData
- **Platform**: iOS / macOS
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

<!-- Describe your models and their relationships as they grow. -->
- `Item` — currently just a timestamp; will become a Note with title + body.

## Coding Conventions

<!-- Fill in your preferences. Examples below. -->
- Use SwiftUI for all UI — no UIKit unless absolutely necessary.
- Keep views small; extract sub-views into their own files when they exceed ~50 lines.
- All SwiftData mutations go through `modelContext` — no direct property mutation outside a view.
- No third-party dependencies without discussion first.

## What Agents Should Know

<!-- Gotchas, constraints, things that bit you. -->
- The `ModelContainer` is set up in `core_notesApp.swift` and injected via `.modelContainer()` — don't create a second one.
- Previews use `inMemory: true` so they don't touch the real database.

## Out of Scope

<!-- Things agents should NOT do unless explicitly asked. -->
- Do not add UIKit.
- Do not add a backend or network layer yet.
- Do not modify the Xcode project file (`.xcodeproj`) directly.

## Current Goals

<!-- Keep this updated as you work. -->
- [ ] Add `title` and `body` fields to the `Item` model
- [ ] Show note title in the list view
- [ ] Build a detail/edit view for note content
