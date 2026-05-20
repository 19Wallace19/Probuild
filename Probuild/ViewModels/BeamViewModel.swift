import Foundation
import SwiftUI
import UIKit
class BeamViewModel: ObservableObject {
    @Published var memberType: String = "Beam"
    @Published var lumberSize: String = "4x10"
    @Published var plies: Int = 1
    @Published var species: String = "SPF #2"
    @Published var totalLoad: Double = 40
    @Published var tributaryWidthFt: Double = 8
    @Published var deflectionLimit: Int = 360

    @Published var showResults: Bool = false

    let memberTypes = ["Beam", "Floor Joist", "Ceiling Joist"]
    let lumberSizes = ["2x8", "2x10", "2x12", "4x10", "4x12", "6x12"]
    let speciesOptions = ["SPF #2", "DFir #2", "HemFir #2", "DFir Select"]
    let deflectionLimits = [240, 360, 480]
    let pliesOptions = [1, 2, 3, 4]

    // Lumber dimensions: nominal -> (breadth, depth) actual inches
    let lumberDims: [String: (Double, Double)] = [
        "2x8":  (1.5,  7.25),
        "2x10": (1.5,  9.25),
        "2x12": (1.5, 11.25),
        "4x10": (3.5,  9.25),
        "4x12": (3.5, 11.25),
        "6x12": (5.5, 11.25)
    ]

    // Fb values (psi)
    let fbValues: [String: Double] = [
        "SPF #2":      900,
        "DFir #2":    1035,
        "HemFir #2":   765,
        "DFir Select": 1125
    ]

    var dims: (Double, Double) { lumberDims[lumberSize] ?? (1.5, 9.25) }

    var b: Double { dims.0 * Double(plies) }
    var d: Double { dims.1 }
    var fb: Double { fbValues[species] ?? 900 }
    var e: Double { 1_400_000.0 }

    // Section modulus S = bd²/6
    var s: Double { (b * pow(d, 2)) / 6 }

    // Moment of inertia I = bd³/12
    var iMoment: Double { (b * pow(d, 3)) / 12 }

    // Uniform load per linear inch (plf * tributary / 12)
    var wLoad: Double { totalLoad * tributaryWidthFt / 12 }

    // Max span from bending: sqrt(8*Fb*S / w) in inches
    var spanBendingIn: Double {
        guard wLoad > 0 else { return 0 }
        return sqrt((fb * s * 8) / wLoad)
    }

    // Max span from deflection: cubeRoot(384*E*I / (5*w*L/deflectionLimit))
    // L/deflLimit = span -> span = cubeRoot(384*E*I*deflLimit / (5*w))
    var spanDeflectIn: Double {
        guard wLoad > 0 else { return 0 }
        return pow((384 * e * iMoment) / (5 * wLoad * Double(deflectionLimit)), 1.0 / 3.0)
    }

    var maxSpanIn: Double { Swift.min(spanBendingIn, spanDeflectIn) }
    var maxSpanFt: Double { maxSpanIn / 12 }

    var controlledBy: String { spanBendingIn < spanDeflectIn ? "Bending" : "Deflection" }

    var spanValid: Bool { maxSpanFt > 0 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
