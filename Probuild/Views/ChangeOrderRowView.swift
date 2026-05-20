import SwiftUI

struct ChangeOrderRowView: View {
    let changeOrder: ChangeOrder

    private var statusColor: Color {
        switch changeOrder.status {
        case .approved: return .green
        case .rejected: return .red
        case .pending: return .orange
        }
    }

    private var statusIcon: String {
        switch changeOrder.status {
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .pending: return "clock.fill"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: changeOrder.date)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.title2)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(changeOrder.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(changeOrder.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(dateString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if !changeOrder.notes.isEmpty {
                    Text(changeOrder.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(changeOrder.amount >= 0 ? "+\(formatCurrency(changeOrder.amount))" : formatCurrency(changeOrder.amount))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(changeOrder.amount >= 0 ? .primary : .red)
                Text(changeOrder.status.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.12))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return (formatter.string(from: NSNumber(value: value)) ?? "$0.00")
    }
}
