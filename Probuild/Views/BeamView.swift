import SwiftUI

struct BeamView: View {
    @StateObject private var vm = BeamViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Member Type")) {
                        Picker("Type", selection: $vm.memberType) {
                            ForEach(vm.memberTypes, id: \.self) { t in
                                Text(t).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    Section(header: Text("Lumber")) {
                        Picker("Size", selection: $vm.lumberSize) {
                            ForEach(vm.lumberSizes, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                        Picker("Species", selection: $vm.species) {
                            ForEach(vm.speciesOptions, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                        Stepper("Plies: \(vm.plies)", value: $vm.plies, in: 1...6)
                    }
                    Section(header: Text("Loading")) {
                        HStack {
                            Text("Total Load (psf)")
                            Spacer()
                            TextField("40", value: $vm.totalLoad, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("Tributary Width (ft)")
                            Spacer()
                            TextField("8", value: $vm.tributaryWidthFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        if vm.totalLoad <= 0 || vm.tributaryWidthFt <= 0 {
                            Text("Load and tributary width must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        Picker("Deflection Limit", selection: $vm.deflectionLimit) {
                            Text("L/240").tag(240)
                            Text("L/360").tag(360)
                            Text("L/480").tag(480)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .frame(height: 460)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Beam Span") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Span Results")
                            .padding(.horizontal, 16)

                        ResultCard(
                            title: "Maximum Span",
                            value: formatFt(vm.maxSpanFt),
                            subtitle: "Controlled by: \(vm.controlledBy)",
                            accent: Color(hex: "1A1A1A")
                        )
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Bending Span", value: formatFt(vm.spanBendingIn / 12), accent: vm.controlledBy == "Bending" ? .orange : .primary)
                            ResultCard(title: "Deflection Span", value: formatFt(vm.spanDeflectIn / 12), accent: vm.controlledBy == "Deflection" ? .orange : .primary)
                            ResultCard(title: "Section Modulus (S)", value: String(format: "%.2f in³", vm.s))
                            ResultCard(title: "Moment of Inertia (I)", value: String(format: "%.2f in⁴", vm.iMoment))
                        }
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Fb (Allowable)", value: String(format: "%.0f psi", vm.fb), subtitle: vm.species)
                            ResultCard(title: "Uniform Load (w)", value: String(format: "%.1f plf", vm.wLoad * 12), subtitle: "per linear foot")
                            ResultCard(title: "Breadth (b)", value: String(format: "%.2f\"", vm.b), subtitle: "\(vm.plies) pl\(vm.plies == 1 ? "y" : "ies")")
                            ResultCard(title: "Depth (d)", value: String(format: "%.2f\"", vm.d))
                        }
                        .padding(.horizontal, 16)

                        Text("Based on NDS simple-span bending and deflection. Verify with engineer for structural applications.")
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
        .navigationTitle("Beam Span")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
