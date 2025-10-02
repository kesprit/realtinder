import SwiftUI

struct PersonInfoOverlay: View {
    let person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(person.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text("\(person.age)")
                    .font(.title2)
            }
            .foregroundColor(.white)

            Text(person.bio)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0), Color.black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    ZStack {
        Color.purple
        PersonInfoOverlay(
            person: Person(
                name: "Emma Wilson",
                age: 26,
                photos: ["person1_1"],
                bio: "Love hiking and coffee ☕️"
            )
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
    .ignoresSafeArea()
}

#Preview("Long Bio") {
    ZStack {
        Color.pink
        PersonInfoOverlay(
            person: Person(
                name: "Sophia",
                age: 24,
                photos: ["person2_1"],
                bio: "Artist, traveler, and food enthusiast. Love exploring new places and meeting new people."
            )
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
    .ignoresSafeArea()
}
