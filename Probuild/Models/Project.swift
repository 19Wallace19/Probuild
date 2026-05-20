import Foundation

struct ProjectEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var type: String
    var label: String
    var summary: String
    var details: String
    var createdAt: Date = Date()
}

struct Project: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var clientName: String = ""
    var address: String = ""
    var notes: String = ""
    var entries: [ProjectEntry] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}
