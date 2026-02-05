import SwiftUI


struct CategoriesScreenView: View {
    @Binding var currentScreen: AppScreen

    var body: some View {
        VStack {
            Text("Categories Screen")
            Button("Home Screen") {
                withAnimation(.easeInOut) {
                    currentScreen = .home
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
