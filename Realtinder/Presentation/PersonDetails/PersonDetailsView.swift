import SwiftUI

struct PersonDetailsView: View {
    @State private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss

    init(person: Person, personState: PersonState?) {
        _viewModel = State(initialValue: .init(dependencies: .init(person: person, personState: personState)))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                photoViewer
                personInfo
            }
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .padding()
        }
    }

    private var photoViewer: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                colors: [Color.pink, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    CardImagePlaceholder(url: viewModel.person.photos[viewModel.currentPhotoIndex])
                    HStack(spacing: 0) {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    viewModel.previousPhoto()
                                }
                            }
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    viewModel.nextPhoto()
                                }
                            }
                    }
                }
            }
            .frame(height: 500)
            photoIndicators
        }
    }

    private var photoIndicators: some View {
        HStack(spacing: 4) {
            ForEach(0..<viewModel.person.photos.count, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.currentPhotoIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }

    private var personInfo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(viewModel.person.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(viewModel.person.age)")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        HStack(spacing: 8) {
                            if viewModel.personState?.isSeen == true {
                                Badge(text: "SEEN", color: .blue)
                            }
                            if let isLiked = viewModel.personState?.isLiked {
                                Badge(text: isLiked ? "LIKED" : "PASSED", color: isLiked ? .green : .gray)
                            }
                        }
                    }

                    Spacer()

                    Button(action: viewModel.toggleLike) {
                        Circle()
                            .fill(viewModel.personState?.isLiked == true ? Color.pink : Color.white)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: viewModel.personState?.isLiked == true ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(viewModel.personState?.isLiked == true ? .white : .pink)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.3))
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    Text(viewModel.person.bio)
                        .font(.body)
                        .foregroundColor(.white)
                }
                Divider()
                    .background(Color.white.opacity(0.3))
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(viewModel.person.photos.count) photos")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}

#Preview {
    let person = Person(
        name: "John Doe",
        age: 30,
        photos: [],
        bio: ""
    )
    PersonDetailsView(
        person: person,
        personState: .init(
            personId: person.id,
            isSeen: false,
            isLiked: false,
            timestamp: .now
        )
    )
}
