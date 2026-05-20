import Foundation
import SwiftUI
import UIKit
class WallFramingViewModel: ObservableObject {
    @Published var wallLengthFt: Double = 20
    @Published var wallHeightFt: Double = 9
    @Published var studSpacing: String = "16\""
    @Published var lumberSize: String = "2x4"
    @Published var doorCount: Int = 1
    @Published var doorWidthIn: Double = 36
    @Published var windowCount: Int = 2
    @Published var windowWidthIn: Double = 36

    @Published var showResults: Bool = false

    let spacingOptions = ["12\"", "16\"", "24\""]
    let lumberSizes = ["2x4", "2x6"]

    var spacingIn: Double {
        switch studSpacing {
        case "12\"": return 12
        case "16\"": return 16
        default: return 24
        }
    }

    var fieldStuds: Int { Int(ceil(wallLengthFt * 12 / spacingIn)) + 1 }
    var cornerStuds: Int { 2 }
    var trimmerStuds: Int { (doorCount + windowCount) * 2 }
    var totalStuds: Int { fieldStuds + cornerStuds + trimmerStuds }

    // Stud length = wall height minus 3 plates (1.5" each = 4.5")
    var studLengthIn: Double { wallHeightFt * 12 - 4.5 }
    var studLengthFt: Double { studLengthIn / 12 }

    var topPlateFt: Double { wallLengthFt * 2 } // double top plate
    var bottomPlateFt: Double { wallLengthFt }

    var headerLinFt: Double {
        Double(doorCount) * (doorWidthIn / 12 + 0.5) * 2 +
        Double(windowCount) * (windowWidthIn / 12 + 0.5) * 2
    }

    var jackStuds: Int { (doorCount + windowCount) * 2 }
    var kingStuds: Int { (doorCount + windowCount) * 2 }
    var cripples: Int { (doorCount + windowCount) * 3 }

    var totalLinearFt: Double {
        Double(totalStuds) * studLengthFt + topPlateFt + bottomPlateFt + headerLinFt
    }

    var lumberWidthIn: Double { lumberSize == "2x4" ? 3.5 : 5.5 }

    // Board feet = linear ft * width(in) / 12 * thickness(1.5in) / 12 * 12
    // Simplified: total LF * nominal width / 12
    var boardFeet: Double { totalLinearFt * (lumberSize == "2x4" ? 4.0 : 6.0) / 12 }

    var totalPlateLF: Double { topPlateFt + bottomPlateFt }
    var totalStudLF: Double { Double(totalStuds) * studLengthFt }

    var wallValid: Bool { wallLengthFt > 0 && wallHeightFt > 0 }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
