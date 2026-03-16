import SwiftUI

struct TrackingScreenView: View {
    @Binding var currentScreen: AppScreen

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 18) {
                Spacer().frame(height: 40)

                Text("Summary")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    TrackingRow(name: "Apples", price: "$7.99")
                    TrackingRow(name: "Pizza", price: "$12.99")
                    TrackingRow(name: "Detergent", price: "$15.00")
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)

                VStack(spacing: 10) {
                    SummaryRow(title: "Subtotal", value: "$35.98")
                    SummaryRow(title: "Sales Tax", value: "13%        $4.68")
                }
                .padding(.horizontal, 24)

                Spacer()

                HStack {
                    Text("Total")
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundColor(.white)

                    Spacer()

                    Text("$40.66")
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
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

struct TrackingRow: View {
    let name: String
    let price: String

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 18, design: .serif))
                .foregroundColor(.white)

            Spacer()

            Text(price)
                .foregroundColor(.white.opacity(0.8))

            Button {
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

struct SummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            Text(value)
                .foregroundColor(.white.opacity(0.85))
        }
    }
}
