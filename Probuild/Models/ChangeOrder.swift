import Foundation

enum ChangeOrderStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}

struct ChangeOrder: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var amount: Double
    var category: String
    var status: ChangeOrderStatus
    var notes: String
    var date: Date

    static let categories = [
        "Electrical",
        "Framing",
        "Plumbing",
        "Finishing",
        "Site Work",
        "Materials",
        "Other"
    ]
}
