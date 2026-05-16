# Phase 4: Performance Hardening

## Goal
Profile the running app and enforce the <50MB idle RAM target. Harden the data layer with proper off-thread saves and query limits so the app stays fast at any note count.

## Context
Depends on Phases 1–3. Do this phase *after* the core features work — premature optimization is worse than no optimization. But don't ship without it.

The CLAUDE.md constraints are explicit: <50MB RAM at idle, no synchronous main-thread I/O, `@Query` with predicates not full table scans.

## Acceptance Criteria
- [ ] Instruments (Time Profiler + Allocations) run shows <50MB heap when app is backgrounded with no window focused
- [ ] `@Query` in the list uses an explicit `FetchDescriptor` with `fetchLimit` (e.g. 200) — not an unbounded scan
- [ ] Search predicate is pushed into the `FetchDescriptor` (SQLite-side), not filtered in Swift after the fetch
- [ ] No `print()` or `NSLog()` statements left in release builds (use `#if DEBUG` guards)
- [ ] Model saves do not block the main thread — verify with the Main Thread Checker instrument
- [ ] App launches in under 300ms on an M-series Mac (measure with `DYLD_PRINT_STATISTICS=1`)
- [ ] No retain cycles — Leaks instrument shows zero persistent leaks after 5 minutes of use

## Files Likely Involved
- `core-notes/ContentView.swift` (query hardening)
- `core-notes/NoteDetailView.swift` (save behavior)
- `core-notes/core_notesApp.swift` (container config)

## Performance Notes
- SwiftData's `ModelContext.autosaveEnabled` is `true` by default — leave it on, it batches saves intelligently.
- If note count could realistically exceed 500, add a `sortBy` + `fetchLimit` + `fetchOffset` pagination strategy.
- Use `@Query(FetchDescriptor(...))` syntax instead of the simple `@Query` sugar for full control.
