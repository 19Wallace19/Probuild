import SwiftUI

struct ConcreteView: View {
    @StateObject private var vm = ConcreteViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Pour Type")) {
                        Picker("Type", selection: $vm.pourType) {
                            ForEach(vm.pourTypes, id: \.self) { t in
                                Text(t).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    if vm.showSlabInputs {
                        Section(header: Text("Dimensions")) {
                            HStack {
                                Text("Length (ft)")
                                Spacer()
                                TextField("20", value: $vm.lengthFt, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                            HStack {
                                Text("Width (ft)")
                                Spacer()
                                TextField("10", value: $vm.widthFt, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                            HStack {
                                Text("Thickness (in)")
                                Spacer()
                                TextField("4", value: $vm.thicknessIn, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }

                    if vm.showColumnInputs {
                        Section(header: Text("Column/Sonotube Dimensions")) {
                            HStack {
                                Text("Diameter (in)")
                                Spacer()
                                TextField("12", value: $vm.diameterIn, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                            HStack {
                                Text("Depth (ft)")
                                Spacer()
                                TextField("4", value: $vm.depthFt, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                            Stepper("Qty: \(vm.columnQty)", value: $vm.columnQty, in: 1...50)
                        }
                    }

                    Section(header: Text("Waste Factor")) {
                        Picker("Waste", selection: $vm.wasteFactor) {
                            Text("5% waste").tag(1.05)
                            Text("8% waste").tag(1.08)
                            Text("10% waste").tag(1.10)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .frame(height: vm.showColumnInputs ? 420 : 400)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Concrete") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Concrete Estimate")
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "Cubic Feet", value: formatCuFt(vm.cubicFeet))
                            ResultCard(title: "Cubic Yards", value: formatCuYd(vm.cubicYards), subtitle: "with \(Int((vm.wasteFactor - 1) * 100))% waste")
                            ResultCard(title: "Cubic Metres", value: String(format: "%.2f m³", vm.cubicMeters))
                            ResultCard(title: "Truck Loads", value: String(format: "%.2f loads", vm.truckLoads), subtitle: "@ 10 cu yd/truck")
                        }
                        .padding(.horizontal, 16)

                        SectionHeader(title: "Bags (if not ready-mix)")
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ResultCard(title: "80 lb Bags", value: "\(vm.bags80lb) bags", subtitle: "0.60 cu ft each")
                            ResultCard(title: "60 lb Bags", value: "\(vm.bags60lb) bags", subtitle: "0.45 cu ft each")
                        }
                        .padding(.horizontal, 16)

                        if vm.cubicYards > 1 {
                            WarningCard(message: "Over 1 cu yd — consider ready-mix concrete for cost efficiency", color: .blue)
                                .padding(.horizontal, 16)
                        }
                    }
                    .transition(.opacity)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Concrete Calculator")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
