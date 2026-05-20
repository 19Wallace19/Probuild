import Foundation
import Combine
import SwiftUI
import UIKit
class RafterViewModel: ObservableObject {
    @Published var spanFt: Double = 24
    @Published var pitch: Double = 6
    @Published var lumberSize: String = "2x6"
    @Published var overhangIn: Double = 12
    @Published var spacing: String = "16\""

    @Published var showResults: Bool = false

    let lumberSizes = ["2x4", "2x6", "2x8", "2x10", "2x12"]
    let spacingOptions = ["12\"", "16\"", "24\""]

    let lumberWidths: [String: Double] = [
        "2x4": 3.5,
        "2x6": 5.5,
        "2x8": 7.25,
        "2x10": 9.25,
        "2x12": 11.25
    ]

    var pitchAngleRad: Double { atan(pitch / 12) }
    var pitchAngleDeg: Double { pitchAngleRad * 180 / .pi }
    var plumbCutDeg: Double { pitchAngleDeg }
    var seatCutDeg: Double { 90 - pitchAngleDeg }
    var run: Double { spanFt / 2 }
    var overhangFt: Double { overhangIn / 12 }
    var tailIn: Double { sqrt(pow(overhangIn, 2) + pow(overhangIn * pitch / 12, 2)) }
    var rafterLengthIn: Double { sqrt(pow(run * 12, 2) + pow(run * pitch, 2)) }
    var totalLengthFt: Double { (rafterLengthIn + tailIn) / 12 }
    var ridgeHeightFt: Double { run * pitch / 12 }
    var birdsMouthDepthIn: Double { 1.5 }
    var birdsMouthWidthIn: Double { 1.5 / sin(pitchAngleRad) }
    var spacingIn: Double {
        switch spacing {
        case "12\"": return 12
        case "16\"": return 16
        default: return 24
        }
    }
    var rafterCount: Int { Int(ceil(spanFt * 12 / spacingIn)) + 1 }
    var lumberWidthIn: Double { lumberWidths[lumberSize] ?? 5.5 }
    var birdsMouthValid: Bool { birdsMouthDepthIn <= lumberWidthIn / 3 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
