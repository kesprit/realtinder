import SwiftUI

struct SwipeIndicators: View {
    let offset: CGSize

    var body: some View {
        ZStack {
            LikeIndicator(offset: offset)
            NopeIndicator(offset: offset)
        }
    }
}

#Preview("Indicators - Neutral") {
    SwipeIndicators(offset: .zero)
}

#Preview("Indicators - Swiping Right") {
    SwipeIndicators(offset: CGSize(width: 80, height: 0))
}

#Preview("Indicators - Swiping Left") {
    SwipeIndicators(offset: CGSize(width: -80, height: 0))
}
