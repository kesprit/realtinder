import SwiftUI

struct NopeIndicator: View {
    let offset: CGSize

    var body: some View {
        Text("NOPE")
            .font(
                .system(
                    size: 40,
                    weight: .bold
                )
            )
            .foregroundColor(.red)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 5)
            )
            .rotationEffect(.degrees(20))
            .opacity(offset.width < -50 ? min(Double(-offset.width / 100), 1.0) : 0)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topTrailing
            )
            .padding(40)
    }
}

#Preview("Nope Indicator") {
    NopeIndicator(offset: CGSize(width: -100, height: 0))
}
