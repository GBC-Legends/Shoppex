import SwiftUI

struct HomeScreenView: View {
    @Binding var currentScreen: AppScreen

    var body: some View {
        VStack {
            Text("Home Screen")
            Button("Categories Screen") {
                withAnimation(.easeInOut) {
                    currentScreen = .categories
                }
            }
            Button("Supplies Screen") {
                withAnimation(.easeInOut) {
                    currentScreen = .supplies
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
