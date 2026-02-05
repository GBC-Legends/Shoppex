import SwiftUI


struct CategoriesScreenView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Categories Screen")
                NavigationLink("Screen 1") {
                    HomeScreenView()
                }
                NavigationLink("Screen 3") {
                    SuppliesScreenView()
                }
                NavigationLink("Screen 4") {
                    TrackingScreenView()
                }
            }
        }
    }
}
