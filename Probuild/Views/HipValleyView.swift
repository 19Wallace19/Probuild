import SwiftUI

struct HipValleyView: View {
    @StateObject private var vm = HipValleyViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Building Dimensions")) {
                        HStack {
                            Text("Building Width (ft)")
                            Spacer()
                            TextField("24", value: $vm.buildingWidthFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("Building Length (ft)")
                            Spacer()
                            TextField("32", value: $vm.buildingLengthFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        if !vm.buildingValid {
                            Text("Width and length must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
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
                    }
                    Section(header: Text("Lumber")) {
                        Picker("Lumber Size", selection: $vm.lumberSize) {
                            ForEach(vm.lumberSizes, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                    }
                }
                .frame(height: 380)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Hip & Valley") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Common Rafter")
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Common Run", value: formatFt(vm.commonRun))
                            ResultCard(title: "Rise", value: formatFt(vm.rise))
                            ResultCard(title: "Common Length", value: formatFt(vm.commonRafterLengthFt))
                            ResultCard(title: "Plumb Cut", value: formatDeg(vm.plumbCutDeg))
                            ResultCard(title: "Seat Cut", value: formatDeg(vm.seatCutDeg))
                            ResultCard(title: "Pitch Angle", value: formatDeg(vm.commonRafterAngleDeg))
                        }
                        .padding(.horizontal, 16)

                        SectionHeader(title: "Hip Rafter")
                            .padding(.horizontal, 16)

                        WarningCard(message: "Hip cheek cut is always 35.26\u{00B0} regardless of pitch", color: .blue)
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Hip Run", value: formatFt(vm.hipRun))
                            ResultCard(title: "Hip Length", value: formatFt(vm.hipLengthFt))
                            ResultCard(title: "Hip Length + OH", value: formatFt(vm.hipLengthWithOverhangFt), subtitle: "with overhang")
                            ResultCard(title: "Hip Plumb Cut", value: formatDeg(vm.hipPlumbCutDeg))
                            ResultCard(title: "Hip Seat Cut", value: formatDeg(vm.hipSeatCutDeg))
                            ResultCard(title: "Hip Cheek Cut", value: formatDeg(vm.hipCheekCutDeg), accent: .orange)
                        }
                        .padding(.horizontal, 16)

                        SectionHeader(title: "Jack Rafters")
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Diff @ 16\" O.C.", value: formatIn(vm.jackRafterDiffIn), subtitle: formatFt(vm.jackRafterDiffFt))
                            ResultCard(title: "Hip Diagonal Unit", value: formatDecimal(vm.hipDiagonalUnit), subtitle: "per ft of run")
                        }
                        .padding(.horizontal, 16)

                        ResultCard(title: "Valley Length", value: formatFt(vm.valleyLengthFt), subtitle: "equal-pitch hip = valley length")
                            .padding(.horizontal, 16)
                    }
                    .transition(.opacity)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Hip & Valley")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
