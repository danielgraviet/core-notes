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
            // Only flush if the debounce is still pending (user typed but 1s hasn't elapsed).
            // Unconditional touch() here causes modifiedAt to update on every navigation,
            // which re-sorts the list and makes notes swap positions.
            guard touchTask != nil else { return }
            touchTask?.cancel()
            touchTask = nil
            note.touch()
        }
    }

    private func scheduleSave() {
        touchTask?.cancel()
        touchTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(1))
                note.touch()
                touchTask = nil  // nil out so onDisappear knows nothing is pending
            } catch {}
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
