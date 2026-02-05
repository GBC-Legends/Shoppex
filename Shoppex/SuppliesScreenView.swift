import SwiftUI

struct SuppliesScreenView: View {
    @Binding var currentScreen: AppScreen

    var body: some View {
        VStack {
            Text("Supplies Screen")
            Button("Home Screen") {
                withAnimation(.easeInOut) {
                    currentScreen = .home
                }
            }
            Button("Categories Screen") {
                withAnimation(.easeInOut) {
                    currentScreen = .categories
                }
            }
            Button("Tracking Screen") {
                withAnimation(.easeInOut) {
                    currentScreen = .tracking
                }
            }
        }
    }
}
