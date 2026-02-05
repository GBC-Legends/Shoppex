import SwiftUI

struct SuppliesScreenView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Supplies Screen")
                NavigationLink("Screen 1") {
                    HomeScreenView()
                }
                NavigationLink("Screen 2") {
                    CategoriesScreenView()
                }
                NavigationLink("Screen 4") {
                    TrackingScreenView()
                }
            }
        }
    }
}
