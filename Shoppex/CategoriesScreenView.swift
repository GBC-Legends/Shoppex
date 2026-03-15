import SwiftUI
 
struct ProductDetail: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let unit: String       
    let brand: String
    let notes: String       
 
    var priceWithTax: Double { price * 1.13 }
}
 
struct SupplyItem: Identifiable {
    let id = UUID()
    let name: String
    let products: [ProductDetail]
    var isExpanded: Bool = false
}
 
struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String        
    var items: [SupplyItem]
    var isExpanded: Bool = false
}
 
extension CategoryItem {
    static let sampleData: [CategoryItem] = [
        CategoryItem(name: "Dairy", icon: "drop.fill", items: [
            SupplyItem(name: "Milk", products: [
                ProductDetail(name: "Whole Milk 1L", price: 4.29, unit: "1L", brand: "Natrel", notes: "Refrigerated"),
                ProductDetail(name: "2% Milk 2L", price: 6.49, unit: "2L", brand: "Beatrice", notes: "Refrigerated"),
                ProductDetail(name: "Skim Milk 1L", price: 3.99, unit: "1L", brand: "Lactantia", notes: "Refrigerated")
            ]),
            SupplyItem(name: "Cheese", products: [
                ProductDetail(name: "Cheddar Block 400g", price: 8.99, unit: "400g", brand: "Black Diamond", notes: "Refrigerated"),
                ProductDetail(name: "Mozzarella 200g", price: 5.49, unit: "200g", brand: "Saputo", notes: "Refrigerated")
            ]),
            SupplyItem(name: "Sour Cream", products: [
                ProductDetail(name: "Sour Cream 500mL", price: 3.79, unit: "500mL", brand: "Astro", notes: "Refrigerated")
            ])
        ]),
        CategoryItem(name: "Bakery", icon: "flame.fill", items: [
            SupplyItem(name: "Bread", products: [
                ProductDetail(name: "White Sandwich Bread", price: 3.49, unit: "675g", brand: "Wonder", notes: ""),
                ProductDetail(name: "Whole Wheat Loaf", price: 4.29, unit: "600g", brand: "Dempster's", notes: "High fibre")
            ]),
            SupplyItem(name: "Bagels", products: [
                ProductDetail(name: "Plain Bagels", price: 4.49, unit: "6 pack", brand: "Montreal Style", notes: "")
            ])
        ]),
        CategoryItem(name: "Produce", icon: "leaf.fill", items: [
            SupplyItem(name: "Apples", products: [
                ProductDetail(name: "Green Apples", price: 7.99, unit: "bag 1.5kg", brand: "Local Farm", notes: "Granny Smith"),
                ProductDetail(name: "Gala Apples", price: 6.99, unit: "bag 1.5kg", brand: "Local Farm", notes: "")
            ]),
            SupplyItem(name: "Bananas", products: [
                ProductDetail(name: "Bananas", price: 2.49, unit: "bunch", brand: "Chiquita", notes: "")
            ])
        ]),
        CategoryItem(name: "Cleaning", icon: "sparkles", items: [
            SupplyItem(name: "Detergent", products: [
                ProductDetail(name: "Laundry Pods 42ct", price: 15.00, unit: "42 count", brand: "Tide", notes: ""),
                ProductDetail(name: "Liquid Detergent 1.47L", price: 12.99, unit: "1.47L", brand: "Gain", notes: "Fresh scent")
            ]),
            SupplyItem(name: "Dish Soap", products: [
                ProductDetail(name: "Dish Soap 532mL", price: 4.99, unit: "532mL", brand: "Dawn", notes: "Original")
            ]),
            SupplyItem(name: "Paper Towels", products: [
                ProductDetail(name: "Paper Towels 6-Roll", price: 8.99, unit: "6 rolls", brand: "Bounty", notes: "Select-A-Size")
            ])
        ]),
        CategoryItem(name: "Medication", icon: "cross.fill", items: [
            SupplyItem(name: "Pain Relief", products: [
                ProductDetail(name: "Ibuprofen 200mg 100ct", price: 11.99, unit: "100 tablets", brand: "Advil", notes: "Take with food"),
                ProductDetail(name: "Acetaminophen 500mg", price: 9.49, unit: "100 tablets", brand: "Tylenol", notes: "")
            ])
        ])
    ]
}

struct CategoriesScreenView: View {
    @Binding var currentScreen: AppScreen
    @State private var searchText = ""
    @State private var categories: [CategoryItem] = CategoryItem.sampleData
 
