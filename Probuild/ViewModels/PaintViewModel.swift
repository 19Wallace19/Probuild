import Foundation
import SwiftUI
import UIKit

struct PaintBuckets {
    let fiveGallon: Int
    let oneGallon: Int
    var label: String {
        switch (fiveGallon, oneGallon) {
        case (0, 0): return "0 gal"
        case (0, let ones): return "\(ones) × 1-gal"
        case (let fives, 0): return "\(fives) × 5-gal"
        default: return "\(fiveGallon) × 5-gal + \(oneGallon) × 1-gal"
        }
    }
}

class PaintViewModel: ObservableObject {
    @Published var wallArea: Double = 0
    @Published var includeCeiling: Bool = false
    @Published var ceilingLength: Double = 12
    @Published var ceilingWidth: Double = 10
    @Published var doors: Double = 1
    @Published var windows: Double = 2
    @Published var numCoats: Double = 2
    @Published var includePrimer: Bool = true
    @Published var finishIndex: Int = 1
    @Published var showResults: Bool = false

    let finishOptions = ["Flat / Matte", "Eggshell", "Satin", "Semi-Gloss"]

    var coveragePerGallon: Double {
        switch finishIndex {
        case 0: return 400
        case 1: return 380
        case 2: return 350
        case 3: return 300
        default: return 350
        }
    }

    var primerCoverage: Double { 300.0 }

    var ceilingArea: Double { includeCeiling ? ceilingLength * ceilingWidth : 0 }
    var openingDeductions: Double { doors * 20.0 + windows * 15.0 }
    var netWallArea: Double { max(0, wallArea - openingDeductions) }
    var totalPaintableArea: Double { netWallArea + ceilingArea }

    var gallonsPerCoat: Double { totalPaintableArea / coveragePerGallon }
    var totalFinishGallons: Double { gallonsPerCoat * numCoats }
    var primerGallons: Double { includePrimer ? totalPaintableArea / primerCoverage : 0 }
    var totalGallons: Double { totalFinishGallons + primerGallons }

    func buckets(for gallons: Double) -> PaintBuckets {
        let rounded = Int(ceil(gallons))
        return PaintBuckets(fiveGallon: rounded / 5, oneGallon: rounded % 5)
    }

    var finishBuckets: PaintBuckets { buckets(for: totalFinishGallons) }
    var primerBuckets: PaintBuckets { buckets(for: primerGallons) }
    var totalBuckets: PaintBuckets { buckets(for: totalGallons) }

    var isValid: Bool { wallArea > 0 }

    func calculate() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
