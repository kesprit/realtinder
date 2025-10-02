import Foundation

protocol LocalPersonStateDataSource: Sendable {
    func getState(personId: UUID) async throws -> PersonState?
    func saveState(_ state: PersonState) async throws
    func getAllStates() async throws -> [PersonState]
}

actor LocalPersonStateDataSourceImpl: LocalPersonStateDataSource {
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL = fileURL {
            self.fileURL = fileURL
        } else {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.fileURL = documentsDirectory.appendingPathComponent("person_states.json")
        }
    }

    func getState(personId: UUID) async throws -> PersonState? {
        let states = try await getAllStates()
        return states.first { $0.personId == personId }
    }

    func saveState(_ state: PersonState) async throws {
        var states = try await getAllStates()

        if let index = states.firstIndex(where: { $0.personId == state.personId }) {
            states[index] = state
        } else {
            states.append(state)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(states)
        try data.write(to: fileURL, options: [.atomic])
    }

    func getAllStates() async throws -> [PersonState] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode([PersonState].self, from: data)
    }
}
