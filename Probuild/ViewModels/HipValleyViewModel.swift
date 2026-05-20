import Foundation
import SwiftUI
import UIKit
class HipValleyViewModel: ObservableObject {
    @Published var buildingWidthFt: Double = 24
    @Published var buildingLengthFt: Double = 32
    @Published var pitch: Double = 6
    @Published var lumberSize: String = "2x8"
    @Published var overhangIn: Double = 12

    @Published var showResults: Bool = false

    let lumberSizes = ["2x6", "2x8", "2x10", "2x12"]

    var commonRun: Double { buildingWidthFt / 2 }
    var rise: Double { commonRun * pitch / 12 }

    var commonRafterLengthFt: Double { sqrt(pow(commonRun, 2) + pow(rise, 2)) }

    // Hip run is diagonal of the corner: sqrt(2) * halfWidth
    var hipRun: Double { sqrt(2) * commonRun }

    var hipAngleDeg: Double { atan(rise / hipRun) * 180 / .pi }
    var hipPlumbCutDeg: Double { hipAngleDeg }
    var hipSeatCutDeg: Double { 90 - hipAngleDeg }

    // Hip cheek cut (side cut) is always 45° projected, but the true dihedral is 35.26° for any pitch
    var hipCheekCutDeg: Double { 35.26 }

    // Diagonal unit run for hip: sqrt(pitch² + 12² + 12²) / 12
    var hipDiagonalUnit: Double { sqrt(pow(pitch, 2) + 144 + 144) / 12 }

    var hipLengthFt: Double { sqrt(pow(hipRun, 2) + pow(rise, 2)) }

    // Jack rafter common difference at 16" OC
    var spacingIn: Double { 16.0 }
    var jackRafterDiffIn: Double { sqrt(1 + pow(pitch / 12, 2)) * spacingIn }
    var jackRafterDiffFt: Double { jackRafterDiffIn / 12 }

    // Valley rafter (same length as hip for equal-pitch hips)
    var valleyLengthFt: Double { hipLengthFt }

    // Overhang extension
    var overhangFt: Double { overhangIn / 12 }
    var hipLengthWithOverhangFt: Double {
        let hipOverhang = sqrt(2) * overhangFt
        return hipLengthFt + hipOverhang
    }

    var commonRafterAngleDeg: Double { atan(pitch / 12) * 180 / .pi }
    var plumbCutDeg: Double { commonRafterAngleDeg }
    var seatCutDeg: Double { 90 - commonRafterAngleDeg }

    var buildingValid: Bool { buildingWidthFt > 0 && buildingLengthFt > 0 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
