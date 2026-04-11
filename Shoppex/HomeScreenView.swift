import SwiftUI

struct HomeScreenView: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject private var shoppingStore: ShoppingStore

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

                SavedShoppingsSection(shoppings: shoppingStore.savedShoppings)
                    .padding(.horizontal, 24)

                Text("click + to start tracking products")
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

private struct SavedShoppingsSection: View {
    let shoppings: [TrackedShopping]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Shoppings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            if shoppings.isEmpty {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 110)
                    .overlay(
                        Text("Saved purchases will appear here")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    )
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 12) {
                        ForEach(shoppings) { shopping in
                            SavedShoppingCard(shopping: shopping)
                        }
                    }
                    .padding(.trailing, 6)
                }
                .frame(height: 220)
                .clipped()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
