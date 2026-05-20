import Foundation
import SwiftUI
import UIKit
class SnowViewModel: ObservableObject {
    @Published var region: String = "Calgary"
    @Published var customSs: Double = 1.6
    @Published var roofAreaSqFt: Double = 1500
    @Published var pitch: Double = 6
    @Published var roofType: String = "Heated"

    @Published var showResults: Bool = false

    let regions = ["Calgary", "Edmonton", "Vancouver", "Toronto", "Winnipeg", "Denver", "Custom"]
    let roofTypes = ["Heated", "Cold", "Slippery Metal"]

    let groundLoads: [String: Double] = [
        "Calgary": 1.6,
        "Edmonton": 1.5,
        "Vancouver": 1.8,
        "Toronto": 1.4,
        "Winnipeg": 1.9,
        "Denver": 2.0
    ]

    let frostDepths: [String: Int] = [
        "Calgary": 48,
        "Edmonton": 42,
        "Vancouver": 24,
        "Toronto": 36,
        "Winnipeg": 54,
        "Denver": 36
    ]

    var ss: Double {
        if region == "Custom" { return customSs }
        return groundLoads[region] ?? 1.6
    }

    var cs: Double {
        switch roofType {
        case "Cold": return 1.0
        case "Slippery Metal": return 0.70
        default: return 0.85 // Heated
        }
    }

    var pitchAngleDeg: Double { atan(pitch / 12) * 180 / .pi }

    var pitchFactor: Double {
        if pitchAngleDeg > 30 {
            return Swift.max(0, (70 - pitchAngleDeg) / 40)
        }
        return 1.0
    }

    var roofLoadKPa: Double { ss * cs * pitchFactor }
    var areaSqM: Double { roofAreaSqFt * 0.0929 }
    var totalLoadKN: Double { roofLoadKPa * areaSqM }
    var totalLoadLbs: Double { totalLoadKN * 224.8 }
    var totalLoadKg: Double { totalLoadKN * 101.97 }

    var frostDepthIn: Int {
        if region == "Custom" { return 48 }
        return frostDepths[region] ?? 48
    }

    var loadPerSqFt: Double { totalLoadLbs / roofAreaSqFt }

    var isHighLoad: Bool { roofLoadKPa > 1.8 }
    var pitchReduced: Bool { pitchAngleDeg > 30 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
