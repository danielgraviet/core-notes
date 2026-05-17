import SwiftUI
import SwiftData

struct MenuBarNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recentNotes: [Note]

    init() {
        var descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\Note.modifiedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 8
        _recentNotes = Query(descriptor)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            newNoteRow
            Divider()
            noteList
        }
        .frame(width: 280, height: 380)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text("Notes")
                .font(.headline)
            Spacer()
            Button("Open Editor") {
                (NSApp.delegate as? AppDelegate)?.showMainWindow()
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var newNoteRow: some View {
        Button(action: createNote) {
            Label("New Note", systemImage: "square.and.pencil")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var noteList: some View {
        Group {
            if recentNotes.isEmpty {
                VStack {
                    Spacer()
                    Text("No notes yet")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Spacer()
                }
            } else {
                List(recentNotes) { note in
                    Button(action: { (NSApp.delegate as? AppDelegate)?.showMainWindow() }) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(note.title.isEmpty ? "Untitled" : note.title)
                                .lineLimit(1)
                            Text(note.modifiedAt, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - Actions

    private func createNote() {
        let note = Note()
        modelContext.insert(note)
        (NSApp.delegate as? AppDelegate)?.showMainWindow()
    }
}
