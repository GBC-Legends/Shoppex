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
                    Text("This month you have spent $\(String(format: "%.2f", shoppingStore.currentMonthTotal()))")
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                        Text("\(shoppingStore.savedShoppings.count) saved receipts this month")
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                SavedShoppingsSection(currentScreen: $currentScreen)
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
    @Binding var currentScreen: AppScreen
    @EnvironmentObject private var shoppingStore: ShoppingStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Receipts")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            if shoppingStore.savedShoppings.isEmpty {
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
                        ForEach(shoppingStore.savedShoppings) { shopping in
                            SavedShoppingCard(
                                shopping: shopping,
                                onDelete: {
                                    shoppingStore.deleteShopping(shopping)
                                },
                                onEdit: {
                                    shoppingStore.editShopping(shopping)
                                    currentScreen = .tracking
                                }
                            )
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
