import Foundation
import SwiftUI
import UIKit
class MaterialViewModel: ObservableObject {
    @Published var materialType: String = "Drywall"
    @Published var lengthFt: Double = 20
    @Published var widthFt: Double = 15
    @Published var wallHeightFt: Double = 9
    @Published var wasteFactor: Double = 1.10

    @Published var showResults: Bool = false

    let materialTypes = ["Drywall", "LVP Flooring", "Tile", "Paint", "Decking", "Siding"]
    let wasteFactors = [1.05, 1.10, 1.15]
    let wasteLabels = ["5% waste", "10% waste", "15% waste"]

    var areaSqFt: Double { lengthFt * widthFt }
    var areaWithWaste: Double { areaSqFt * wasteFactor }

    // Drywall: 4x8 sheets = 32 sqft each
    var drywallSheets: Int { Int(ceil(areaWithWaste / 32)) }
    var drywallSheetsCost: String { "~$\(Int(Double(drywallSheets) * 18)) CAD (est. $18/sheet)" }

    // LVP: boxes cover 20 sqft
    var lvpBoxes: Int { Int(ceil(areaWithWaste / 20)) }
    var lvpBoxesCost: String { "~$\(Int(Double(lvpBoxes) * 65)) CAD (est. $65/box)" }

    // Tile: boxes cover 10 sqft
    var tileBoxes: Int { Int(ceil(areaWithWaste / 10)) }
    var tileBoxesCost: String { "~$\(Int(Double(tileBoxes) * 45)) CAD (est. $45/box)" }

    // Paint: 1 gallon = 350 sqft, walls = perimeter * height
    var paintSqFt: Double {
        let perimeter = (lengthFt + widthFt) * 2
        return perimeter * wallHeightFt
    }
    var paintGallons: Double { (paintSqFt * wasteFactor) / 350 }
    var paintGallonsCost: String { "~$\(Int(paintGallons * 55)) CAD (est. $55/gal)" }

    // Decking: 5/4x6 boards, 5.5" wide, 16' long
    var deckingBoards: Int {
        let boardsAcross = Int(ceil(widthFt / (5.5 / 12)))
        let boardLength: Double = 16
        let runs = Int(ceil(lengthFt / boardLength))
        return Int(ceil(Double(boardsAcross * runs) * wasteFactor))
    }
    var deckingBoardsCost: String { "~$\(Int(Double(deckingBoards) * 12)) CAD (est. $12/board)" }

    // Siding: sold by sq (100 sqft)
    var sidingSquares: Double { areaWithWaste / 100 }
    var sidingSquaresCost: String { "~$\(Int(sidingSquares * 185)) CAD (est. $185/sq)" }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
