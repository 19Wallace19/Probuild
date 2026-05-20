import SwiftUI

struct PermitView: View {
    @StateObject private var vm = PermitViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("City")) {
                        Picker("City", selection: $vm.city) {
                            ForEach(vm.cities, id: \.self) { c in
                                Text(c).tag(c)
                            }
                        }
                        .pickerStyle(.menu)
                        Text("Currency: \(vm.currency)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Section(header: Text("Permit Type")) {
                        Picker("Type", selection: $vm.permitType) {
                            ForEach(vm.permitTypes, id: \.self) { t in
                                Text(t).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    if vm.showProjectValue {
                        Section(header: Text("Project Value")) {
                            HStack {
                                Text("Construction Value ($)")
                                Spacer()
                                TextField("50000", value: $vm.projectValue, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 110)
                                    .textFieldStyle(.roundedBorder)
                            }
                            if !vm.projectValueValid {
                                Text("Project value must be greater than 0")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    if vm.showDeckArea {
                        Section(header: Text("Deck Area")) {
                            HStack {
                                Text("Deck Area (sq ft)")
                                Spacer()
                                TextField("200", value: $vm.deckAreaSqFt, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 110)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                    if vm.showAddOns {
                        Section(header: Text("Add-On Permits")) {
                            Toggle("Include Electrical Permit", isOn: $vm.includeElectrical)
                            Toggle("Include Plumbing Permit", isOn: $vm.includePlumbing)
                            Toggle("Include Mechanical Permit", isOn: $vm.includeMech)
                        }
                    }
                }
                .frame(height: 500)
                .scrollDisabled(true)

                CalcButton(title: "Estimate Permit Fees") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Permit Fee Estimate")
                            .padding(.horizontal, 16)

                        if let note = vm.calgaryDeckNote {
                            WarningCard(message: note, color: .blue)
                                .padding(.horizontal, 16)
                        }

                        VStack(spacing: 1) {
                            permitLineItem(label: "Base Permit Fee", value: vm.baseFee, currency: vm.currency)
                            permitLineItem(label: "Plan Review Fee", value: vm.planReviewFee, currency: vm.currency, subtitle: "(\(Int(vm.config.planReviewRate * 100))% of base)")
                            if vm.safetyLevy > 0 {
                                permitLineItem(label: "Safety Codes Levy", value: vm.safetyLevy, currency: vm.currency, subtitle: "(\(Int(vm.config.safetyLevyRate * 1000))‰ of project value)")
                            }
                            if vm.additionalFees > 0 {
                                Divider().padding(.vertical, 4)
                                if vm.includeElectrical {
                                    permitLineItem(label: "Electrical Permit", value: vm.config.electricalFee, currency: vm.currency)
                                }
                                if vm.includePlumbing {
                                    permitLineItem(label: "Plumbing Permit", value: vm.config.plumbingFee, currency: vm.currency)
                                }
                                if vm.includeMech {
                                    permitLineItem(label: "Mechanical Permit", value: vm.config.mechFee, currency: vm.currency)
                                }
                            }
                            Divider().padding(.vertical, 4)
                            permitLineItem(label: "ESTIMATED TOTAL", value: vm.totalFee, currency: vm.currency, bold: true, large: true, accent: Color(hex: "1A1A1A"))
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)

                        WarningCard(message: "Estimates only. Contact \(vm.city) Development Services for exact fees. Fees change annually.", color: .orange)
                            .padding(.horizontal, 16)
                    }
                    .transition(.opacity)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Permit Estimator")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func permitLineItem(label: String, value: Double, currency: String, subtitle: String? = nil, bold: Bool = false, large: Bool = false, accent: Color = .primary) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(large ? .headline : .subheadline)
                    .fontWeight(bold ? .semibold : .regular)
                    .foregroundColor(bold ? .primary : .secondary)
                if let sub = subtitle {
                    Text(sub)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(formatCurrency(value, currency: currency))
                .font(large ? .title3 : .subheadline)
                .fontWeight(bold ? .bold : .regular)
                .foregroundColor(accent)
        }
        .padding(.vertical, 4)
    }
}
