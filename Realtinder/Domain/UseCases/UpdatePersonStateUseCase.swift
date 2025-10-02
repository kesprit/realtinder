import Foundation

protocol UpdatePersonStateUseCase {
    func execute(
        personId: UUID,
        isSeen: Bool,
        isLiked: Bool?
    ) async throws
}

final class UpdatePersonStateUseCaseImpl: UpdatePersonStateUseCase {
    @Injection private var repository: PersonRepository

    func execute(
        personId: UUID,
        isSeen: Bool,
        isLiked: Bool?
    ) async throws {
        let state = PersonState(
            personId: personId,
            isSeen: isSeen,
            isLiked: isLiked
        )
        try await repository.savePersonState(state)
    }
}