    var filteredCategories: [CategoryItem] {
        guard !searchText.isEmpty else { return categories }
        return categories.compactMap { category in
            let matchingItems = category.items.compactMap { item -> SupplyItem? in
                if item.name.lowercased().contains(searchText.lowercased()) { return item }
                let matchingProducts = item.products.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
                if !matchingProducts.isEmpty {
                    var copy = item
                    return copy
                }
                return nil
            }
            if category.name.lowercased().contains(searchText.lowercased()) { return category }
            if !matchingItems.isEmpty {
                var copy = category
                copy.items = matchingItems
                return copy
            }
            return nil
        }
    }
 
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.4))
                    TextField("", text: $searchText, prompt: Text("Search items...").foregroundColor(.white.opacity(0.4)))
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
 
                Button(action: {}) {
                    Text("Add a new category")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#4A90E2").opacity(0.25))
                                .overlay(Capsule().stroke(Color(hex: "#4A90E2"), lineWidth: 2))
                        )
                }
                .padding(.top, 6)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredCategories.indices, id: \.self) { catIndex in
                            CategoryAccordionRow(
                                category: filteredCategories[catIndex],
                                onToggleCategory: {
                                    toggleCategory(id: filteredCategories[catIndex].id)
                                },
                                onToggleItem: { itemID in
                                    toggleItem(categoryID: filteredCategories[catIndex].id, itemID: itemID)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
 
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
 
    private func toggleCategory(id: UUID) {
        withAnimation(.easeInOut(duration: 0.25)) {
            if let i = categories.firstIndex(where: { $0.id == id }) {
                categories[i].isExpanded.toggle()
            }
        }
    }
 
    private func toggleItem(categoryID: UUID, itemID: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let ci = categories.firstIndex(where: { $0.id == categoryID }),
               let ii = categories[ci].items.firstIndex(where: { $0.id == itemID }) {
                categories[ci].items[ii].isExpanded.toggle()
            }
        }
    }
}
struct CategoryAccordionRow: View {
    let category: CategoryItem
    let onToggleCategory: () -> Void
    let onToggleItem: (UUID) -> Void
 
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggleCategory) {
                HStack(spacing: 14) {
                    Image(systemName: category.icon)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#4A90E2"))
                        .frame(width: 28)
 
                    Text(category.name)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.white)
 
                    Spacer()
 
                    Text("\(category.items.count) items")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
 
                    Image(systemName: category.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .animation(.easeInOut(duration: 0.2), value: category.isExpanded)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: category.isExpanded ? 16 : 16)
                        .fill(Color.white.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            if category.isExpanded {
                VStack(spacing: 0) {
                    ForEach(category.items) { item in
                        ItemAccordionRow(
                            item: item,
                            onToggle: { onToggleItem(item.id) }
                        )
                        .padding(.leading, 16)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 8)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.bottom, 10)
    }
}
struct ItemAccordionRow: View {
    let item: SupplyItem
    let onToggle: () -> Void
 
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
 
                    Spacer()
 
                    Text("\(item.products.count) products")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.35))
 
                    Image(systemName: item.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .animation(.easeInOut(duration: 0.2), value: item.isExpanded)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
            }
            .buttonStyle(PlainButtonStyle())
            Divider()
                .background(Color.white.opacity(0.07))
                .padding(.leading, 14)
            if item.isExpanded {
                VStack(spacing: 0) {
                    ForEach(item.products) { product in
                        ProductDetailRow(product: product)
                    }
                }
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.04))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct ProductDetailRow: View {
    let product: ProductDetail
 
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
 
                HStack(spacing: 6) {
                    Text(product.brand)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
 
                    if !product.notes.isEmpty {
                        Text("·")
                            .foregroundColor(.white.opacity(0.3))
                        Text(product.notes)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#4A90E2").opacity(0.8))
                    }
                }
 
                Text(String(format: "$%.2f  ($%.2f with HST)", product.price, product.priceWithTax))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#4A90E2"))
            }
 
            Spacer()
 
            VStack(alignment: .trailing, spacing: 6) {
                Text(product.unit)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.35))
 
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.clear)
 
        Divider()
            .background(Color.white.opacity(0.05))
            .padding(.leading, 14)
    }
}

struct SuppliesScreenView: View {
    @Binding var currentScreen: AppScreen
    @State private var searchText = ""
 
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
        if searchText.isEmpty { return supplies }
        return supplies.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
 
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)
 
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.4))
                    TextField("", text: $searchText, prompt: Text("Search Item").foregroundColor(.white.opacity(0.4)))
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
                .padding(.horizontal, 24)
 
                Button(action: {}) {
                    Text("Add a new item")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#4A90E2").opacity(0.25))
                                .overlay(Capsule().stroke(Color(hex: "#4A90E2"), lineWidth: 2))
                        )
                }
                .padding(.top, 6)
 
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredSupplies) { supply in
                            SupplyItemCard(supply: supply)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                }
 
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
 
struct Supply: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
}
 
struct SupplyItemCard: View {
    let supply: Supply
 
    var priceWithTax: Double { supply.price * 1.13 }
 
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(supply.name)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
 
                Text(String(format: "$%.2f ($%.2f with HST)", supply.price, priceWithTax))
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "#4A90E2"))
            }
 
            Spacer()
 
            Button(action: {}) {
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
}