import Foundation

protocol FetchPersonsUseCase {
    func execute(
        page: Int,
        pageSize: Int
    ) async throws -> [Person]
}

final class FetchPersonsUseCaseImpl: FetchPersonsUseCase {
    @Injection private var repository: PersonRepository

    func execute(
        page: Int,
        pageSize: Int
    ) async throws -> [Person] {
        try await repository.fetchPersons(page: page, pageSize: pageSize)
    }
}
