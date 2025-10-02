import SwiftUI

struct LikeIndicator: View {
    let offset: CGSize

    var body: some View {
        Text("LIKE")
            .font(
                .system(
                    size: 40,
                    weight: .bold
                )
            )
            .foregroundColor(.green)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color.green,
                        lineWidth: 5
                    )
            )
            .rotationEffect(.degrees(-20))
            .opacity(offset.width > 50 ? min(Double(offset.width / 100), 1.0) : 0)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(40)
    }
}

#Preview("Like Indicator") {
    LikeIndicator(offset: CGSize(width: 100, height: 0))
}
