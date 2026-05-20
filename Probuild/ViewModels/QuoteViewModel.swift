import Foundation
import SwiftUI
import UIKit

class QuoteViewModel: ObservableObject {
    @Published var materialsCost: Double = 5000
    @Published var labourHours: Double = 40
    @Published var hourlyRate: Double = 85
    @Published var subcontractorCost: Double = 0
    @Published var markupPercent: Double = 20
    @Published var region: String = "Alberta"
    @Published var showResults: Bool = false

    let regions = ["Alberta", "BC", "Ontario", "USA"]

    var labourCost: Double { labourHours * hourlyRate }
    var subtotal: Double { materialsCost + labourCost + subcontractorCost }
    var markupAmount: Double { subtotal * (markupPercent / 100) }
    var beforeTax: Double { subtotal + markupAmount }

    var taxRate: Double {
        switch region {
        case "BC": return 0.12
        case "Ontario": return 0.13
        case "USA": return 0.0
        default: return 0.05
        }
    }

    var taxLabel: String {
        switch region {
        case "BC": return "HST (12%)"
        case "Ontario": return "HST (13%)"
        case "USA": return "Tax (0%)"
        default: return "GST (5%)"
        }
    }

    var taxAmount: Double { beforeTax * taxRate }
    var totalWithTax: Double { beforeTax + taxAmount }
    var grossMarginPercent: Double {
        guard beforeTax > 0 else { return 0 }
        return (markupAmount / beforeTax) * 100
    }

    var currency: String { region == "USA" ? "USD" : "CAD" }
    var markupValid: Bool { markupPercent >= 0 && markupPercent <= 300 }
    var hoursValid: Bool { labourHours >= 0 }
    var rateValid: Bool { hourlyRate > 0 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
