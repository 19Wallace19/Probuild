import Foundation

func cubeRoot(_ x: Double) -> Double {
    return pow(x, 1.0 / 3.0)
}

func toDeg(_ rad: Double) -> Double {
    return rad * 180 / .pi
}

func toRad(_ deg: Double) -> Double {
    return deg * .pi / 180
}

func roundTo(_ value: Double, places: Int) -> Double {
    let multiplier = pow(10.0, Double(places))
    return (value * multiplier).rounded() / multiplier
}

func clamp(_ value: Double, min minVal: Double, max maxVal: Double) -> Double {
    return Swift.max(minVal, Swift.min(maxVal, value))
}
