import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Bindable var note: Note
    @FocusState private var titleFocused: Bool
    @State private var touchTask: Task<Void, Never>?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Title", text: $note.title)
                .font(.title2.weight(.semibold))
                .textFieldStyle(.plain)
                .focused($titleFocused)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .onChange(of: note.title) { scheduleSave() }

            Divider()

            TextEditor(text: $note.body)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onChange(of: note.body) { scheduleSave() }
        }
        .onAppear {
            if note.title.isEmpty {
                titleFocused = true
            }
        }
        .onDisappear {
            // Flush immediately when leaving the view so modifiedAt
            // is never stale if the debounce hadn't fired yet.
            touchTask?.cancel()
            note.touch()
        }
    }

    private func scheduleSave() {
        touchTask?.cancel()
        touchTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(1))
                note.touch()
            } catch {
                // Task was cancelled — a newer keystroke is already scheduled.
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)
    let note = Note(title: "Sample Note", body: "This is the body of the note.")
    container.mainContext.insert(note)
    return NoteDetailView(note: note)
        .modelContainer(container)
        .frame(width: 500, height: 400)
}
