import SwiftUI

struct PersonCardView: View {
    let person: Person
    let personState: PersonState?
    let onSwipe: (SwipeDirection) -> Void
    let onTap: () -> Void
    var isTopCard: Bool = true

    @State private var offset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            cardContent(geometry: geometry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func cardContent(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottomLeading) {
                CardImagePlaceholder(url: person.photos.first ?? "")
                PersonInfoOverlay(person: person)
            }
            PersonStateBadges(personState: personState)
                .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .overlay(SwipeIndicators(offset: offset))
        .allowsHitTesting(isTopCard)
        .gesture(dragGesture(geometry: geometry))
        .onTapGesture(perform: handleTap)
    }

    private func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                guard isTopCard else { return }
                offset = gesture.translation
            }
            .onEnded { gesture in
                guard isTopCard else { return }
                handleSwipeEnd(geometry: geometry)
            }
    }

    private func handleSwipeEnd(geometry: GeometryProxy) {
        let swipeThreshold: CGFloat = geometry.size.width * 0.3

        if abs(offset.width) > swipeThreshold {
            let direction: SwipeDirection = offset.width > 0 ? .right : .left
            removeCard(direction: direction)
            onSwipe(direction)
        } else {
            withAnimation(.spring(response: 0.3)) {
                offset = .zero
            }
        }
    }

    private func handleTap() {
        guard isTopCard else { return }
        onTap()
    }

    private func removeCard(direction: SwipeDirection) {
        let swipeDistance: CGFloat = direction == .right ? 500 : -500
        withAnimation(.easeOut(duration: 0.3)) {
            offset = CGSize(width: swipeDistance, height: 0)
        }
    }
}

#Preview("No State") {
    PersonCardView(
        person: Person(
            name: "Emma Wilson",
            age: 26,
            photos: ["person1_1", "person1_2"],
            bio: "Love hiking and coffee ☕️"
        ),
        personState: nil,
        onSwipe: { direction in
            print("Swiped: \(direction)")
        },
        onTap: {
            print("Tapped")
        }
    )
}

#Preview("Seen and Liked") {
    PersonCardView(
        person: Person(
            name: "Sophia Martinez",
            age: 24,
            photos: ["person2_1", "person2_2"],
            bio: "Artist | Traveler 🎨✈️"
        ),
        personState: PersonState(personId: .init(), isSeen: true, isLiked: true),
        onSwipe: { _ in },
        onTap: {}
    )
}

#Preview("Seen and Passed") {
    PersonCardView(
        person: Person(
            name: "Olivia Johnson",
            age: 28,
            photos: ["person3_1"],
            bio: "Fitness enthusiast 💪"
        ),
        personState: PersonState(personId: .init(), isSeen: true, isLiked: false),
        onSwipe: { _ in },
        onTap: {}
    )
}

#Preview("Back Card (Non-interactive)") {
    PersonCardView(
        person: Person(
            name: "Ava Brown",
            age: 25,
            photos: ["person4_1"],
            bio: "Foodie and book lover 📚"
        ),
        personState: nil,
        onSwipe: { _ in },
        onTap: {},
        isTopCard: false
    )
}
