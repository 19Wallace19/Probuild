import Foundation
import SwiftUI
import UIKit
class PermitViewModel: ObservableObject {
    @Published var city: String = "Calgary"
    @Published var permitType: String = "Addition/Reno"
    @Published var projectValue: Double = 50000
    @Published var deckAreaSqFt: Double = 200
    @Published var includeElectrical: Bool = false
    @Published var includePlumbing: Bool = false
    @Published var includeMech: Bool = false

    @Published var showResults: Bool = false

    let cities = ["Calgary", "Edmonton", "Vancouver", "Toronto", "Winnipeg", "Seattle"]
    let permitTypes = ["Addition/Reno", "New Build", "Deck", "Electrical", "Plumbing", "Mechanical", "Demo"]

    var config: PermitFeeConfig {
        PermitFeeConfig.configs[city] ?? PermitFeeConfig.configs["Calgary"]!
    }

    var baseFee: Double {
        switch permitType {
        case "Deck":
            return config.deckBase + (deckAreaSqFt / 100 * config.deckPer100SqFt)
        case "Electrical":
            return config.electricalFee
        case "Plumbing":
            return config.plumbingFee
        case "Mechanical":
            return config.mechFee
        case "Demo":
            return config.demoFee
        default:
            return Swift.max(projectValue * config.baseRate, config.minFee)
        }
    }

    var planReviewFee: Double { baseFee * config.planReviewRate }
    var safetyLevy: Double { projectValue * config.safetyLevyRate }

    var additionalFees: Double {
        (includeElectrical ? config.electricalFee : 0) +
        (includePlumbing ? config.plumbingFee : 0) +
        (includeMech ? config.mechFee : 0)
    }

    var totalFee: Double { baseFee + planReviewFee + safetyLevy + additionalFees }

    var currency: String { config.currency }

    var calgaryDeckNote: String? {
        city == "Calgary" && permitType == "Deck" ?
        "Calgary: Permit required if deck >10 sq ft AND >600mm above grade" : nil
    }

    var showDeckArea: Bool { permitType == "Deck" }
    var showProjectValue: Bool { permitType == "Addition/Reno" || permitType == "New Build" }
    var showAddOns: Bool { permitType == "Addition/Reno" || permitType == "New Build" || permitType == "Deck" }

    var projectValueValid: Bool { projectValue > 0 }
    var deckAreaValid: Bool { deckAreaSqFt > 0 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
