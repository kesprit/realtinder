import XCTest
@testable import Realtinder

final class GetPersonStateUseCaseTests: XCTestCase {
    var sut: GetPersonStateUseCaseimpl!
    var mockRepository: MockPersonRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPersonRepository()
        DIContainer.shared.register(type: PersonRepository.self, component: mockRepository)
        sut = GetPersonStateUseCaseimpl()
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        DIContainer.shared.removeAll()
        super.tearDown()
    }

    func testExecute_StateExists_ReturnsPersonState() async throws {
        // Given
        let personId = UUID()
        let expectedState = PersonState(personId: personId, isSeen: true, isLiked: true)
        mockRepository.getPersonStateResult = .success(expectedState)

        // When
        let result = try await sut.execute(personId: personId)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.personId, personId)
        XCTAssertEqual(result?.isSeen, true)
        XCTAssertEqual(result?.isLiked, true)
        XCTAssertEqual(mockRepository.getPersonStateCallCount, 1)
        XCTAssertEqual(mockRepository.lastGetPersonStateId, personId)
    }

    func testExecute_StateDoesNotExist_ReturnsNil() async throws {
        // Given
        let personId = UUID()
        mockRepository.getPersonStateResult = .success(nil)

        // When
        let result = try await sut.execute(personId: personId)

        // Then
        XCTAssertNil(result)
        XCTAssertEqual(mockRepository.getPersonStateCallCount, 1)
        XCTAssertEqual(mockRepository.lastGetPersonStateId, personId)
    }

    func testExecute_StateWithSeenButNotLiked() async throws {
        // Given
        let personId = UUID()
        let expectedState = PersonState(personId: personId, isSeen: true, isLiked: nil)
        mockRepository.getPersonStateResult = .success(expectedState)

        // When
        let result = try await sut.execute(personId: personId)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.isSeen, true)
        XCTAssertNil(result?.isLiked)
    }

    func testExecute_StateWithDisliked() async throws {
        // Given
        let personId = UUID()
        let expectedState = PersonState(personId: personId, isSeen: true, isLiked: false)
        mockRepository.getPersonStateResult = .success(expectedState)

        // When
        let result = try await sut.execute(personId: personId)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.isLiked, false)
    }

    func testExecute_Failure_ThrowsError() async throws {
        // Given
        let personId = UUID()
        let expectedError = NSError(domain: "TestError", code: 500)
        mockRepository.getPersonStateResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(personId: personId)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual((error as NSError).code, 500)
        }
    }

    func testExecute_MultipleCalls_TracksDifferentPersonIds() async throws {
        // Given
        let personId1 = UUID()
        let personId2 = UUID()
        mockRepository.getPersonStateResult = .success(nil)

        // When
        _ = try await sut.execute(personId: personId1)
        _ = try await sut.execute(personId: personId2)

        // Then
        XCTAssertEqual(mockRepository.getPersonStateCallCount, 2)
        XCTAssertEqual(mockRepository.lastGetPersonStateId, personId2)
    }
}
