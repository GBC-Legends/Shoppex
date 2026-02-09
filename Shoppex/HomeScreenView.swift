import SwiftUI

struct HomeScreenView: View {
    @Binding var currentScreen: AppScreen

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                CircleWidget()

                VStack(alignment: .leading, spacing: 18) {
                    Text("This month you have\nspent 25% of your budget")
                        .font(.system(size: 34, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .lineSpacing(6)

                    Text("That’s 5% less than this time last month.\nKeep it up!")
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                Spacer()

                Text("click + to start adding supplies")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomBar(
                onHome: { withAnimation(.easeInOut) { currentScreen = .home } },
                onPlus: { withAnimation(.easeInOut) { currentScreen = .supplies } },
                onTracking: { withAnimation(.easeInOut) { currentScreen = .tracking } },
                currentScreen: currentScreen
            )
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
        }
        .foregroundColor(.white)
    }
}


private struct CircleWidget: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 170, height: 170)
                .shadow(radius: 8, y: 6)

            Image("homepage_pie")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
        }
    }
}
