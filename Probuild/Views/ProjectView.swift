import SwiftUI
import UIKit

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Project Picker

struct ProjectPickerSheet: View {
    let entry: ProjectEntry
    @EnvironmentObject var store: ProjectStore
    @State private var showNewProject = false
    @State private var newName = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                if store.projects.isEmpty {
                    Text("No projects yet. Tap + to create one.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                ForEach(store.projects) { project in
                    Button { saveEntry(to: project) } label: {
                        projectPickerRow(project)
                    }
                }
            }
            .navigationTitle("Save to Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showNewProject = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New Project", isPresented: $showNewProject) {
                TextField("Project name", text: $newName)
                Button("Create & Save") { createAndSave() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func projectPickerRow(_ project: Project) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(project.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            if !project.clientName.isEmpty {
                Text(project.clientName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("\(project.entries.count) saved items")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func saveEntry(to project: Project) {
        store.addEntry(entry, to: project)
        dismiss()
    }

    private func createAndSave() {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var p = Project(name: newName)
        p.entries = [entry]
        store.save(p)
        dismiss()
    }
}

// MARK: - New Project Sheet

struct NewProjectSheet: View {
    var onSave: (Project) -> Void
    @State private var name = ""
    @State private var clientName = ""
    @State private var address = ""
    @State private var notes = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Info")) {
                    TextField("Project Name", text: $name)
                    TextField("Client Name", text: $clientName)
                    TextField("Address", text: $address)
                }
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var p = Project(name: name)
        p.clientName = clientName
        p.address = address
        p.notes = notes
        onSave(p)
    }
}

// MARK: - Project Detail

struct ProjectDetailView: View {
    @State var project: Project
    @EnvironmentObject var store: ProjectStore
    @State private var showShare = false

    var body: some View {
        List {
            infoSection
            entriesSection
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button { showShare = true } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [store.fileURL(for: project)])
        }
        .onAppear {
            if let fresh = store.projects.first(where: { $0.id == project.id }) {
                project = fresh
            }
        }
    }

    @ViewBuilder private var infoSection: some View {
        Section(header: Text("Info")) {
            if !project.clientName.isEmpty {
                infoRow("Client", project.clientName)
            }
            if !project.address.isEmpty {
                infoRow("Address", project.address)
            }
            infoRow("Created", project.createdAt.formatted(date: .abbreviated, time: .omitted))
            if !project.notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes").font(.caption).foregroundColor(.secondary)
                    Text(project.notes).font(.subheadline)
                }
                .padding(.vertical, 2)
            }
        }
    }

    @ViewBuilder
    private var entriesSection: some View {
        Section(header: Text("\(project.entries.count) Saved Calculations")) {
            if project.entries.isEmpty {
                Text("No calculations saved yet. Run a calculator and tap \"Save to Project\".")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(project.entries) { entry in
                    entryRow(entry)
                }
                .onDelete { indexSet in
                    var updated = project
                    updated.entries.remove(atOffsets: indexSet)
                    store.save(updated)
                    project = updated
                }
            }
        }
    }

    @ViewBuilder private func entryRow(_ entry: ProjectEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: entryIcon(entry.type))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Text(entry.summary)
                .font(.subheadline)
            if !entry.details.isEmpty {
                Text(entry.details)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(entry.createdAt, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.subheadline).multilineTextAlignment(.trailing)
        }
    }

    private func entryIcon(_ type: String) -> String {
        switch type {
        case "drywall": return "square.3.layers.3d"
        case "paint": return "paintbrush"
        case "quote": return "doc.text"
        default: return "hammer"
        }
    }
}

// MARK: - Project List

struct ProjectView: View {
    @EnvironmentObject var store: ProjectStore
    @State private var showNewProject = false
    @State private var showImportPicker = false
    @State private var importError: String? = nil
    @State private var showImportError = false

    var body: some View {
        List {
            projectListContent
        }
        .navigationTitle("Projects")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { showImportPicker = true } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showNewProject = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showNewProject) {
            NewProjectSheet(onSave: { project in
                store.save(project)
                showNewProject = false
            })
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .alert("Import Failed", isPresented: $showImportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importError ?? "Unknown error")
        }
    }

    @ViewBuilder
    private var projectListContent: some View {
        if store.projects.isEmpty {
            emptyState
        } else {
            projectRows
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("No Projects Yet")
                .font(.headline)
            Text("Create a project to save and share calculations with your team.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
    }

    private var projectRows: some View {
        ForEach(store.projects) { project in
            NavigationLink {
                ProjectDetailView(project: project)
            } label: {
                projectRow(project)
            }
        }
        .onDelete { indexSet in
            indexSet.forEach { store.delete(store.projects[$0]) }
        }
    }

    @ViewBuilder private func projectRow(_ project: Project) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.name)
                .font(.subheadline)
                .fontWeight(.semibold)
            if !project.clientName.isEmpty {
                Text(project.clientName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if !project.address.isEmpty {
                Text(project.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("\(project.entries.count) \(project.entries.count == 1 ? "item" : "items")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(project.updatedAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                try store.importProject(from: url)
            } catch {
                importError = error.localizedDescription
                showImportError = true
            }
        case .failure(let error):
            importError = error.localizedDescription
            showImportError = true
        }
    }
}
