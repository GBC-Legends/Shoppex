import SwiftUI

struct TrackingScreenView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Tracking Screen")
                NavigationLink("Screen 1") {
                    HomeScreenView()
                }
                NavigationLink("Screen 2") {
                    CategoriesScreenView()
                }
                NavigationLink("Screen 3") {
                    SuppliesScreenView()
                }
            }
        }
    }
}
