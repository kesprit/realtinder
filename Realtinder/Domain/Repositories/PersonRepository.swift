import Foundation

protocol PersonRepository: Sendable {
    func fetchPersons(page: Int, pageSize: Int) async throws -> [Person]
    func getPersonState(personId: UUID) async throws -> PersonState?
    func savePersonState(_ state: PersonState) async throws
    func getAllPersonStates() async throws -> [PersonState]
}
