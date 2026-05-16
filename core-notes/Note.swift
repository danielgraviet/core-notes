import Foundation
import SwiftData

@Model
final class Note {
    var title: String
    var body: String
    var createdAt: Date
    var modifiedAt: Date

    init(title: String = "", body: String = "") {
        let now = Date.now
        self.title = title
        self.body = body
        self.createdAt = now
        self.modifiedAt = now
    }

    // Call this after mutating title or body so SwiftData fires one
    // observation notification per logical edit, not one per property.
    func touch() {
        modifiedAt = .now
    }
}
