import Foundation

final class PersonRepositoryImpl: PersonRepository {
    @Injection private var remoteDataSource: RemotePersonDataSource
    @Injection private var localDataSource: LocalPersonStateDataSource

    func fetchPersons(page: Int, pageSize: Int) async throws -> [Person] {
        try await remoteDataSource.fetchPersons(page: page, pageSize: pageSize)
    }

    func getPersonState(personId: UUID) async throws -> PersonState? {
        try await localDataSource.getState(personId: personId)
    }

    func savePersonState(_ state: PersonState) async throws {
        try await localDataSource.saveState(state)
    }

    func getAllPersonStates() async throws -> [PersonState] {
        try await localDataSource.getAllStates()
    }
}
