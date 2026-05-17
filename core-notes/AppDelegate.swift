import AppKit
import SwiftUI
import SwiftData
import Carbon

extension Notification.Name {
    static let quickCaptureNote = Notification.Name("quickCaptureNote")
}

// Menu-bar-first architecture:
// - NSStatusItem + NSPopover for the quick-capture icon. SwiftUI's MenuBarExtra
//   cannot be shown programmatically, so AppKit is used directly — this is the
//   one place the project intentionally crosses into UIKit-adjacent territory.
// - Carbon RegisterEventHotKey for Cmd+Shift+Space (no Accessibility entitlement
//   needed, unlike CGEventTap or NSEvent global monitors).
// - WindowGroup provides the full editor; windowShouldClose intercepts the close
//   button to hide rather than destroy the window so it can be reshown cheaply.

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    // nonisolated(unsafe): lets the C callback read this without a @MainActor hop.
    // Safe because Carbon hotkey events fire on the main thread.
    nonisolated(unsafe) private static weak var instance: AppDelegate?

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Note.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        setupStatusItem()
        setupPopover()
        registerHotKey()

        // Defer so SwiftUI finishes creating the WindowGroup window first.
        DispatchQueue.main.async { [weak self] in
            for window in NSApp.windows where !(window is NSPanel) {
                window.delegate = self
                window.orderOut(nil)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Notes")
        button.action = #selector(togglePopover)
        button.target = self
    }

    // MARK: - Popover

    private func setupPopover() {
        let content = MenuBarNoteView()
            .modelContainer(sharedModelContainer)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 380)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: content)
    }

    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    // MARK: - Main Window

    func showMainWindow() {
        popover.performClose(nil)
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { !($0 is NSPanel) }) {
            window.makeKeyAndOrderFront(nil)
        }
    }

    // Hotkey action: show the editor and signal ContentView to create a new note.
    // Posting the notification lets ContentView own creation (correct modelContext)
    // rather than AppDelegate inserting into mainContext and hoping @Query catches up.
    func quickCapture() {
        showMainWindow()
        NotificationCenter.default.post(name: .quickCaptureNote, object: nil)
    }

    // NSWindowDelegate — hide instead of destroy so the SwiftUI tree stays alive.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }

    // MARK: - Global Hotkey (Carbon)

    private func registerHotKey() {
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ -> OSStatus in
                // Carbon fires on the main thread; dispatch async for safety.
                DispatchQueue.main.async { AppDelegate.instance?.quickCapture() }
                return noErr
            },
            1, &eventSpec, nil, &eventHandlerRef
        )
        // Cmd+Shift+Space: keyCode 49 = kVK_Space
        let hotKeyID = EventHotKeyID(signature: 0x434E4F54, id: 1) // 'CNOT'
        RegisterEventHotKey(
            49,
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    deinit {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref) }
        if let ref = eventHandlerRef { RemoveEventHandler(ref) }
    }
}
