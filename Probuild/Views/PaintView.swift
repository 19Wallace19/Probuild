import SwiftUI

struct PaintView: View {
    @StateObject private var vm = PaintViewModel()
    @EnvironmentObject var store: ProjectStore
    @State private var showSaveToProject = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                inputForm
                if !vm.isValid {
                    WarningCard(message: "Enter a wall area greater than 0 to calculate.")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                CalcButton(title: "Calculate Paint") { vm.calculate() }
                if vm.showResults { resultsSection }
            }
        }
        .navigationTitle("Paint Calculator")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showSaveToProject) {
            ProjectPickerSheet(entry: makeProjectEntry())
                .environmentObject(store)
        }
    }

    // MARK: - Input

    private var inputForm: some View {
        Form {
            Section(header: Text("Wall Area")) {
                inputRow("Total Wall Area (sq ft)", value: $vm.wallArea)
                Text("Tip: use Drywall Calculator to get net area, then enter it here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Section(header: Text("Openings (subtract)")) {
                inputRow("Doors  (−20 sq ft each)", value: $vm.doors)
                inputRow("Windows  (−15 sq ft each)", value: $vm.windows)
            }
            Section(header: Text("Ceiling")) {
                Toggle("Include Ceiling", isOn: $vm.includeCeiling)
                if vm.includeCeiling {
                    inputRow("Ceiling Length (ft)", value: $vm.ceilingLength)
                    inputRow("Ceiling Width (ft)", value: $vm.ceilingWidth)
                }
            }
            Section(header: Text("Paint")) {
                Picker("Finish", selection: $vm.finishIndex) {
                    ForEach(0..<vm.finishOptions.count, id: \.self) { i in
                        Text(vm.finishOptions[i]).tag(i)
                    }
                }
                inputRow("Finish Coats", value: $vm.numCoats)
                Toggle("Include Primer Coat", isOn: $vm.includePrimer)
            }
        }
        .frame(height: vm.includeCeiling ? 560 : 480)
        .scrollDisabled(true)
    }

    private func inputRow(_ label: String, value: Binding<Double>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
                .textFieldStyle(.roundedBorder)
        }
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Area Summary")
                .padding(.horizontal, 16)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ResultCard(title: "Wall Area", value: formatSqFt(vm.netWallArea))
                if vm.includeCeiling {
                    ResultCard(title: "Ceiling Area", value: formatSqFt(vm.ceilingArea))
                }
                ResultCard(title: "Total Paintable", value: formatSqFt(vm.totalPaintableArea),
                           accent: Color(hex: "1A1A1A"))
                ResultCard(title: "Coverage/Gal",
                           value: formatSqFt(vm.coveragePerGallon),
                           subtitle: vm.finishOptions[vm.finishIndex])
            }
            .padding(.horizontal, 16)

            SectionHeader(title: "Paint Required")
                .padding(.horizontal, 16)

            VStack(spacing: 10) {
                paintRow(
                    label: "\(vm.finishOptions[vm.finishIndex]) × \(Int(vm.numCoats)) coat\(Int(vm.numCoats) == 1 ? "" : "s")",
                    gallons: vm.totalFinishGallons,
                    buckets: vm.finishBuckets,
                    primary: true
                )

                if vm.includePrimer {
                    paintRow(
                        label: "Primer × 1 coat",
                        gallons: vm.primerGallons,
                        buckets: vm.primerBuckets,
                        primary: false
                    )
                }

                if vm.includePrimer {
                    Divider()
                        .padding(.horizontal, 8)
                    paintRow(
                        label: "Total Paint",
                        gallons: vm.totalGallons,
                        buckets: vm.totalBuckets,
                        primary: true
                    )
                }
            }
            .padding(.horizontal, 16)

            coverageNote
                .padding(.horizontal, 16)

            Button {
                showSaveToProject = true
            } label: {
                Label("Save to Project", systemImage: "folder.badge.plus")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "1A1A1A"))
            }
            .padding(.vertical, 12)
        }
        .transition(.opacity)
        .padding(.bottom, 24)
    }

    private func paintRow(label: String, gallons: Double, buckets: PaintBuckets, primary: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(primary ? .subheadline : .subheadline)
                    .fontWeight(primary ? .semibold : .regular)
                Text(buckets.label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f gal", gallons))
                    .font(.headline)
                    .fontWeight(primary ? .bold : .regular)
                    .foregroundColor(primary ? Color(hex: "1A1A1A") : .primary)
                Text("(\(Int(ceil(gallons))) rounded up)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var coverageNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Coverage Assumptions")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text("Flat/Matte 400 · Eggshell 380 · Satin 350 · Semi-Gloss 300 sq ft/gal (1 coat). Primer 300 sq ft/gal. Standard wall paint on smooth drywall. Rough or textured surfaces may use 15–20% more.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }

    // MARK: - Helpers

    private func makeProjectEntry() -> ProjectEntry {
        ProjectEntry(
            type: "paint",
            label: "Paint",
            summary: String(format: "%.1f gal finish + %.1f gal primer = %.1f gal total",
                            vm.totalFinishGallons, vm.primerGallons, vm.totalGallons),
            details: "Net wall area: \(formatSqFt(vm.netWallArea))  Finish: \(vm.finishOptions[vm.finishIndex])  Coats: \(Int(vm.numCoats))  \(vm.includePrimer ? "Primer included" : "No primer")"
        )
    }
}
