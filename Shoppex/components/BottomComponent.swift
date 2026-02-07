import SwiftUI


struct BottomBar: View {
    var onHome: () -> Void
    var onPlus: () -> Void
    var onTracking: () -> Void
    var currentScreen: AppScreen

    var body: some View {
        HStack {
            PillButton(title: "Home", action: onHome, active: currentScreen == .home)

            Spacer()

            PlusButton(action: onPlus)

            Spacer()

            PillButton(title: "Tracking", action: onTracking, active: currentScreen == .tracking)
        }
    }
}


private struct PillButton: View {
    let title: String
    let action: () -> Void
    let active: Bool

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(active ? Color.blue.opacity(0.65) : Color.white.opacity(0.08))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                )
        }
    }
}


private struct PlusButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("+")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 76, height: 56)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.65))
                )
                .shadow(radius: 16)
        }
    }
}
