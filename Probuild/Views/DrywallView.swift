import SwiftUI

struct DrywallView: View {
    @StateObject private var vm = DrywallViewModel()
    @EnvironmentObject var store: ProjectStore
    @State private var showSaveToProject = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                inputForm
                CalcButton(title: "Calculate Drywall") { vm.calculate() }
                if vm.showResults { resultsSection }
            }
        }
        .navigationTitle("Drywall Calculator")
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
            Section(header: Text("Wall Lengths (ft)")) {
                inputRow("Wall 1", value: $vm.wall1)
                inputRow("Wall 2", value: $vm.wall2)
                inputRow("Wall 3", value: $vm.wall3)
                inputRow("Wall 4", value: $vm.wall4)
                inputRow("Wall Height", value: $vm.wallHeight)
            }
            Section(header: Text("Openings")) {
                inputRow("Doors  (−20 sq ft each)", value: $vm.doors)
                inputRow("Windows  (−15 sq ft each)", value: $vm.windows)
            }
            Section(header: Text("Waste Factor")) {
                inputRow("Waste %  (recommend 10)", value: $vm.wastePct)
            }
        }
        .frame(height: 520)
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
                ResultCard(title: "Gross Area", value: formatSqFt(vm.grossArea))
                ResultCard(title: "Deductions", value: formatSqFt(vm.deductions), accent: .orange)
                ResultCard(title: "Net Area", value: formatSqFt(vm.netArea))
                ResultCard(title: "Area + Waste", value: formatSqFt(vm.areaWithWaste),
                           subtitle: "\(Int(vm.wastePct))% waste", accent: Color(hex: "1A1A1A"))
            }
            .padding(.horizontal, 16)

            SectionHeader(title: "Board Recommendations")
                .padding(.horizontal, 16)

            ForEach(vm.boardOptions) { option in
                boardCard(option)
                    .padding(.horizontal, 16)
            }

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

    private func boardCard(_ option: DrywallBoardOption) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(option.size)
                            .font(.headline)
                            .fontWeight(.bold)
                        if option.isRecommended {
                            Text("RECOMMENDED")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "1A1A1A"))
                                .cornerRadius(4)
                        }
                    }
                    Text("\(Int(option.sqFt)) sq ft per sheet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(option.sheetsNeeded)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(option.isRecommended ? Color(hex: "1A1A1A") : .primary)
                    Text("sheets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Text(option.reason)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            option.isRecommended
                ? Color(hex: "1A1A1A").opacity(0.06)
                : Color(.secondarySystemGroupedBackground)
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    option.isRecommended ? Color(hex: "1A1A1A").opacity(0.25) : Color.clear,
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(option.isRecommended ? 0 : 0.06), radius: 4, x: 0, y: 2)
    }

    // MARK: - Helpers

    private func makeProjectEntry() -> ProjectEntry {
        let rec = vm.recommendedOption
        return ProjectEntry(
            type: "drywall",
            label: "Drywall",
            summary: "\(rec?.sheetsNeeded ?? 0) sheets of \(rec?.size ?? "4×8") recommended — \(formatSqFt(vm.netArea)) net area",
            details: "Gross: \(formatSqFt(vm.grossArea))  Deductions: \(formatSqFt(vm.deductions))  Waste: \(Int(vm.wastePct))%  Height: \(String(format: "%.1f", vm.wallHeight)) ft"
        )
    }
}
