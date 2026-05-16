import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var selectedNote: Note?

    var body: some View {
        NavigationSplitView {
            NoteListContent(searchText: searchText, selectedNote: $selectedNote)
                .navigationTitle("Notes")
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem {
                        Button(action: addNote) {
                            Label("New Note", systemImage: "square.and.pencil")
                        }
                        .keyboardShortcut("n", modifiers: .command)
                    }
                }
        } detail: {
            if let note = selectedNote {
                NoteDetailView(note: note)
                    .id(note.persistentModelID)
            } else {
                Text("Select a note")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func addNote() {
        let note = Note()
        modelContext.insert(note)
        selectedNote = note
    }
}

// Separate struct so @Query can be re-initialized with a dynamic predicate
// whenever searchText changes. This is the correct SwiftData pattern for
// filtered queries — the predicate runs in SQLite, not in Swift.
private struct NoteListContent: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @Binding var selectedNote: Note?

    init(searchText: String, selectedNote: Binding<Note?>) {
        var descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\Note.modifiedAt, order: .reverse)]
        )
        if !searchText.isEmpty {
            descriptor.predicate = #Predicate { note in
                note.title.contains(searchText) ||
                note.body.contains(searchText)
            }
        }
        descriptor.fetchLimit = 50
        _notes = Query(descriptor)
        _selectedNote = selectedNote
    }

    var body: some View {
        List(selection: $selectedNote) {
            ForEach(notes) { note in
                NoteRowView(note: note)
                    .tag(note)
            }
            .onDelete(perform: deleteNotes)
        }
        .overlay {
            if notes.isEmpty {
                Text("No notes")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func deleteNotes(offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            if selectedNote == note { selectedNote = nil }
            modelContext.delete(note)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
