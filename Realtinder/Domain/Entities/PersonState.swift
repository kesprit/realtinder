import Foundation

struct PersonState: Codable, Hashable {
    let personId: UUID
    var isSeen: Bool
    var isLiked: Bool?
    var timestamp: Date

    init(
        personId: UUID,
        isSeen: Bool = false,
        isLiked: Bool? = nil,
        timestamp: Date = Date()
    ) {
        self.personId = personId
        self.isSeen = isSeen
        self.isLiked = isLiked
        self.timestamp = timestamp
    }
}
