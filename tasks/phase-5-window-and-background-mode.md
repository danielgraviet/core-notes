# Phase 5: Window & Background Mode

## Goal
Decide between menu bar app and standard window app, implement the winner, and ensure the app consumes negligible CPU/RAM when no window is visible.

## Context
This is the final phase and the one most specific to macOS. A menu bar app (`MenuBarExtra`) can live as a small popover — fast to open, invisible when not in use, minimal memory when backgrounded. A standard window app is simpler to build but keeps a Dock icon and a larger memory footprint.

This phase requires a conscious architectural decision before coding. The CLAUDE.md goal is "background-friendly — the app should run quietly, consume negligible CPU at rest."

## Decision Criteria (evaluate before implementing)

| Factor | Menu Bar App | Standard Window |
|---|---|---|
| Open speed | Instant popover | Normal window launch |
| Background RAM | ~15–25MB (no window) | ~30–50MB |
| macOS convention | Good for quick-capture tools | Good for primary workspace apps |
| Implementation complexity | Medium (MenuBarExtra + popover sizing) | Low (already done) |
| Keyboard global shortcut | Possible (Carbon HotKey or EventMonitor) | Possible |

**Recommendation to evaluate**: menu bar app with a keyboard global shortcut (e.g. `Cmd+Shift+Space`) for instant note capture. Standard window stays available for longer editing sessions.

## Decision
Menu bar app with global hotkey (Cmd+Shift+Space). NSStatusItem + NSPopover via AppDelegate
(not MenuBarExtra) because MenuBarExtra cannot be shown programmatically — required for hotkey
support. Carbon RegisterEventHotKey used (no Accessibility entitlement needed). WindowGroup
window hidden on launch, close intercepted to hide-not-destroy.

## Acceptance Criteria
- [x] Architectural decision documented as a comment in `core_notesApp.swift` with reasoning
- [x] Chosen mode implemented and working
- [ ] App backgrounded with no visible window uses <25MB RAM (menu bar) or <50MB (standard window)
- [ ] CPU usage at idle is 0% (no timers, no polling, no background tasks)
- [ ] If menu bar: popover opens in <100ms on keypress
- [x] If menu bar: app does not appear in the Dock when popover is closed (`LSUIElement = YES` in Info.plist)
- [ ] App survives sleep/wake cycles without crashing or leaking

## Files Likely Involved
- `core-notes/core_notesApp.swift` (Scene type change if going menu bar)
- `core-notes/Info.plist` (LSUIElement if going menu bar)
- Possibly a new `MenuBarNoteView.swift` for the popover content

## Notes
- `MenuBarExtra` was introduced in macOS 13 — fine for Apple Silicon target.
- Do not use `NSStatusItem` directly; `MenuBarExtra` is the SwiftUI-native equivalent.
- A global keyboard shortcut requires `CGEventTap` or a small AppKit bridge — this is the one place UIKit-adjacent code is acceptable.
