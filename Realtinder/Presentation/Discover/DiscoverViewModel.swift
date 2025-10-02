import Foundation

extension DiscoverView {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var persons: [Person] = []
        private(set) var personStates: [UUID: PersonState] = [:]
        private(set) var isLoading = false
        private var currentPage = 0
        private let pageSize = 10
        var selectedPerson: Person?
        private let dependencies: Dependencies
        
        init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }
        
        func loadInitialPersons() async {
            await loadPersons()
        }
        
        func removeTopCard() async {
            guard !persons.isEmpty else { return }
            persons.removeFirst()

            if persons.count <= 5 && !isLoading {
                await loadPersons()
            }
        }
        
        private func loadPersons() async {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let newPersons = try await dependencies.fetchPersonsUseCase.execute(page: currentPage, pageSize: pageSize)
                persons.append(contentsOf: newPersons)
                currentPage += 1
                
                // Load states for new persons
                for person in newPersons {
                    if let state = try await dependencies.getPersonStateUseCase.execute(personId: person.id) {
                        personStates[person.id] = state
                    }
                }
            } catch {
                print("Failed to load persons: \(error)")
            }
        }
        
        func handleSwipe(person: Person, direction: SwipeDirection) async {
            await markAsSeen(person: person)
            
            switch direction {
            case .left:
                await dislikePerson(person: person)
            case .right:
                await likePerson(person: person)
            }
            
            // Remove the card after swipe
            await removeTopCard()
        }
        
        func likePerson(person: Person) async {
            do {
                try await dependencies.updatePersonStateUseCase.execute(personId: person.id, isSeen: true, isLiked: true)
                personStates[person.id] = PersonState(personId: person.id, isSeen: true, isLiked: true)
            } catch {
                print("Failed to like person: \(error)")
            }
        }
        
        func dislikePerson(person: Person) async {
            do {
                try await dependencies.updatePersonStateUseCase.execute(personId: person.id, isSeen: true, isLiked: false)
                personStates[person.id] = PersonState(personId: person.id, isSeen: true, isLiked: false)
            } catch {
                print("Failed to dislike person: \(error)")
            }
        }
        
        func markAsSeen(person: Person) async {
            guard personStates[person.id]?.isSeen != true else { return }
            
            do {
                let currentState = personStates[person.id]
                try await dependencies.updatePersonStateUseCase.execute(
                    personId: person.id,
                    isSeen: true,
                    isLiked: currentState?.isLiked
                )
                personStates[person.id] = PersonState(
                    personId: person.id,
                    isSeen: true,
                    isLiked: currentState?.isLiked
                )
            } catch {
                print("Failed to mark as seen: \(error)")
            }
        }
        
        func toggleLike(person: Person) async {
            let currentState = personStates[person.id]
            let newLikedState: Bool? = currentState?.isLiked == true ? nil : true
            
            do {
                try await dependencies.updatePersonStateUseCase.execute(personId: person.id, isSeen: true, isLiked: newLikedState)
                personStates[person.id] = PersonState(personId: person.id, isSeen: true, isLiked: newLikedState)
            } catch {
                print("Failed to toggle like: \(error)")
            }
        }
        
        func refreshPersonState(personId: UUID) async {
            do {
                if let state = try await dependencies.getPersonStateUseCase.execute(personId: personId) {
                    personStates[personId] = state
                }
            } catch {
                print("Failed to refresh person state: \(error)")
            }
        }
    }
}

extension DiscoverView.ViewModel {
    struct Dependencies {
        @Injection var fetchPersonsUseCase: FetchPersonsUseCase
        @Injection var updatePersonStateUseCase: UpdatePersonStateUseCase
        @Injection var getPersonStateUseCase: GetPersonStateUseCase
    }
}
