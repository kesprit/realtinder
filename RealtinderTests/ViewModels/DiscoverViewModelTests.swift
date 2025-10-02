import XCTest
@testable import Realtinder

@MainActor
final class DiscoverViewModelTests: XCTestCase {
    var sut: DiscoverView.ViewModel!
    var mockFetchPersonsUseCase: MockFetchPersonsUseCase!
    var mockUpdatePersonStateUseCase: MockUpdatePersonStateUseCase!
    var mockGetPersonStateUseCase: MockGetPersonStateUseCase!

    override func setUp() {
        super.setUp()
        mockFetchPersonsUseCase = MockFetchPersonsUseCase()
        mockUpdatePersonStateUseCase = MockUpdatePersonStateUseCase()
        mockGetPersonStateUseCase = MockGetPersonStateUseCase()

        DIContainer.shared.register(type: FetchPersonsUseCase.self, component: mockFetchPersonsUseCase)
        DIContainer.shared.register(type: UpdatePersonStateUseCase.self, component: mockUpdatePersonStateUseCase)
        DIContainer.shared.register(type: GetPersonStateUseCase.self, component: mockGetPersonStateUseCase)

        sut = DiscoverView.ViewModel(dependencies: .init())
    }

    override func tearDown() {
        sut = nil
        mockFetchPersonsUseCase = nil
        mockUpdatePersonStateUseCase = nil
        mockGetPersonStateUseCase = nil
        DIContainer.shared.removeAll()
        super.tearDown()
    }

    // MARK: - loadInitialPersons Tests

