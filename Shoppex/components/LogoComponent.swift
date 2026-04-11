import SwiftUI

struct LogoComponentView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "#1D1E27")

            Text("Shoppex")
                .font(.custom("AtomicAge", size: 48))
                .foregroundColor(.white)
                .padding(.leading, 8)
                .padding(.top, 2)
        }.frame(height: 60).frame(maxWidth: .infinity).clipped()
    }
}
