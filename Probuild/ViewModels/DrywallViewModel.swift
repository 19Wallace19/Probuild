import Foundation
import SwiftUI
import UIKit

struct DrywallBoardOption: Identifiable {
    let id: String
    let size: String
    let sqFt: Double
    let sheetsNeeded: Int
    let isRecommended: Bool
    let reason: String
}

class DrywallViewModel: ObservableObject {
    @Published var wall1: Double = 12
    @Published var wall2: Double = 12
    @Published var wall3: Double = 10
    @Published var wall4: Double = 10
    @Published var wallHeight: Double = 9
    @Published var doors: Double = 1
    @Published var windows: Double = 2
    @Published var wastePct: Double = 10
    @Published var showResults: Bool = false

    var totalPerimeter: Double { wall1 + wall2 + wall3 + wall4 }
    var grossArea: Double { totalPerimeter * wallHeight }
    var deductions: Double { doors * 20.0 + windows * 15.0 }
    var netArea: Double { max(0, grossArea - deductions) }
    var areaWithWaste: Double { netArea * (1 + wastePct / 100) }

    var boardOptions: [DrywallBoardOption] {
        let configs: [(String, Double)] = [
            ("4×8", 32.0),
            ("4×10", 40.0),
            ("4×12", 48.0)
        ]
        return configs.map { name, sqFt in
            let sheets = Int(ceil(areaWithWaste / sqFt))
            let (rec, reason) = boardRecommendation(size: name)
            return DrywallBoardOption(id: name, size: name, sqFt: sqFt,
                                     sheetsNeeded: sheets, isRecommended: rec, reason: reason)
        }
    }

    var recommendedOption: DrywallBoardOption? {
        boardOptions.first { $0.isRecommended }
    }

    private func boardRecommendation(size: String) -> (Bool, String) {
        switch size {
        case "4×8":
            if wallHeight <= 8.5 {
                return (true, "Standard for 8ft walls — single sheet covers full height, no mid-wall seam.")
            } else {
                return (false, "Wall is taller than 8ft — needs a horizontal filler strip above each sheet.")
            }
        case "4×10":
            if wallHeight > 8.5 && wallHeight <= 9.5 {
                return (true, "Ideal for 9ft walls — single sheet reaches full height with minimal trim.")
            } else if wallHeight <= 8.5 {
                return (false, "Overkill for short walls — excess waste cutting down to height.")
            } else {
                return (false, "Wall exceeds 10ft — needs a filler strip above. Consider 4×12.")
            }
        case "4×12":
            if wallHeight > 9.5 {
                return (true, "Best for 10ft+ walls — fewest horizontal seams, fewer butt joints.")
            } else {
                return (false, "More sheet than needed — higher cost with excess trim waste.")
            }
        default:
            return (false, "")
        }
    }

    func calculate() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
