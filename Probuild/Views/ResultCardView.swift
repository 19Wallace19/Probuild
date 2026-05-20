import SwiftUI

struct ResultCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var accent: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(accent)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct ResultCardWide: View {
    let title: String
    let leftLabel: String
    let leftValue: String
    let rightLabel: String
    let rightValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(leftLabel)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(leftValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(rightLabel)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(rightValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct WarningCard: View {
    let message: String
    var color: Color = .orange

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(color)
            Text(message)
                .font(.subheadline)
                .foregroundColor(color == .orange ? .orange : color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatusCard: View {
    let title: String
    let isValid: Bool
    let validMessage: String
    let invalidMessage: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(isValid ? validMessage : invalidMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isValid ? .green : .red)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}
