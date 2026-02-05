import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Home Screen")
                NavigationLink("Screen 2") {
                    CategoriesScreenView()
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
