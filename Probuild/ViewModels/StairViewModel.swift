import Foundation
import SwiftUI
import UIKit
class StairViewModel: ObservableObject {
    @Published var totalRiseIn: Double = 108
    @Published var treadDepthIn: Double = 10
    @Published var lumberSize: String = "2x12"
    @Published var codeRegion: String = "Canada (NBC)"

    @Published var showResults: Bool = false

    let lumberSizes = ["2x10", "2x12"]
    let codeRegions = ["Canada (NBC)", "IRC USA"]

    var maxRiserIn: Double { codeRegion == "Canada (NBC)" ? 8.25 : 7.75 }
    var minTreadIn: Double { codeRegion == "Canada (NBC)" ? 8.25 : 10.0 }
    var numRisers: Int { Int(ceil(totalRiseIn / maxRiserIn)) }
    var actualRiserIn: Double { totalRiseIn / Double(numRisers) }
    var totalRunIn: Double { treadDepthIn * Double(numRisers - 1) }
    var stringerAngleDeg: Double { atan(actualRiserIn / treadDepthIn) * 180 / .pi }
    var stringerLengthIn: Double { sqrt(pow(totalRunIn, 2) + pow(totalRiseIn, 2)) }
    var stringerLengthFt: Double { stringerLengthIn / 12 }
    var lumberWidthIn: Double { lumberSize == "2x12" ? 11.25 : 9.25 }
    var notchDepth: Double { actualRiserIn }
    var boardRemaining: Double { lumberWidthIn - notchDepth }
    var boardRemainingValid: Bool { boardRemaining >= 3.5 }
    var treadValid: Bool { treadDepthIn >= minTreadIn }
    var riserValid: Bool { actualRiserIn <= maxRiserIn }
    var totalRiseValid: Bool { totalRiseIn > 0 }
    var treadInputValid: Bool { treadDepthIn > 0 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
