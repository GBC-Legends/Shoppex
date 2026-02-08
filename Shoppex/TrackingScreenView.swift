import SwiftUI

struct TrackingScreenView: View {
    @Binding var currentScreen: AppScreen

    var body: some View {
        VStack {
            Text("Tracking Screen")
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
            Button("Supplies Screen") {
                withAnimation(.easeInOut) {
                    currentScreen = .supplies
                }
            }
        }
    }
}
