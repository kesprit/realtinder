import Foundation

struct Person: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let age: Int
    let photos: [String]
    let bio: String

    init(
        id: UUID = .init(),
        name: String,
        age: Int,
        photos: [String],
        bio: String
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.photos = photos
        self.bio = bio
    }
}
