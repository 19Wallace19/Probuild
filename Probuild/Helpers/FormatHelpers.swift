import Foundation

func formatCurrency(_ value: Double, currency: String = "CAD") -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    if currency == "CAD" {
        formatter.currencyCode = "CAD"
        formatter.currencySymbol = "$"
    } else if currency == "USD" {
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
    } else {
        formatter.currencyCode = currency
    }
    return (formatter.string(from: NSNumber(value: value)) ?? "$0.00") + " \(currency)"
}

func formatFt(_ value: Double) -> String {
    return String(format: "%.2f ft", value)
}

func formatIn(_ value: Double) -> String {
    return String(format: "%.2f\"", value)
}

func formatDeg(_ value: Double) -> String {
    return String(format: "%.1f°", value)
}

func formatDecimal(_ value: Double, places: Int = 2) -> String {
    return String(format: "%.\(places)f", value)
}

func formatInt(_ value: Int) -> String {
    return "\(value)"
}

func formatKPa(_ value: Double) -> String {
    return String(format: "%.2f kPa", value)
}

func formatKN(_ value: Double) -> String {
    return String(format: "%.2f kN", value)
}

func formatLbs(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    return (formatter.string(from: NSNumber(value: value)) ?? "0") + " lbs"
}

func formatGPM(_ value: Double) -> String {
    return String(format: "%.1f GPM", value)
}

func formatCFS(_ value: Double) -> String {
    return String(format: "%.4f CFS", value)
}

func formatFtPerSec(_ value: Double) -> String {
    return String(format: "%.2f ft/s", value)
}

func formatPercent(_ value: Double) -> String {
    return String(format: "%.1f%%", value)
}

func formatSqFt(_ value: Double) -> String {
    return String(format: "%.1f sq ft", value)
}

func formatCuYd(_ value: Double) -> String {
    return String(format: "%.2f cu yd", value)
}

func formatCuFt(_ value: Double) -> String {
    return String(format: "%.2f cu ft", value)
}
