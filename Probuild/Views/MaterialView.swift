import SwiftUI

struct MaterialView: View {
    @StateObject private var vm = MaterialViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Material Type")) {
                        Picker("Material", selection: $vm.materialType) {
                            ForEach(vm.materialTypes, id: \.self) { m in
                                Text(m).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Section(header: Text("Area")) {
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
                            TextField("15", value: $vm.widthFt, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        if vm.materialType == "Paint" {
                            HStack {
                                Text("Wall Height (ft)")
                                Spacer()
                                TextField("9", value: $vm.wallHeightFt, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        if vm.lengthFt <= 0 || vm.widthFt <= 0 {
                            Text("Length and width must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    Section(header: Text("Waste Factor")) {
                        Picker("Waste", selection: $vm.wasteFactor) {
                            Text("5%").tag(1.05)
                            Text("10%").tag(1.10)
                            Text("15%").tag(1.15)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .frame(height: vm.materialType == "Paint" ? 360 : 310)
                .scrollDisabled(true)

                CalcButton(title: "Calculate Materials") {
                    vm.calculate()
                }

                if vm.showResults {
                    VStack(spacing: 12) {
                        SectionHeader(title: "Material Results")
                            .padding(.horizontal, 16)

                        ResultCard(
                            title: "Total Area",
                            value: formatSqFt(vm.areaSqFt),
                            subtitle: "with waste: \(formatSqFt(vm.areaWithWaste))"
                        )
                        .padding(.horizontal, 16)

                        switch vm.materialType {
                        case "Drywall":
                            ResultCard(title: "Drywall Sheets", value: "\(vm.drywallSheets) sheets", subtitle: vm.drywallSheetsCost)
                                .padding(.horizontal, 16)
                            ResultCard(title: "Coverage", value: "32 sq ft / sheet", subtitle: "4×8 sheets")
                                .padding(.horizontal, 16)

                        case "LVP Flooring":
                            ResultCard(title: "LVP Boxes", value: "\(vm.lvpBoxes) boxes", subtitle: vm.lvpBoxesCost)
                                .padding(.horizontal, 16)
                            ResultCard(title: "Coverage", value: "20 sq ft / box", subtitle: "typical LVP carton")
                                .padding(.horizontal, 16)

                        case "Tile":
                            ResultCard(title: "Tile Boxes", value: "\(vm.tileBoxes) boxes", subtitle: vm.tileBoxesCost)
                                .padding(.horizontal, 16)
                            ResultCard(title: "Coverage", value: "10 sq ft / box", subtitle: "verify with supplier")
                                .padding(.horizontal, 16)

                        case "Paint":
                            ResultCard(title: "Paint Gallons", value: String(format: "%.1f gal", vm.paintGallons), subtitle: vm.paintGallonsCost)
                                .padding(.horizontal, 16)
                            ResultCard(title: "Wall Area", value: formatSqFt(vm.paintSqFt), subtitle: "perimeter × height")
                                .padding(.horizontal, 16)
                            WarningCard(message: "Paint coverage assumes 1 coat. Double for 2 coats.", color: .blue)
                                .padding(.horizontal, 16)

                        case "Decking":
                            ResultCard(title: "5/4×6 Boards", value: "\(vm.deckingBoards) boards", subtitle: vm.deckingBoardsCost)
                                .padding(.horizontal, 16)
                            ResultCard(title: "Board Width", value: "5.5\" (5/4×6)", subtitle: "16 ft board length assumed")
                                .padding(.horizontal, 16)

                        case "Siding":
                            ResultCard(title: "Siding Squares", value: String(format: "%.1f sq", vm.sidingSquares), subtitle: vm.sidingSquaresCost)
                                .padding(.horizontal, 16)
                            ResultCard(title: "Coverage", value: "100 sq ft / square", subtitle: "standard siding unit")
                                .padding(.horizontal, 16)

                        default:
                            EmptyView()
                        }

                        Text("Prices vary by region. Verify with local suppliers.")
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
        .navigationTitle("Materials")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}
