import Foundation

protocol GetPersonStateUseCase {
    func execute(personId: UUID) async throws -> PersonState?
}

final class GetPersonStateUseCaseimpl: GetPersonStateUseCase {
    @Injection private var repository: PersonRepository

    func execute(personId: UUID) async throws -> PersonState? {
        try await repository.getPersonState(personId: personId)
    }
}
