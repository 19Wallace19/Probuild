import Foundation

class ProjectStore: ObservableObject {
    @Published var projects: [Project] = []

    private let folder: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("ProBuildProjects", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    init() { load() }

    func load() {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: nil
        ) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        projects = files
            .filter { $0.pathExtension == "probuild" }
            .compactMap { url -> Project? in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(Project.self, from: data)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func save(_ project: Project) {
        var p = project
        p.updatedAt = Date()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(p) {
            let url = folder.appendingPathComponent("\(p.id.uuidString).probuild")
            try? data.write(to: url)
        }
        load()
    }

    func addEntry(_ entry: ProjectEntry, to project: Project) {
        var updated = project
        updated.entries.append(entry)
        save(updated)
    }

    func delete(_ project: Project) {
        let url = folder.appendingPathComponent("\(project.id.uuidString).probuild")
        try? FileManager.default.removeItem(at: url)
        projects.removeAll { $0.id == project.id }
    }

    func fileURL(for project: Project) -> URL {
        folder.appendingPathComponent("\(project.id.uuidString).probuild")
    }

    @discardableResult
    func importProject(from url: URL) throws -> Project {
        _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var project = try decoder.decode(Project.self, from: data)
        project.id = UUID()
        save(project)
        return project
    }
}
