import Foundation
import SwiftUI
import UIKit
class DrainageViewModel: ObservableObject {
    @Published var runLengthFt: Double = 100
    @Published var pipeDiameterIn: Double = 4
    @Published var slopeInPerFt: Double = 0.25
    @Published var drainageAreaSqFt: Double = 5000
    @Published var rainfallIntensityInHr: Double = 2.0
    @Published var runoffCoefficient: Double = 0.9

    @Published var showResults: Bool = false

    let pipeDiameterOptions: [Double] = [3, 4, 6, 8, 10, 12]
    let runoffOptions: [Double] = [0.9, 0.85, 0.35, 0.25]
    let runoffLabels = ["Roof (0.90)", "Paved (0.85)", "Lawn (0.35)", "Meadow (0.25)"]

    var runoffLabelForValue: String {
        switch runoffCoefficient {
        case 0.9: return "Roof"
        case 0.85: return "Paved"
        case 0.35: return "Lawn"
        case 0.25: return "Meadow"
        default: return "Custom"
        }
    }

    // Manning's n for PVC
    var n: Double { 0.013 }

    // Radius in feet
    var radius: Double { pipeDiameterIn / (2 * 12) }

    // Cross-sectional area of full pipe (sq ft)
    var areaPipe: Double { .pi * pow(radius, 2) }

    // Hydraulic radius for full pipe = radius/2
    var hydraulicRadius: Double { radius / 2 }

    // Slope in ft/ft
    var slope: Double { slopeInPerFt / 12 }

    // Manning's velocity (ft/s)
    var velocity: Double {
        guard slope > 0 else { return 0 }
        return (1.0 / n) * pow(hydraulicRadius, 2.0 / 3.0) * pow(slope, 0.5)
    }

    // Flow in CFS (cubic feet per second)
    var flowCFS: Double { velocity * areaPipe }

    // Flow in GPM
    var flowGPM: Double { flowCFS * 448.83 }

    // Rational method: Q = C * i * A / 43560 (acres), here in sqft/3600 for inches/hr
    var peakRunoffCFS: Double {
        (rainfallIntensityInHr / 12) * drainageAreaSqFt * runoffCoefficient / 3600
    }

    var peakRunoffGPM: Double { peakRunoffCFS * 448.83 }

    var capacitySufficient: Bool { flowGPM >= peakRunoffGPM }

    var velocityWarning: String? {
        if velocity < 2 { return "Velocity < 2 ft/s — sediment buildup risk" }
        if velocity > 10 { return "Velocity > 10 ft/s — pipe scour risk" }
        return nil
    }

    var slopeValid: Bool { slopeInPerFt > 0 }
    var diameterValid: Bool { pipeDiameterIn > 0 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
