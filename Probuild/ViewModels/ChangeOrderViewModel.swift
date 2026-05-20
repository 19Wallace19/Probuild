import Foundation
import Combine

class ChangeOrderViewModel: ObservableObject {
    @Published var changeOrders: [ChangeOrder] = []
    @Published var originalContract: Double = 0
    @Published var filterStatus: ChangeOrderStatus? = nil

    private let storageKey = "ProBuildChangeOrders"
    private let contractKey = "ProBuildOriginalContract"

    init() {
        load()
    }

    var filtered: [ChangeOrder] {
        if let filter = filterStatus {
            return changeOrders.filter { $0.status == filter }
        }
        return changeOrders
    }

    var approvedTotal: Double {
        changeOrders.filter { $0.status == .approved }.reduce(0) { $0 + $1.amount }
    }

    var pendingTotal: Double {
        changeOrders.filter { $0.status == .pending }.reduce(0) { $0 + $1.amount }
    }

    var rejectedTotal: Double {
        changeOrders.filter { $0.status == .rejected }.reduce(0) { $0 + $1.amount }
    }

    var revisedContract: Double { originalContract + approvedTotal }

    var taxOnApproved: Double { approvedTotal * 0.05 } // GST 5%

    var approvedCount: Int { changeOrders.filter { $0.status == .approved }.count }
    var pendingCount: Int { changeOrders.filter { $0.status == .pending }.count }
    var rejectedCount: Int { changeOrders.filter { $0.status == .rejected }.count }

    func save() {
        if let encoded = try? JSONEncoder().encode(changeOrders) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
        UserDefaults.standard.set(originalContract, forKey: contractKey)
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ChangeOrder].self, from: data) {
            changeOrders = decoded
        }
        originalContract = UserDefaults.standard.double(forKey: contractKey)
    }

    func add(_ co: ChangeOrder) {
        changeOrders.append(co)
        save()
    }

    func update(_ co: ChangeOrder) {
        if let idx = changeOrders.firstIndex(where: { $0.id == co.id }) {
            changeOrders[idx] = co
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        // Map offsets from filtered array back to main array
        let idsToDelete = offsets.map { filtered[$0].id }
        changeOrders.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    func exportSummary() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        var lines: [String] = []
        lines.append("CHANGE ORDER SUMMARY")
        lines.append("Generated: \(dateFormatter.string(from: Date()))")
        lines.append(String(repeating: "=", count: 40))
        lines.append("")
        lines.append(String(format: "Original Contract:  $%.2f", originalContract))
        lines.append(String(format: "Approved Changes:   $%.2f", approvedTotal))
        lines.append(String(format: "Revised Contract:   $%.2f", revisedContract))
        lines.append(String(format: "Pending Changes:    $%.2f", pendingTotal))
        lines.append(String(format: "GST on Approved:    $%.2f", taxOnApproved))
        lines.append("")
        lines.append(String(repeating: "-", count: 40))
        lines.append("CHANGE ORDERS (\(changeOrders.count) total)")
        lines.append(String(repeating: "-", count: 40))
        lines.append("")

        for co in changeOrders.sorted(by: { $0.date > $1.date }) {
            lines.append("[\(co.status.rawValue.uppercased())] \(co.title)")
            lines.append("  Category: \(co.category)")
            lines.append("  Amount: $\(String(format: "%.2f", co.amount))")
            lines.append("  Date: \(dateFormatter.string(from: co.date))")
            if !co.notes.isEmpty {
                lines.append("  Notes: \(co.notes)")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
