import SwiftUI

struct StairView: View {
    @StateObject private var vm = StairViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Stair Dimensions")) {
                        HStack {
                            Text("Total Rise (in)")
                            Spacer()
                            TextField("108", value: $vm.totalRiseIn, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        if vm.totalRiseIn <= 0 {
                            Text("Total rise must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        HStack {
                            Text("Tread Depth (in)")
                            Spacer()
                            TextField("10", value: $vm.treadDepthIn, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        if !vm.treadValid && vm.showResults {
                            Text("Tread depth must be ≥ \(formatDecimal(vm.minTreadIn))\" (\(vm.codeRegion))")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    Section(header: Text("Code & Lumber")) {
                        Picker("Code Region", selection: $vm.codeRegion) {
                            ForEach(vm.codeRegions, id: \.self) { r in
                                Text(r).tag(r)
                            }
                        }
                        Picker("Stringer Lumber", selection: $vm.lumberSize) {
                            ForEach(vm.lumberSizes, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                    }
                }
                .frame(height: 340)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Stairs") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Stair Results")
                            .padding(.horizontal, 16)

                        // Code Compliance
                        VStack(spacing: 8) {
                            StatusCard(
                                title: "Riser Height",
                                isValid: vm.riserValid,
                                validMessage: "\(formatDecimal(vm.actualRiserIn))\" ≤ \(formatDecimal(vm.maxRiserIn))\" max ✓",
                                invalidMessage: "\(formatDecimal(vm.actualRiserIn))\" exceeds \(formatDecimal(vm.maxRiserIn))\" max"
                            )
                            StatusCard(
                                title: "Tread Depth",
                                isValid: vm.treadValid,
                                validMessage: "\(formatDecimal(vm.treadDepthIn))\" ≥ \(formatDecimal(vm.minTreadIn))\" min ✓",
                                invalidMessage: "\(formatDecimal(vm.treadDepthIn))\" below \(formatDecimal(vm.minTreadIn))\" min"
                            )
                            StatusCard(
                                title: "Stringer Board",
                                isValid: vm.boardRemainingValid,
                                validMessage: "\(formatDecimal(vm.boardRemaining))\" remaining (≥ 3.5\") ✓",
                                invalidMessage: "\(formatDecimal(vm.boardRemaining))\" remaining — under 3.5\" min"
                            )
                        }
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Number of Risers", value: "\(vm.numRisers)")
                            ResultCard(title: "Actual Riser", value: formatIn(vm.actualRiserIn))
                            ResultCard(title: "Total Run", value: formatIn(vm.totalRunIn), subtitle: "\(formatFt(vm.totalRunIn / 12))")
                            ResultCard(title: "Stringer Angle", value: formatDeg(vm.stringerAngleDeg))
                            ResultCard(title: "Stringer Length", value: formatFt(vm.stringerLengthFt), subtitle: formatIn(vm.stringerLengthIn))
                            ResultCard(title: "Board Remaining", value: formatIn(vm.boardRemaining), accent: vm.boardRemainingValid ? .green : .red)
                        }
                        .padding(.horizontal, 16)

                        Text("Code: \(vm.codeRegion) — Max riser \(formatDecimal(vm.maxRiserIn))\", Min tread \(formatDecimal(vm.minTreadIn))\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.opacity)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Stair Calculator")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
