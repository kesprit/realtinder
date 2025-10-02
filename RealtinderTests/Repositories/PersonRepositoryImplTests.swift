import XCTest
@testable import Realtinder

final class PersonRepositoryImplTests: XCTestCase {
    var sut: PersonRepositoryImpl!
    var mockRemoteDataSource: MockRemotePersonDataSource!
    var mockLocalDataSource: MockLocalPersonStateDataSource!

    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockRemotePersonDataSource()
        mockLocalDataSource = MockLocalPersonStateDataSource()
        DIContainer.shared.register(type: RemotePersonDataSource.self, component: mockRemoteDataSource)
        DIContainer.shared.register(type: LocalPersonStateDataSource.self, component: mockLocalDataSource)
        sut = PersonRepositoryImpl()
    }

    override func tearDown() {
        sut = nil
        mockRemoteDataSource = nil
        mockLocalDataSource = nil
        DIContainer.shared.removeAll()
        super.tearDown()
    }

    // MARK: - fetchPersons Tests

    func testFetchPersons_Success_ReturnsPersons() async throws {
        // Given
        let expectedPersons = [
            Person(id: UUID(), name: "John", age: 25, photos: [], bio: "Test bio"),
            Person(id: UUID(), name: "Jane", age: 28, photos: [], bio: "Another bio")
        ]
        mockRemoteDataSource.fetchPersonsResult = .success(expectedPersons)

        // When
        let result = try await sut.fetchPersons(page: 0, pageSize: 10)

        // Then
        XCTAssertEqual(result.count, expectedPersons.count)
        XCTAssertEqual(mockRemoteDataSource.fetchPersonsCallCount, 1)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPersonsPage, 0)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPersonsPageSize, 10)
    }

    func testFetchPersons_Failure_ThrowsError() async throws {
        // Given
        let expectedError = NSError(domain: "TestError", code: 500)
        mockRemoteDataSource.fetchPersonsResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.fetchPersons(page: 0, pageSize: 10)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual((error as NSError).code, 500)
        }
    }

    func testFetchPersons_WithDifferentPagination() async throws {
        // Given
        mockRemoteDataSource.fetchPersonsResult = .success([])

        // When
        _ = try await sut.fetchPersons(page: 2, pageSize: 20)

        // Then
        XCTAssertEqual(mockRemoteDataSource.lastFetchPersonsPage, 2)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPersonsPageSize, 20)
    }

    // MARK: - getPersonState Tests

    func testGetPersonState_StateExists_ReturnsState() async throws {
        // Given
        let personId = UUID()
        let expectedState = PersonState(personId: personId, isSeen: true, isLiked: true)
        mockLocalDataSource.getStateResult = .success(expectedState)

        // When
        let result = try await sut.getPersonState(personId: personId)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.personId, personId)
        XCTAssertEqual(result?.isSeen, true)
        XCTAssertEqual(result?.isLiked, true)
        XCTAssertEqual(mockLocalDataSource.getStateCallCount, 1)
        XCTAssertEqual(mockLocalDataSource.lastGetStatePersonId, personId)
    }

    func testGetPersonState_StateDoesNotExist_ReturnsNil() async throws {
        // Given
        let personId = UUID()
        mockLocalDataSource.getStateResult = .success(nil)

        // When
        let result = try await sut.getPersonState(personId: personId)

        // Then
        XCTAssertNil(result)
        XCTAssertEqual(mockLocalDataSource.getStateCallCount, 1)
    }

    func testGetPersonState_Failure_ThrowsError() async throws {
        // Given
        let personId = UUID()
        let expectedError = NSError(domain: "TestError", code: 404)
        mockLocalDataSource.getStateResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.getPersonState(personId: personId)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual((error as NSError).code, 404)
        }
    }

    // MARK: - savePersonState Tests

    func testSavePersonState_Success_SavesState() async throws {
        // Given
        let personId = UUID()
        let state = PersonState(personId: personId, isSeen: true, isLiked: true)
        mockLocalDataSource.saveStateResult = .success(())

        // When
        try await sut.savePersonState(state)

        // Then
        XCTAssertEqual(mockLocalDataSource.saveStateCallCount, 1)
        XCTAssertEqual(mockLocalDataSource.lastSavedState?.personId, personId)
        XCTAssertEqual(mockLocalDataSource.lastSavedState?.isSeen, true)
        XCTAssertEqual(mockLocalDataSource.lastSavedState?.isLiked, true)
    }

    func testSavePersonState_WithNilLiked_SavesCorrectly() async throws {
        // Given
        let personId = UUID()
        let state = PersonState(personId: personId, isSeen: true, isLiked: nil)
        mockLocalDataSource.saveStateResult = .success(())

        // When
        try await sut.savePersonState(state)

        // Then
        XCTAssertEqual(mockLocalDataSource.lastSavedState?.isSeen, true)
        XCTAssertNil(mockLocalDataSource.lastSavedState?.isLiked)
    }

    func testSavePersonState_Failure_ThrowsError() async throws {
        // Given
        let state = PersonState(personId: UUID(), isSeen: true, isLiked: true)
        let expectedError = NSError(domain: "TestError", code: 500)
        mockLocalDataSource.saveStateResult = .failure(expectedError)

        // When/Then
        do {
            try await sut.savePersonState(state)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual((error as NSError).code, 500)
        }
    }

    // MARK: - getAllPersonStates Tests

    func testGetAllPersonStates_Success_ReturnsAllStates() async throws {
        // Given
        let states = [
            PersonState(personId: UUID(), isSeen: true, isLiked: true),
            PersonState(personId: UUID(), isSeen: true, isLiked: false),
            PersonState(personId: UUID(), isSeen: true, isLiked: nil)
        ]
        mockLocalDataSource.getAllStatesResult = .success(states)

        // When
        let result = try await sut.getAllPersonStates()

        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(mockLocalDataSource.getAllStatesCallCount, 1)
    }

    func testGetAllPersonStates_EmptyResult_ReturnsEmptyArray() async throws {
        // Given
        mockLocalDataSource.getAllStatesResult = .success([])

        // When
        let result = try await sut.getAllPersonStates()

        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(mockLocalDataSource.getAllStatesCallCount, 1)
    }

    func testGetAllPersonStates_Failure_ThrowsError() async throws {
        // Given
        let expectedError = NSError(domain: "TestError", code: 500)
        mockLocalDataSource.getAllStatesResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.getAllPersonStates()
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual((error as NSError).code, 500)
        }
    }
}

