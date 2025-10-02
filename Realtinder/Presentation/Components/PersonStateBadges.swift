import SwiftUI

struct PersonStateBadges: View {
    let personState: PersonState?

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if personState?.isSeen == true {
                Badge(
                    text: "SEEN",
                    color: .blue
                )
            }
            if let isLiked = personState?.isLiked {
                Badge(
                    text: isLiked ? "LIKED" : "PASSED",
                    color: isLiked ? .green : .red
                )
            }
        }
    }
}

#Preview("Badges - Seen and Liked") {
    PersonStateBadges(
        personState: PersonState(
            personId: .init(),
            isSeen: true,
            isLiked: true
        )
    )
    .padding()
}

#Preview("Badges - Seen and Passed") {
    PersonStateBadges(
        personState: PersonState(
            personId: .init(),
            isSeen: true,
            isLiked: false
        )
    )
    .padding()
}

#Preview("Badges - Only Seen") {
    PersonStateBadges(
        personState: PersonState(
            personId: .init(),
            isSeen: true,
            isLiked: nil
        )
    )
    .padding()
}

#Preview("Badges - No State") {
    PersonStateBadges(personState: nil)
        .padding()
}
