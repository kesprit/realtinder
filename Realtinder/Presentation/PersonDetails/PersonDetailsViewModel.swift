import Foundation

extension PersonDetailsView {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var person: Person
        private(set) var personState: PersonState?
        private(set) var currentPhotoIndex = 0
        private let dependencies: Dependencies
        
        init(dependencies: Dependencies) {
            self.person = dependencies.person
            self.personState = dependencies.personState
            self.dependencies = dependencies
        }
        
        func toggleLike() async {
            let currentLiked = personState?.isLiked
            let newLiked: Bool? = currentLiked == true ? nil : true
            personState = PersonState(personId: person.id, isSeen: true, isLiked: newLiked)

            do {
                try await dependencies.updatePersonStateUseCase.execute(
                    personId: person.id,
                    isSeen: true,
                    isLiked: newLiked
                )
            } catch {
                print("Failed to toggle like: \(error)")
                personState = PersonState(personId: person.id, isSeen: true, isLiked: currentLiked)
            }
        }

        func navigateToPhoto(at index: Int) {
            guard index >= 0 && index < person.photos.count else { return }
            currentPhotoIndex = index
        }

        func nextPhoto() {
            if currentPhotoIndex < person.photos.count - 1 {
                currentPhotoIndex += 1
            }
        }

        func previousPhoto() {
            if currentPhotoIndex > 0 {
                currentPhotoIndex -= 1
            }
        }
    }
}

extension PersonDetailsView.ViewModel {
    struct Dependencies {
        let person: Person
        let personState: PersonState?
        @Injection var updatePersonStateUseCase: UpdatePersonStateUseCase
    }
}
