import SwiftUI

struct SnowView: View {
    @StateObject private var vm = SnowViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Location")) {
                        Picker("Region", selection: $vm.region) {
                            ForEach(vm.regions, id: \.self) { r in
                                Text(r).tag(r)
                            }
                        }
                        if vm.region == "Custom" {
                            HStack {
                                Text("Ground Snow Load (kPa)")
                                Spacer()
                                TextField("1.6", value: $vm.customSs, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                    Section(header: Text("Roof")) {
                        HStack {
                            Text("Roof Area (sq ft)")
                            Spacer()
                            TextField("1500", value: $vm.roofAreaSqFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("Roof Pitch (x/12)")
                            Spacer()
                            TextField("6", value: $vm.pitch, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        Picker("Roof Type", selection: $vm.roofType) {
                            ForEach(vm.roofTypes, id: \.self) { t in
                                Text(t).tag(t)
                            }
                        }
                    }
                }
                .frame(height: vm.region == "Custom" ? 360 : 310)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Snow Load") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Snow Load Results")
                            .padding(.horizontal, 16)

                        if vm.isHighLoad {
                            WarningCard(message: "High snow load region — verify structural capacity with engineer")
                                .padding(.horizontal, 16)
                        }
                        if vm.pitchReduced {
                            WarningCard(message: "Pitch > 30° — load reduced by slope factor (\(formatDecimal(vm.pitchFactor, places: 2)))", color: .blue)
                                .padding(.horizontal, 16)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Ground Snow (Ss)", value: formatKPa(vm.ss), subtitle: vm.region)
                            ResultCard(title: "Roof Snow Load", value: formatKPa(vm.roofLoadKPa), subtitle: "Ss × Cs × pitch factor")
                            ResultCard(title: "Total Load", value: formatKN(vm.totalLoadKN))
                            ResultCard(title: "Total Load (lbs)", value: formatLbs(vm.totalLoadLbs))
                        }
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Load / sq ft", value: String(format: "%.1f psf", vm.loadPerSqFt))
                            ResultCard(title: "Pitch Factor", value: formatDecimal(vm.pitchFactor))
                            ResultCard(title: "Cs (roof type)", value: formatDecimal(vm.cs))
                            ResultCard(title: "Frost Depth", value: "\(vm.frostDepthIn)\"", subtitle: "design frost depth")
                        }
                        .padding(.horizontal, 16)

                        Text("Based on NBCC 2020 snow load provisions. Always verify with a structural engineer for permit applications.")
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
        .navigationTitle("Snow Load")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
