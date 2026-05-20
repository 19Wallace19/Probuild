import SwiftUI

struct ChangeOrderView: View {
    @StateObject private var vm = ChangeOrderViewModel()
    @State private var showingAddSheet = false
    @State private var editingOrder: ChangeOrder? = nil
    @State private var showExportSheet = false
    @State private var exportText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary card
                summaryCard
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // Filter picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(label: "All", status: nil)
                        filterChip(label: "Pending", status: .pending)
                        filterChip(label: "Approved", status: .approved)
                        filterChip(label: "Rejected", status: .rejected)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }

                Divider()

                // List
                if vm.filtered.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No change orders")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Tap + to add your first change order")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(vm.filtered) { co in
                            Button {
                                editingOrder = co
                            } label: {
                                ChangeOrderRowView(changeOrder: co)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: vm.delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Change Orders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        exportText = vm.exportSummary()
                        showExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ChangeOrderFormSheet(vm: vm, existingOrder: nil)
            }
            .sheet(item: $editingOrder) { order in
                ChangeOrderFormSheet(vm: vm, existingOrder: order)
            }
            .sheet(isPresented: $showExportSheet) {
                NavigationView {
                    ScrollView {
                        Text(exportText)
                            .font(.system(.body, design: .monospaced))
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .navigationTitle("Export Summary")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showExportSheet = false }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            ShareLink(item: exportText) {
                                Image(systemName: "paperplane")
                            }
                        }
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Original Contract")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0", value: $vm.originalContract, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                            .onChange(of: vm.originalContract) { _ in vm.save() }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Revised Contract")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(vm.revisedContract))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "1A1A1A"))
                }
            }
            .padding(12)

            Divider()

            HStack {
                summaryPill(label: "Approved", value: vm.approvedTotal, count: vm.approvedCount, color: .green)
                Divider().frame(height: 36)
                summaryPill(label: "Pending", value: vm.pendingTotal, count: vm.pendingCount, color: .orange)
                Divider().frame(height: 36)
                summaryPill(label: "GST", value: vm.taxOnApproved, count: nil, color: .secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private func summaryPill(label: String, value: Double, count: Int?, color: Color) -> some View {
        VStack(spacing: 2) {
            if let count = count {
                Text("\(count) \(label)")
                    .font(.caption)
                    .foregroundColor(color)
            } else {
                Text(label)
                    .font(.caption)
                    .foregroundColor(color)
            }
            Text(formatCurrencyShort(value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color == .secondary ? .primary : color)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func filterChip(label: String, status: ChangeOrderStatus?) -> some View {
        Button {
            withAnimation { vm.filterStatus = status }
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(vm.filterStatus == status ? Color(hex: "1A1A1A") : Color(.tertiarySystemGroupedBackground))
                .foregroundColor(vm.filterStatus == status ? .white : .primary)
                .cornerRadius(20)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        String(format: "$%.2f CAD", value)
    }

    private func formatCurrencyShort(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "$%.1fK", value / 1000)
        }
        return String(format: "$%.0f", value)
    }
}

struct ChangeOrderFormSheet: View {
    @ObservedObject var vm: ChangeOrderViewModel
    var existingOrder: ChangeOrder?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var amount: Double = 0
    @State private var category: String = "Materials"
    @State private var status: ChangeOrderStatus = .pending
    @State private var notes: String = ""
    @State private var date: Date = Date()

    @State private var amountString: String = ""

    var isEditing: Bool { existingOrder != nil }
    var titleValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }
    var amountParsed: Double { Double(amountString) ?? 0 }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Change order title", text: $title)
                    if !titleValid && !title.isEmpty {
                        Text("Title is required")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Amount ($)")
                        Spacer()
                        TextField("0.00", text: $amountString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    Picker("Category", selection: $category) {
                        ForEach(ChangeOrder.categories, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                }
                Section(header: Text("Status")) {
                    Picker("Status", selection: $status) {
                        ForEach(ChangeOrderStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            if let order = existingOrder {
                                if let idx = vm.changeOrders.firstIndex(where: { $0.id == order.id }) {
                                    vm.changeOrders.remove(at: idx)
                                    vm.save()
                                }
                            }
                            dismiss()
                        } label: {
                            Text("Delete Change Order")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Change Order" : "New Change Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveOrder()
                    }
                    .disabled(!titleValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let order = existingOrder {
                    title = order.title
                    amountString = String(format: "%.2f", order.amount)
                    category = order.category
                    status = order.status
                    notes = order.notes
                    date = order.date
                }
            }
        }
    }

    private func saveOrder() {
        let co = ChangeOrder(
            id: existingOrder?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amountParsed,
            category: category,
            status: status,
            notes: notes.trimmingCharacters(in: .whitespaces),
            date: date
        )
        if isEditing {
            vm.update(co)
        } else {
            vm.add(co)
        }
        dismiss()
    }
}