// MARK: - Mock Data Sources

class MockRemotePersonDataSource: RemotePersonDataSource {
    var fetchPersonsResult: Result<[Person], Error> = .success([])
    var fetchPersonsCallCount = 0
    var lastFetchPersonsPage: Int?
    var lastFetchPersonsPageSize: Int?

    func fetchPersons(page: Int, pageSize: Int) async throws -> [Person] {
        fetchPersonsCallCount += 1
        lastFetchPersonsPage = page
        lastFetchPersonsPageSize = pageSize
        return try fetchPersonsResult.get()
    }
}

class MockLocalPersonStateDataSource: LocalPersonStateDataSource {
    var getStateResult: Result<PersonState?, Error> = .success(nil)
    var getStateCallCount = 0
    var lastGetStatePersonId: UUID?

    var saveStateResult: Result<Void, Error> = .success(())
    var saveStateCallCount = 0
    var lastSavedState: PersonState?

    var getAllStatesResult: Result<[PersonState], Error> = .success([])
    var getAllStatesCallCount = 0

    func getState(personId: UUID) async throws -> PersonState? {
        getStateCallCount += 1
        lastGetStatePersonId = personId
        return try getStateResult.get()
    }

    func saveState(_ state: PersonState) async throws {
        saveStateCallCount += 1
        lastSavedState = state
        try saveStateResult.get()
    }

    func getAllStates() async throws -> [PersonState] {
        getAllStatesCallCount += 1
        return try getAllStatesResult.get()
    }
}
