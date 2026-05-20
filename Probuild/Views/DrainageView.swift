import SwiftUI

struct DrainageView: View {
    @StateObject private var vm = DrainageViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Pipe Specs")) {
                        Picker("Diameter", selection: $vm.pipeDiameterIn) {
                            ForEach(vm.pipeDiameterOptions, id: \.self) { d in
                                Text("\(Int(d))\" pipe").tag(d)
                            }
                        }
                        HStack {
                            Text("Run Length (ft)")
                            Spacer()
                            TextField("100", value: $vm.runLengthFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("Slope (in/ft)")
                            Spacer()
                            TextField("0.25", value: $vm.slopeInPerFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        if !vm.slopeValid {
                            Text("Slope must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    Section(header: Text("Drainage Area")) {
                        HStack {
                            Text("Area (sq ft)")
                            Spacer()
                            TextField("5000", value: $vm.drainageAreaSqFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("Rainfall (in/hr)")
                            Spacer()
                            TextField("2.0", value: $vm.rainfallIntensityInHr, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        Picker("Runoff Coefficient", selection: $vm.runoffCoefficient) {
                            ForEach(0..<vm.runoffOptions.count, id: \.self) { i in
                                Text(vm.runoffLabels[i]).tag(vm.runoffOptions[i])
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .frame(height: 440)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Drainage") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Pipe Capacity (Manning's)")
                            .padding(.horizontal, 16)

                        if let warning = vm.velocityWarning {
                            WarningCard(message: warning)
                                .padding(.horizontal, 16)
                        }

                        StatusCard(
                            title: "Pipe Capacity",
                            isValid: vm.capacitySufficient,
                            validMessage: "Pipe capacity sufficient for peak runoff",
                            invalidMessage: "Pipe undersized — increase diameter or slope"
                        )
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Flow Velocity", value: formatFtPerSec(vm.velocity), accent: vm.velocityWarning != nil ? .orange : .primary)
                            ResultCard(title: "Pipe Flow", value: formatGPM(vm.flowGPM))
                            ResultCard(title: "Peak Runoff", value: formatGPM(vm.peakRunoffGPM), subtitle: "rational method")
                            ResultCard(title: "Flow (CFS)", value: formatCFS(vm.flowCFS))
                        }
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Slope", value: String(format: "%.3f ft/ft", vm.slope), subtitle: "\(formatDecimal(vm.slopeInPerFt))\" per foot")
                            ResultCard(title: "Hydraulic Radius", value: String(format: "%.4f ft", vm.hydraulicRadius))
                            ResultCard(title: "Pipe Area", value: String(format: "%.4f sq ft", vm.areaPipe))
                            ResultCard(title: "Manning's n", value: "\(vm.n)", subtitle: "PVC smooth pipe")
                        }
                        .padding(.horizontal, 16)

                        Text("Manning's equation for full-flow PVC pipe (n=0.013). Calgary design storm: 2\" / hr for 5-yr return.")
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
        .navigationTitle("Drainage")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
