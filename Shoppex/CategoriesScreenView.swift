import SwiftUI


struct CategoriesScreenView: View {
    @Binding var currentScreen: AppScreen
    @State private var searchText = ""
    @State private var categories: [CategoryItem] = [
        CategoryItem(name: "Food"),
        CategoryItem(name: "Medication"),
        CategoryItem(name: "Cleaning"),
        CategoryItem(name: "Personal Hygiene"),
        CategoryItem(name: "Pet Supplies")
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20){
                Spacer().frame(height: 20)

                HStack{
                    TextField("", text: $searchText, prompt: Text("Search Item").foregroundColor(.white.opacity(0.4)))
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
                .padding(.horizontal, 24)

                Text("Categories")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Button(action: {
                }) {
                    Text("Add a new category")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(Color(hex: "#4A90E2"), lineWidth: 2)
                                .background(Capsule().fill(Color(hex: "#4A90E2").opacity(0.2)))
                        )
                }
                .padding(.top, 10)

                VStack(spacing: 0) {
                    ForEach(categories) { category in
                        CategoryRow(category: category)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
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
struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
}

struct CategoryRow: View {
    let category: CategoryItem
    
    var body: some View {
        HStack {
            Text(category.name)
                .font(.system(size: 18))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.3))
                .font(.system(size: 14))
        }
        .padding(.vertical, 16)
        .background(Color.clear)
    }
}
