import Foundation

protocol RemotePersonDataSource {
    func fetchPersons(page: Int, pageSize: Int) async throws -> [Person]
}

final class MockRemotePersonDataSource: RemotePersonDataSource {
    private let mockPersons: [Person] = [
        Person(
            name: "Emma Wilson",
            age: 26,
            photos: [
                "https://picsum.photos/seed/emma1/400/600",
                "https://picsum.photos/seed/emma2/400/600",
                "https://picsum.photos/seed/emma3/400/600"
            ],
            bio: "Love hiking and coffee ☕️"
        ),
        Person(
            name: "Sophia Martinez",
            age: 24,
            photos: [
                "https://picsum.photos/seed/sophia1/400/600",
                "https://picsum.photos/seed/sophia2/400/600",
                "https://picsum.photos/seed/sophia3/400/600"
            ],
            bio: "Artist | Traveler 🎨✈️"
        ),
        Person(
            name: "Olivia Johnson",
            age: 28,
            photos: [
                "https://picsum.photos/seed/olivia1/400/600",
                "https://picsum.photos/seed/olivia2/400/600",
                "https://picsum.photos/seed/olivia3/400/600"
            ],
            bio: "Fitness enthusiast 💪"
        ),
        Person(
            name: "Ava Brown",
            age: 25,
            photos: [
                "https://picsum.photos/seed/ava1/400/600",
                "https://picsum.photos/seed/ava2/400/600",
                "https://picsum.photos/seed/ava3/400/600"
            ],
            bio: "Foodie and book lover 📚"
        ),
        Person(
            name: "Isabella Davis",
            age: 27,
            photos: [
                "https://picsum.photos/seed/isabella1/400/600",
                "https://picsum.photos/seed/isabella2/400/600",
                "https://picsum.photos/seed/isabella3/400/600"
            ],
            bio: "Yoga teacher 🧘‍♀️"
        ),
        Person(
            name: "Mia Garcia",
            age: 23,
            photos: [
                "https://picsum.photos/seed/mia1/400/600",
                "https://picsum.photos/seed/mia2/400/600",
                "https://picsum.photos/seed/mia3/400/600"
            ],
            bio: "Music & adventure 🎵"
        ),
        Person(
            name: "Charlotte Rodriguez",
            age: 29,
            photos: [
                "https://picsum.photos/seed/charlotte1/400/600",
                "https://picsum.photos/seed/charlotte2/400/600",
                "https://picsum.photos/seed/charlotte3/400/600"
            ],
            bio: "Software engineer 💻"
        ),
        Person(
            name: "Amelia Wilson",
            age: 26,
            photos: [
                "https://picsum.photos/seed/amelia1/400/600",
                "https://picsum.photos/seed/amelia2/400/600",
                "https://picsum.photos/seed/amelia3/400/600"
            ],
            bio: "Dog lover 🐶"
        )
    ]

    func fetchPersons(page: Int, pageSize: Int) async throws -> [Person] {
        try await Task.sleep(for: .seconds(5))
        let startIndex = page * pageSize
        var persons: [Person] = []

        for i in 0..<pageSize {
            let mockIndex = (startIndex + i) % mockPersons.count
            let mockPerson = mockPersons[mockIndex]
            let person = Person(
                id: mockPerson.id,
                name: mockPerson.name,
                age: mockPerson.age,
                photos: mockPerson.photos,
                bio: mockPerson.bio
            )
            persons.append(person)
        }

        return persons
    }
}
