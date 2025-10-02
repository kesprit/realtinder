import SwiftUI

struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .bold()
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(.capsule)
    }
}

#Preview {
    Badge(text: "Badge", color: .blue)
}
