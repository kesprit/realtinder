import XCTest
@testable import Realtinder

@MainActor
final class PersonDetailsViewModelTests: XCTestCase {
    var sut: PersonDetailsView.ViewModel!
    var mockUpdatePersonStateUseCase: MockUpdatePersonStateUseCaseForDetails!
    var mockPerson: Person!

    override func setUp() {
        super.setUp()
        mockUpdatePersonStateUseCase = MockUpdatePersonStateUseCaseForDetails()
        mockPerson = Person(id: UUID(), name: "John", age: 25, photos: ["photo1.jpg", "photo2.jpg", "photo3.jpg"], bio: "Test bio")

        DIContainer.shared.register(type: UpdatePersonStateUseCase.self, component: mockUpdatePersonStateUseCase)
    }

    override func tearDown() {
        sut = nil
        mockUpdatePersonStateUseCase = nil
        mockPerson = nil
        DIContainer.shared.removeAll()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_WithPerson_SetsPerson() {
        // Given
        let person = mockPerson!
        let state = PersonState(personId: person.id, isSeen: true, isLiked: true)

        // When
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: person, personState: state))

        // Then
        XCTAssertEqual(sut.person.id, person.id)
        XCTAssertEqual(sut.person.name, "John")
        XCTAssertEqual(sut.personState?.isLiked, true)
    }

    func testInit_WithNilState_SetsNilState() {
        // Given
        let person = mockPerson!

        // When
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: person, personState: nil))

        // Then
        XCTAssertNil(sut.personState)
    }

    // MARK: - toggleLike Tests

    func testToggleLike_NotLiked_SetsToLiked() async {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        await sut.toggleLike()

        // Then
        XCTAssertEqual(sut.personState?.isLiked, true)
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecutePersonId, mockPerson.id)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsSeen, true)
        XCTAssertEqual(mockUpdatePersonStateUseCase.lastExecuteIsLiked, true)
    }

    func testToggleLike_Liked_SetsToNil() async {
        // Given
        let state = PersonState(personId: mockPerson.id, isSeen: true, isLiked: true)
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: state))

        // When
        await sut.toggleLike()

        // Then
        XCTAssertNil(sut.personState?.isLiked)
        XCTAssertEqual(mockUpdatePersonStateUseCase.executeCallCount, 1)
        XCTAssertNil(mockUpdatePersonStateUseCase.lastExecuteIsLiked)
    }

    func testToggleLike_Failure_RevertsState() async {
        // Given
        let state = PersonState(personId: mockPerson.id, isSeen: true, isLiked: nil)
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: state))
        mockUpdatePersonStateUseCase.executeResult = .failure(NSError(domain: "Test", code: 500))

        // When
        await sut.toggleLike()

        // Then - State should be reverted to original
        XCTAssertNil(sut.personState?.isLiked)
    }

    func testToggleLike_FromNilToLikedAndBack() async {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When - First toggle
        await sut.toggleLike()

        // Then
        XCTAssertEqual(sut.personState?.isLiked, true)

        // When - Second toggle
        await sut.toggleLike()

        // Then
        XCTAssertNil(sut.personState?.isLiked)
    }

    // MARK: - navigateToPhoto Tests

    func testNavigateToPhoto_ValidIndex_SetsCurrentPhotoIndex() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.navigateToPhoto(at: 1)

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 1)
    }

    func testNavigateToPhoto_InvalidNegativeIndex_DoesNotChange() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.navigateToPhoto(at: -1)

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 0)
    }

    func testNavigateToPhoto_IndexOutOfBounds_DoesNotChange() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.navigateToPhoto(at: 10)

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 0)
    }

    func testNavigateToPhoto_LastValidIndex_SetsCorrectly() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.navigateToPhoto(at: 2) // Last photo

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 2)
    }

    // MARK: - nextPhoto Tests

    func testNextPhoto_NotAtEnd_IncrementsIndex() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.nextPhoto()

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 1)
    }

    func testNextPhoto_AtEnd_DoesNotIncrement() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))
        sut.navigateToPhoto(at: 2) // Last photo

        // When
        sut.nextPhoto()

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 2)
    }

    func testNextPhoto_MultipleIncrements() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.nextPhoto()
        sut.nextPhoto()

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 2)
    }

    // MARK: - previousPhoto Tests

    func testPreviousPhoto_NotAtStart_DecrementsIndex() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))
        sut.navigateToPhoto(at: 1)

        // When
        sut.previousPhoto()

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 0)
    }

    func testPreviousPhoto_AtStart_DoesNotDecrement() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.previousPhoto()

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 0)
    }

    func testPreviousPhoto_FromEndToStart() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))
        sut.navigateToPhoto(at: 2)

        // When
        sut.previousPhoto()
        sut.previousPhoto()

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 0)
    }

    // MARK: - Photo Navigation Integration Tests

    func testPhotoNavigation_NextThenPrevious() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.nextPhoto()
        sut.nextPhoto()
        sut.previousPhoto()

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 1)
    }

    func testPhotoNavigation_NavigateToThenNext() {
        // Given
        sut = PersonDetailsView.ViewModel(dependencies: .init(person: mockPerson, personState: nil))

        // When
        sut.navigateToPhoto(at: 1)
        sut.nextPhoto()

        // Then
        XCTAssertEqual(sut.currentPhotoIndex, 2)
    }
}

// MARK: - Mock Use Case

class MockUpdatePersonStateUseCaseForDetails: UpdatePersonStateUseCase {
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
