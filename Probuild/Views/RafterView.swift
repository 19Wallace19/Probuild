import SwiftUI

struct RafterView: View {
    @StateObject private var vm = RafterViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Roof Dimensions")) {
                        HStack {
                            Text("Building Span (ft)")
                            Spacer()
                            TextField("24", value: $vm.spanFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("Pitch (x/12)")
                            Spacer()
                            TextField("6", value: $vm.pitch, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("Overhang (in)")
                            Spacer()
                            TextField("12", value: $vm.overhangIn, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        if vm.spanFt <= 0 {
                            Text("Span must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        if vm.pitch <= 0 {
                            Text("Pitch must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    Section(header: Text("Lumber")) {
                        Picker("Lumber Size", selection: $vm.lumberSize) {
                            ForEach(vm.lumberSizes, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                        Picker("Spacing", selection: $vm.spacing) {
                            ForEach(vm.spacingOptions, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                    }
                }
                .frame(height: 380)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Rafters") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Rafter Results")
                            .padding(.horizontal, 16)

                        if !vm.birdsMouthValid {
                            WarningCard(message: "Bird's mouth depth exceeds 1/3 lumber width — consider larger lumber")
                                .padding(.horizontal, 16)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Rafter Length", value: formatFt(vm.totalLengthFt), subtitle: "incl. tail")
                            ResultCard(title: "Ridge Height", value: formatFt(vm.ridgeHeightFt))
                            ResultCard(title: "Plumb Cut", value: formatDeg(vm.plumbCutDeg))
                            ResultCard(title: "Seat Cut", value: formatDeg(vm.seatCutDeg))
                            ResultCard(title: "Bird's Mouth Width", value: formatIn(vm.birdsMouthWidthIn), accent: vm.birdsMouthValid ? .primary : .orange)
                            ResultCard(title: "Bird's Mouth Depth", value: formatIn(vm.birdsMouthDepthIn))
                        }
                        .padding(.horizontal, 16)

                        ResultCard(title: "Rafter Count", value: "\(vm.rafterCount) rafters", subtitle: "at \(vm.spacing) O.C. for \(formatDecimal(vm.spanFt, places: 1)) ft span")
                            .padding(.horizontal, 16)

                        ResultCard(title: "Pitch Angle", value: formatDeg(vm.pitchAngleDeg), subtitle: "arctan(\(formatDecimal(vm.pitch, places: 1))/12)")
                            .padding(.horizontal, 16)

                        Text("Note: Rafter count is per side — double for full roof")
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
        .navigationTitle("Rafter Calculator")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