    func testLoadInitialPersons_Success_LoadsPersons() async {
        // Given
        let expectedPersons = createMockPersons(count: 10)
        mockFetchPersonsUseCase.executeResult = .success(expectedPersons)

        // When
        await sut.loadInitialPersons()

        // Then
        XCTAssertEqual(sut.persons.count, 10)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockFetchPersonsUseCase.executeCallCount, 1)
        XCTAssertEqual(mockFetchPersonsUseCase.lastExecutePage, 0)
        XCTAssertEqual(mockFetchPersonsUseCase.lastExecutePageSize, 10)
    }

    func testLoadInitialPersons_LoadsPersonStates() async {
        // Given
        let persons = createMockPersons(count: 2)
        let state = PersonState(personId: persons[0].id, isSeen: true, isLiked: true)
        mockFetchPersonsUseCase.executeResult = .success(persons)
        mockGetPersonStateUseCase.executeResult = .success(state)

        // When
        await sut.loadInitialPersons()

        // Then
        XCTAssertEqual(sut.personStates.count, 2)
        XCTAssertEqual(mockGetPersonStateUseCase.executeCallCount, 2)
    }

    func testLoadInitialPersons_Failure_HandlesError() async {
        // Given
        mockFetchPersonsUseCase.executeResult = .failure(NSError(domain: "Test", code: 500))

        // When
        await sut.loadInitialPersons()

        // Then
        XCTAssertTrue(sut.persons.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - removeTopCard Tests

    func testRemoveTopCard_RemovesFirstPerson() async {
        // Given
        let persons = createMockPersons(count: 10)
        mockFetchPersonsUseCase.executeResult = .success(persons)
        await sut.loadInitialPersons()
        let firstPersonId = sut.persons.first?.id

        // When
        await sut.removeTopCard()

        // Then
        XCTAssertEqual(sut.persons.count, 9)
        XCTAssertNotEqual(sut.persons.first?.id, firstPersonId)
    }

    func testRemoveTopCard_WhenFewCardsLeft_LoadsMore() async {
        // Given
        let initialPersons = createMockPersons(count: 6)
        let morePersons = createMockPersons(count: 10)
        mockFetchPersonsUseCase.executeResult = .success(initialPersons)
        await sut.loadInitialPersons()

        mockFetchPersonsUseCase.executeResult = .success(morePersons)

        // When
        await sut.removeTopCard()

        // Then - Should load more when down to 5 cards
        XCTAssertEqual(sut.persons.count, 15) // 5 remaining + 10 new
        XCTAssertEqual(mockFetchPersonsUseCase.executeCallCount, 2)
    }

    func testRemoveTopCard_EmptyList_DoesNothing() async {
        // When
        await sut.removeTopCard()

        // Then
        XCTAssertTrue(sut.persons.isEmpty)
    }

    // MARK: - handleSwipe Tests

    func testHandleSwipe_Right_LikesPerson() async {
        // Given
        let persons = createMockPersons(count: 10)
        mockFetchPersonsUseCase.executeResult = .success(persons)
        await sut.loadInitialPersons()
        let person = sut.persons.first!

        // When
        await sut.handleSwipe(person: person, direction: .right)

        // Then - handleSwipe calls markAsSeen and likePerson, so executeCount is 2
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 2)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsLiked, true)
        XCTAssertEqual(sut.persons.count, 9)
    }

    func testHandleSwipe_Left_DislikesPerson() async {
        // Given
        let persons = createMockPersons(count: 10)
        mockFetchPersonsUseCase.executeResult = .success(persons)
        await sut.loadInitialPersons()
        let person = sut.persons.first!

        // When
        await sut.handleSwipe(person: person, direction: .left)

        // Then - handleSwipe calls markAsSeen and dislikePerson, so executeCount is 2
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 2)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsLiked, false)
        XCTAssertEqual(sut.persons.count, 9)
    }

    // MARK: - likePerson Tests

    func testLikePerson_Success_UpdatesState() async {
        // Given
        let person = createMockPersons(count: 1)[0]

        // When
        await sut.likePerson(person: person)

        // Then
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecutePersonId, person.id)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsSeen, true)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsLiked, true)
        XCTAssertEqual(sut.personStates[person.id]?.isLiked, true)
    }

    func testLikePerson_Failure_HandlesError() async {
        // Given
        let person = createMockPersons(count: 1)[0]
        mockUpdatePersonStateUseCase.executeResult = .failure(NSError(domain: "Test", code: 500))

        // When
        await sut.likePerson(person: person)

        // Then
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 1)
    }

    // MARK: - dislikePerson Tests

    func testDislikePerson_Success_UpdatesState() async {
        // Given
        let person = createMockPersons(count: 1)[0]

        // When
        await sut.dislikePerson(person: person)

        // Then
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecutePersonId, person.id)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsSeen, true)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsLiked, false)
        XCTAssertEqual(sut.personStates[person.id]?.isLiked, false)
    }

    // MARK: - markAsSeen Tests

    func testMarkAsSeen_NotSeenBefore_UpdatesState() async {
        // Given
        let person = createMockPersons(count: 1)[0]

        // When
        await sut.markAsSeen(person: person)

        // Then
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsSeen, true)
        XCTAssertEqual(sut.personStates[person.id]?.isSeen, true)
    }

    func testMarkAsSeen_AlreadySeen_DoesNotUpdate() async {
        // Given
        let person = createMockPersons(count: 1)[0]
        // Mark as seen first
        await sut.markAsSeen(person: person)
        mockUpdatePersonStateUseCase.executeCallCount = 0 // Reset counter

        // When
        await sut.markAsSeen(person: person)

        // Then
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 0)
    }

    // MARK: - toggleLike Tests

    func testToggleLike_NotLiked_SetsToLiked() async {
        // Given
        let person = createMockPersons(count: 1)[0]

        // When
        await sut.toggleLike(person: person)

        // Then
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsLiked, true)
        XCTAssertEqual(sut.personStates[person.id]?.isLiked, true)
    }

    func testToggleLike_Liked_SetsToNil() async {
        // Given
        let person = createMockPersons(count: 1)[0]
        // Like the person first
        await sut.toggleLike(person: person)
        XCTAssertEqual(sut.personStates[person.id]?.isLiked, true)

        // When - Toggle again
        await sut.toggleLike(person: person)

        // Then
        XCTAssertNil(mockUpdatePersonStateUseCase.lastExecuteIsLiked)
        XCTAssertNil(sut.personStates[person.id]?.isLiked)
    }

    // MARK: - refreshPersonState Tests

    func testRefreshPersonState_Success_UpdatesState() async {
        // Given
        let personId = UUID()
        let state = PersonState(personId: personId, isSeen: true, isLiked: true)
        mockGetPersonStateUseCase.executeResult = .success(state)

        // When
        await sut.refreshPersonState(personId: personId)

        // Then
        XCTAssertEqual(mockGetPersonStateUseCase.executeCallCount, 1)
        XCTAssertEqual(sut.personStates[personId]?.isLiked, true)
    }

    func testRefreshPersonState_NoState_DoesNotUpdate() async {
        // Given
        let personId = UUID()
        mockGetPersonStateUseCase.executeResult = .success(nil)

        // When
        await sut.refreshPersonState(personId: personId)

        // Then
        XCTAssertNil(sut.personStates[personId])
    }

    // MARK: - Helper Methods

    private func createMockPersons(count: Int) -> [Person] {
        (0..<count).map { _ in
            Person(id: UUID(), name: "Test", age: 25, photos: [], bio: "Test bio")
        }
    }
}

// MARK: - Mock Use Cases

class MockFetchPersonsUseCase: FetchPersonsUseCase {
    var executeResult: Result<[Person], Error> = .success([])
    var executeCallCount = 0
    var lastExecutePage: Int?
    var lastExecutePageSize: Int?

    func execute(page: Int, pageSize: Int) async throws -> [Person] {
        executeCallCount += 1
        lastExecutePage = page
        lastExecutePageSize = pageSize
        return try executeResult.get()
    }
}

class MockUpdatePersonStateUseCase: UpdatePersonStateUseCase {
    var executeResult: Result<Void, Error> = .success(())
    var executeCallCount = 0
    var lastExecutePersonId: UUID?
    var lastExecuteIsSeen: Bool?
    var lastExecuteIsLiked: Bool?

    func execute(personId: UUID, isSeen: Bool, isLiked: Bool?) async throws {
        executeCallCount += 1
        lastExecutePersonId = personId
        lastExecuteIsSeen = isSeen
        lastExecuteIsLiked = isLiked
        try executeResult.get()
    }
}

class MockGetPersonStateUseCase: GetPersonStateUseCase {
    var executeResult: Result<PersonState?, Error> = .success(nil)
    var executeCallCount = 0
    var lastExecutePersonId: UUID?

    func execute(personId: UUID) async throws -> PersonState? {
        executeCallCount += 1
        lastExecutePersonId = personId
        return try executeResult.get()
    }
}
