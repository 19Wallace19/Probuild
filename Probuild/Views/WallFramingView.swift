import SwiftUI

struct WallFramingView: View {
    @StateObject private var vm = WallFramingViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Wall Dimensions")) {
                        HStack {
                            Text("Wall Length (ft)")
                            Spacer()
                            TextField("20", value: $vm.wallLengthFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("Wall Height (ft)")
                            Spacer()
                            TextField("9", value: $vm.wallHeightFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        if !vm.wallValid {
                            Text("Length and height must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    Section(header: Text("Framing")) {
                        Picker("Lumber", selection: $vm.lumberSize) {
                            ForEach(vm.lumberSizes, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)
                        Picker("Stud Spacing", selection: $vm.studSpacing) {
                            ForEach(vm.spacingOptions, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    Section(header: Text("Openings")) {
                        Stepper("Doors: \(vm.doorCount)", value: $vm.doorCount, in: 0...10)
                        if vm.doorCount > 0 {
                            HStack {
                                Text("Door Width (in)")
                                Spacer()
                                TextField("36", value: $vm.doorWidthIn, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        Stepper("Windows: \(vm.windowCount)", value: $vm.windowCount, in: 0...20)
                        if vm.windowCount > 0 {
                            HStack {
                                Text("Window Width (in)")
                                Spacer()
                                TextField("36", value: $vm.windowWidthIn, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                }
                .frame(height: 480)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Wall Framing") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Stud Breakdown")
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Field Studs", value: "\(vm.fieldStuds)")
                            ResultCard(title: "Corner Studs", value: "\(vm.cornerStuds)")
                            ResultCard(title: "Trimmer Studs", value: "\(vm.trimmerStuds)")
                            ResultCard(title: "Total Studs", value: "\(vm.totalStuds)", accent: Color(hex: "1A1A1A"))
                        }
                        .padding(.horizontal, 16)

                        SectionHeader(title: "Lumber Totals")
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Stud Length", value: formatFt(vm.studLengthFt), subtitle: formatIn(vm.studLengthIn))
                            ResultCard(title: "Top Plate", value: formatFt(vm.topPlateFt), subtitle: "double plate")
                            ResultCard(title: "Bottom Plate", value: formatFt(vm.bottomPlateFt))
                            ResultCard(title: "Header LF", value: formatFt(vm.headerLinFt))
                        }
                        .padding(.horizontal, 16)

                        ResultCard(
                            title: "Total Linear Feet",
                            value: formatFt(vm.totalLinearFt),
                            subtitle: "all framing members",
                            accent: Color(hex: "1A1A1A")
                        )
                        .padding(.horizontal, 16)

                        ResultCard(
                            title: "Board Feet",
                            value: String(format: "%.0f BF", vm.boardFeet),
                            subtitle: "\(vm.lumberSize) lumber"
                        )
                        .padding(.horizontal, 16)

                        if vm.doorCount > 0 || vm.windowCount > 0 {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Opening Hardware")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .padding(.bottom, 2)
                                Text("Jack studs: \(vm.jackStuds)   King studs: \(vm.kingStuds)   Cripples: \(vm.cripples)")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                        }
                    }
                    .transition(.opacity)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Wall Framing")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
