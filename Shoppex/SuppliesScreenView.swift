import SwiftUI

struct SuppliesScreenView: View {
    @Binding var currentScreen: AppScreen
    @State private var searchText = ""
<<<<<<< HEAD
    
=======

>>>>>>> adef91d (adding categories and goods with folds)
    let supplies = [
        Supply(name: "Green Apples", price: 7.99),
        Supply(name: "Pizza", price: 12.99),
        Supply(name: "Detergent", price: 15.00),
        Supply(name: "Bananas", price: 2.49),
        Supply(name: "Bread", price: 3.49),
        Supply(name: "Milk", price: 4.29),
        Supply(name: "Dish Soap", price: 4.99),
        Supply(name: "Paper Towels", price: 8.99)
    ]

    var filteredSupplies: [Supply] {
        if searchText.isEmpty {
            return supplies
        }
        return supplies.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
        var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
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

<<<<<<< HEAD
=======
                Button(action: {
                }) {
                    Text("Add a new category")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#4A90E2").opacity(0.25))
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "#4A90E2"), lineWidth: 2)
                            )
                    )
                }
                .padding(.top, 6)

>>>>>>> adef91d (adding categories and goods with folds)
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredSupplies) { supply in
                            SupplyItemCard(supply: supply)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                }
<<<<<<< HEAD
                
                Spacer()
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
=======

                Spacer()
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

>>>>>>> adef91d (adding categories and goods with folds)
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

struct Supply: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
}

struct SupplyItemCard: View {
    let supply: Supply
<<<<<<< HEAD
    
    var priceWithTax: Double {
        supply.price * 1.13
    }
    
=======

    var priceWithTax: Double {
        supply.price * 1.13
    }

>>>>>>> adef91d (adding categories and goods with folds)
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(supply.name)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
<<<<<<< HEAD
                
=======

>>>>>>> adef91d (adding categories and goods with folds)
                Text(String(format: "$%.2f ($%.2f with HST)", supply.price, priceWithTax))
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "#4A90E2"))
            }
<<<<<<< HEAD
            
            Spacer()
            
=======

            Spacer()

>>>>>>> adef91d (adding categories and goods with folds)
            Button(action: {
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#0A84FF"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
        )
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> adef91d (adding categories and goods with folds)
