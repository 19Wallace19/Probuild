import SwiftUI

struct QuoteView: View {
    @StateObject private var vm = QuoteViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                inputForm
                CalcButton(title: "Build Quote") { vm.calculate() }
                if vm.showResults { resultsSection }
            }
        }
        .navigationTitle("Quote Builder")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }

    var inputForm: some View {
        Form {
            Section(header: Text("Region & Tax")) {
                Picker("Region", selection: $vm.region) {
                    ForEach(vm.regions, id: \.self) { r in Text(r).tag(r) }
                }
            }
            Section(header: Text("Costs")) { costRows }
            Section(header: Text("Markup")) { markupRow }
        }
        .frame(height: 460)
        .scrollDisabled(true)
    }

    @ViewBuilder var costRows: some View {
        HStack {
            Text("Materials"); Spacer()
            TextField("5000", value: $vm.materialsCost, format: .number)
                .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .frame(width: 110).textFieldStyle(.roundedBorder)
        }
        HStack {
            Text("Labour Hours"); Spacer()
            TextField("40", value: $vm.labourHours, format: .number)
                .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .frame(width: 110).textFieldStyle(.roundedBorder)
        }
        if !vm.hoursValid { Text("Labour hours must be 0 or more").font(.caption).foregroundColor(.red) }
        HStack {
            Text("Hourly Rate ($)"); Spacer()
            TextField("85", value: $vm.hourlyRate, format: .number)
                .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .frame(width: 110).textFieldStyle(.roundedBorder)
        }
        if !vm.rateValid { Text("Hourly rate must be greater than 0").font(.caption).foregroundColor(.red) }
        HStack {
            Text("Subcontractors"); Spacer()
            TextField("0", value: $vm.subcontractorCost, format: .number)
                .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .frame(width: 110).textFieldStyle(.roundedBorder)
        }
    }

    @ViewBuilder var markupRow: some View {
        HStack {
            Text("Markup %"); Spacer()
            TextField("20", value: $vm.markupPercent, format: .number)
                .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .frame(width: 110).textFieldStyle(.roundedBorder)
        }
        if !vm.markupValid { Text("Markup must be between 0% and 300%").font(.caption).foregroundColor(.red) }
    }

    var resultsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Quote Breakdown").padding(.horizontal, 16)
            breakdownCard
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ResultCard(title: "Markup %", value: formatPercent(vm.markupPercent), subtitle: "on cost")
                ResultCard(title: "Gross Margin %", value: formatPercent(vm.grossMarginPercent), subtitle: "on revenue", accent: vm.grossMarginPercent < 15 ? .orange : .green)
            }
            .padding(.horizontal, 16)
            WarningCard(message: "Markup % \u{2260} Gross Margin %. A 20% markup = \(formatDecimal(vm.grossMarginPercent, places: 1))% gross margin.", color: .orange)
                .padding(.horizontal, 16)
        }
        .transition(.opacity)
        .padding(.bottom, 24)
    }

    var breakdownCard: some View {
        VStack(spacing: 1) {
            quoteRow("Materials", vm.materialsCost)
            quoteRow("Labour (\(formatDecimal(vm.labourHours, places: 0)) hrs @ $\(formatDecimal(vm.hourlyRate, places: 0))/hr)", vm.labourCost)
            Divider().padding(.vertical, 4)
            quoteRow("Subtotal", vm.subtotal, bold: true)
            quoteRow("Markup (\(formatDecimal(vm.markupPercent, places: 0))%)", vm.markupAmount)
            Divider().padding(.vertical, 4)
            quoteRow("Before Tax", vm.beforeTax, bold: true)
            quoteRow(vm.taxLabel, vm.taxAmount)
            Divider().padding(.vertical, 4)
            quoteRow("TOTAL", vm.totalWithTax, bold: true, large: true)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    private func quoteRow(_ label: String, _ value: Double, bold: Bool = false, large: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(large ? .headline : .subheadline)
                .fontWeight(bold ? .semibold : .regular)
                .foregroundColor(bold ? .primary : .secondary)
            Spacer()
            Text(formatCurrency(value, currency: vm.currency))
                .font(large ? .title3 : .subheadline)
                .fontWeight(bold ? .bold : .regular)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}
