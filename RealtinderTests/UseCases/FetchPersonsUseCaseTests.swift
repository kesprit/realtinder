import XCTest
@testable import Realtinder

final class FetchPersonsUseCaseTests: XCTestCase {
    var sut: FetchPersonsUseCaseImpl!
    var mockRepository: MockPersonRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPersonRepository()
        DIContainer.shared.register(type: PersonRepository.self, component: mockRepository)
        sut = FetchPersonsUseCaseImpl()
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        DIContainer.shared.removeAll()
        super.tearDown()
    }

    func testExecute_Success_ReturnsPersons() async throws {
        // Given
        let expectedPersons = [
            Person(id: UUID(), name: "John", age: 25, photos: [], bio: "Test bio"),
            Person(id: UUID(), name: "Jane", age: 28, photos: [], bio: "Another bio")
        ]
        mockRepository.fetchPersonsResult = .success(expectedPersons)

        // When
        let result = try await sut.execute(page: 0, pageSize: 10)

        // Then
        XCTAssertEqual(result.count, expectedPersons.count)
        XCTAssertEqual(mockRepository.fetchPersonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPersonsPage, 0)
        XCTAssertEqual(mockRepository.lastFetchPersonsPageSize, 10)
    }

    func testExecute_Failure_ThrowsError() async throws {
        // Given
        let expectedError = NSError(domain: "TestError", code: 500)
        mockRepository.fetchPersonsResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(page: 0, pageSize: 10)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual((error as NSError).code, 500)
        }
    }

    func testExecute_WithDifferentPageParameters() async throws {
        // Given
        mockRepository.fetchPersonsResult = .success([])

        // When
        _ = try await sut.execute(page: 2, pageSize: 20)

        // Then
        XCTAssertEqual(mockRepository.lastFetchPersonsPage, 2)
        XCTAssertEqual(mockRepository.lastFetchPersonsPageSize, 20)
    }
}

// MARK: - Mock Repository
class MockPersonRepository: PersonRepository {
    var getAllPersonStatesResult: Result<[PersonState], Error> = .success([])
    var getAllPersonStatesCallCount = 0

    func getAllPersonStates() async throws -> [PersonState] {
        getAllPersonStatesCallCount += 1
        return try getAllPersonStatesResult.get()
    }

    var fetchPersonsResult: Result<[Person], Error> = .success([])
    var fetchPersonsCallCount = 0
    var lastFetchPersonsPage: Int?
    var lastFetchPersonsPageSize: Int?

    var savePersonStateResult: Result<Void, Error> = .success(())
    var savePersonStateCallCount = 0
    var lastSavedPersonState: PersonState?

    var getPersonStateResult: Result<PersonState?, Error> = .success(nil)
    var getPersonStateCallCount = 0
    var lastGetPersonStateId: UUID?

    func fetchPersons(page: Int, pageSize: Int) async throws -> [Person] {
        fetchPersonsCallCount += 1
        lastFetchPersonsPage = page
        lastFetchPersonsPageSize = pageSize
        return try fetchPersonsResult.get()
    }

    func savePersonState(_ state: PersonState) async throws {
        savePersonStateCallCount += 1
        lastSavedPersonState = state
        try savePersonStateResult.get()
    }

    func getPersonState(personId: UUID) async throws -> PersonState? {
        getPersonStateCallCount += 1
        lastGetPersonStateId = personId
        return try getPersonStateResult.get()
    }
}
