import SwiftUI

// MARK: - Model

struct Measurement {
    var whole: String = ""
    var numerator: String = ""
    var denominator: String = "8"
    var unit: MeasurementUnit = .inches

    var totalInches: Double? {
        let w = Double(whole) ?? 0
        let num = Double(numerator) ?? 0
        let den = Double(denominator) ?? 1
        guard den != 0 else { return nil }
        let fraction = num / den
        switch unit {
        case .inches:
            return w + fraction
        case .feetInches:
            // whole = feet, fraction part = inches as fraction
            return w * 12 + fraction
        case .mm:
            return (w + fraction) / 25.4
        case .cm:
            return (w + fraction) / 2.54
        }
    }
}

enum MeasurementUnit: String, CaseIterable {
    case inches = "in"
    case feetInches = "ft-in"
    case mm = "mm"
    case cm = "cm"

    var label: String { rawValue }
}

enum MathOperation: String, CaseIterable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
}

// MARK: - ViewModel

class MeasurementViewModel: ObservableObject {
    @Published var a = Measurement()
    @Published var b = Measurement()
    @Published var operation: MathOperation = .add
    @Published var outputUnit: MeasurementUnit = .inches

    var resultInches: Double? {
        guard let ai = a.totalInches, let bi = b.totalInches else { return nil }
        switch operation {
        case .add:      return ai + bi
        case .subtract: return ai - bi
        case .multiply: return ai * bi
        case .divide:   guard bi != 0 else { return nil }; return ai / bi
        }
    }

    var resultFormatted: String {
        guard let inches = resultInches else { return "—" }
        switch outputUnit {
        case .inches:
            return formatImperial(totalInches: inches, asFeet: false)
        case .feetInches:
            return formatImperial(totalInches: inches, asFeet: true)
        case .mm:
            let mm = inches * 25.4
            return String(format: "%.1f mm", mm)
        case .cm:
            let cm = inches * 2.54
            return String(format: "%.2f cm", cm)
        }
    }

    private func formatImperial(totalInches: Double, asFeet: Bool) -> String {
        let negative = totalInches < 0
        var remaining = abs(totalInches)

        var feet = 0
        if asFeet {
            feet = Int(remaining / 12)
            remaining = remaining.truncatingRemainder(dividingBy: 12)
        }

        let wholeInches = Int(remaining)
        let fracPart = remaining - Double(wholeInches)

        // Find best fraction from common denominators
        let denominators = [2, 4, 8, 16, 32]
        var bestNum = 0
        var bestDen = 1
        var bestErr = Double.infinity
        for den in denominators {
            let num = Int((fracPart * Double(den)).rounded())
            let err = abs(fracPart - Double(num) / Double(den))
            if err < bestErr {
                bestErr = err
                bestNum = num
                bestDen = den
            }
        }

        // Simplify fraction
        if bestNum > 0 {
            let g = gcd(bestNum, bestDen)
            bestNum /= g
            bestDen /= g
        }

        let sign = negative ? "-" : ""
        var result = sign
        if asFeet { result += "\(feet)' " }
        result += "\(wholeInches)"
        if bestNum > 0 { result += " \(bestNum)/\(bestDen)" }
        result += "\""
        return result
    }

    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }
}

// MARK: - View

struct MeasurementView: View {
    @StateObject private var vm = MeasurementViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                measurementCard(label: "Measurement A", binding: $vm.a)

                operationPicker

                measurementCard(label: "Measurement B", binding: $vm.b)

                resultCard

                outputUnitPicker
            }
            .padding()
        }
        .navigationTitle("Measurement Calc")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Subviews

    private func measurementCard(label: String, binding: Binding<Measurement>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                // Unit picker
                Picker("Unit", selection: binding.unit) {
                    ForEach(MeasurementUnit.allCases, id: \.self) { u in
                        Text(u.label).tag(u)
                    }
                }
                .pickerStyle(.segmented)

                HStack(spacing: 12) {
                    // Whole number
                    VStack(alignment: .leading, spacing: 4) {
                        Text(binding.wrappedValue.unit == .feetInches ? "Feet" : "Whole")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("0", text: binding.whole)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)
                    }

                    // Numerator
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Numerator")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("0", text: binding.numerator)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)
                    }

                    Text("/")
                        .font(.title2)
                        .padding(.top, 16)

                    // Denominator
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Denominator")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Picker("", selection: binding.denominator) {
                            ForEach(["2","4","8","16","32"], id: \.self) { d in
                                Text(d).tag(d)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator), lineWidth: 0.5))
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    private var operationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Operation")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)

            Picker("Operation", selection: $vm.operation) {
                ForEach(MathOperation.allCases, id: \.self) { op in
                    Text(op.rawValue).tag(op)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var resultCard: some View {
        VStack(spacing: 8) {
            Text("Result")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Text(vm.resultFormatted)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "1A1A1A"))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var outputUnitPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Show Result In")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)

            Picker("Output", selection: $vm.outputUnit) {
                ForEach(MeasurementUnit.allCases, id: \.self) { u in
                    Text(u.label).tag(u)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
