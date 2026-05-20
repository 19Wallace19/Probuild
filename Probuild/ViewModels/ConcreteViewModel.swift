import Foundation
import SwiftUI
import UIKit
class ConcreteViewModel: ObservableObject {
    @Published var pourType: String = "Slab"
    @Published var lengthFt: Double = 20
    @Published var widthFt: Double = 10
    @Published var thicknessIn: Double = 4
    @Published var diameterIn: Double = 12
    @Published var depthFt: Double = 4
    @Published var columnQty: Int = 4
    @Published var wasteFactor: Double = 1.08

    @Published var showResults: Bool = false

    let pourTypes = ["Slab", "Strip Footing", "Foundation Wall", "Column/Sonotube"]
    let wasteFactors = [1.05, 1.08, 1.10]

    var cubicFeet: Double {
        if pourType == "Column/Sonotube" {
            return .pi * pow(diameterIn / 24, 2) * depthFt * Double(columnQty)
        }
        if pourType == "Strip Footing" || pourType == "Foundation Wall" {
            return lengthFt * widthFt * (thicknessIn / 12)
        }
        return lengthFt * widthFt * (thicknessIn / 12)
    }

    var cubicYards: Double { (cubicFeet / 27) * wasteFactor }
    var cubicMeters: Double { cubicYards * 0.7646 }
    var bags80lb: Int { Int(ceil(cubicYards * 27 / 0.6)) }
    var truckLoads: Double { cubicYards / 10 }
    var bags60lb: Int { Int(ceil(cubicYards * 27 / 0.45)) }

    var showColumnInputs: Bool { pourType == "Column/Sonotube" }
    var showSlabInputs: Bool { pourType != "Column/Sonotube" }

    func calculate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            showResults = true
        }
    }
}
