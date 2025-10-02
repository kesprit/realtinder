import XCTest
@testable import Realtinder

final class UpdatePersonStateUseCaseTests: XCTestCase {
    var sut: UpdatePersonStateUseCaseImpl!
    var mockRepository: MockPersonRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPersonRepository()
        DIContainer.shared.register(type: PersonRepository.self, component: mockRepository)
        sut = UpdatePersonStateUseCaseImpl()
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        DIContainer.shared.removeAll()
        super.tearDown()
    }

    func testExecute_Success_SavesPersonState() async throws {
        // Given
        let personId = UUID()
        mockRepository.savePersonStateResult = .success(())

        // When
        try await sut.execute(personId: personId, isSeen: true, isLiked: true)

        // Then
        XCTAssertEqual(mockRepository.savePersonStateCallCount, 1)
        XCTAssertEqual(mockRepository.lastSavedPersonState?.personId, personId)
        XCTAssertEqual(mockRepository.lastSavedPersonState?.isSeen, true)
        XCTAssertEqual(mockRepository.lastSavedPersonState?.isLiked, true)
    }

    func testExecute_WithSeenButNotLiked() async throws {
        // Given
        let personId = UUID()
        mockRepository.savePersonStateResult = .success(())

        // When
        try await sut.execute(personId: personId, isSeen: true, isLiked: nil)

        // Then
        XCTAssertEqual(mockRepository.lastSavedPersonState?.personId, personId)
        XCTAssertEqual(mockRepository.lastSavedPersonState?.isSeen, true)
        XCTAssertNil(mockRepository.lastSavedPersonState?.isLiked)
    }

    func testExecute_WithSeenAndDisliked() async throws {
        // Given
        let personId = UUID()
        mockRepository.savePersonStateResult = .success(())

        // When
        try await sut.execute(personId: personId, isSeen: true, isLiked: false)

        // Then
        XCTAssertEqual(mockRepository.lastSavedPersonState?.personId, personId)
        XCTAssertEqual(mockRepository.lastSavedPersonState?.isSeen, true)
        XCTAssertEqual(mockRepository.lastSavedPersonState?.isLiked, false)
    }

    func testExecute_Failure_ThrowsError() async throws {
        // Given
        let personId = UUID()
        let expectedError = NSError(domain: "TestError", code: 500)
        mockRepository.savePersonStateResult = .failure(expectedError)

        // When/Then
        do {
            try await sut.execute(personId: personId, isSeen: true, isLiked: true)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual((error as NSError).code, 500)
        }
    }

    func testExecute_NotSeen_SavesCorrectly() async throws {
        // Given
        let personId = UUID()
        mockRepository.savePersonStateResult = .success(())

        // When
        try await sut.execute(personId: personId, isSeen: false, isLiked: nil)

        // Then
        XCTAssertEqual(mockRepository.lastSavedPersonState?.isSeen, false)
        XCTAssertNil(mockRepository.lastSavedPersonState?.isLiked)
    }
}
