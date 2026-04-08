import SwiftUI

struct CategoriesScreenView: View {
    @Binding var currentScreen: AppScreen
    @State private var searchText = ""
    @State private var categories: [CategoryItem] = []

    var filteredCategories: [CategoryItem] {
        guard !searchText.isEmpty else { return categories }
        return categories.compactMap { category in
            let matchingItems = category.items.compactMap { item -> SupplyItem? in
                if item.name.lowercased().contains(searchText.lowercased()) { return item }
                let matchingProducts = item.products.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
                if !matchingProducts.isEmpty {
                    let copy = item
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

        .onAppear {
            categories = DB.shared.fetchCategoriesTree()
        }
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
