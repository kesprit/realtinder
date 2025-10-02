import SwiftUI

struct CardImagePlaceholder: View {
    let url: String
    
    var body: some View {
        ZStack {
            gradientBackground
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .empty:
                    loadingPlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    fallbackPlaceholder
                }
            }
        }
    }
    
    private var loadingPlaceholder: some View {
        ZStack {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
        }
    }
    
    private var fallbackPlaceholder: some View {
        ZStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var gradientBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.pink.opacity(0.3),
                        Color.purple.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

#Preview("With URL") {
    CardImagePlaceholder(url: "https://picsum.photos/400/600")
        .frame(height: 600)
        .padding()
}

#Preview("Fallback") {
    CardImagePlaceholder(url: "person1_photo")
        .frame(height: 600)
        .padding()
}
