import SwiftUI

struct CategoriesScreenView: View {
    @Binding var currentScreen: AppScreen
    @State private var searchText = ""
    @State private var categories: [CategoryItem] = []

    var filteredCategories: [CategoryItem] {
        guard !searchText.isEmpty else { return categories }

        return categories.compactMap { category in
            let matchingProducts = category.products.compactMap { product -> ProductItem? in
                if product.name.lowercased().contains(searchText.lowercased()) {
                    return product
                }

                let matchingTrackedItems = product.trackedItems.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }

                guard !matchingTrackedItems.isEmpty else { return nil }

                return ProductItem(
                    id: product.id,
                    name: product.name,
                    trackedItems: matchingTrackedItems,
                    isExpanded: product.isExpanded
                )
            }

            if category.name.lowercased().contains(searchText.lowercased()) {
                return category
            }

            guard !matchingProducts.isEmpty else { return nil }

            var copy = category
            copy.products = matchingProducts
            return copy
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.4))
                    TextField("", text: $searchText, prompt: Text("Search products...").foregroundColor(.white.opacity(0.4)))
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
                                onToggleProduct: { productID in
                                    toggleProduct(categoryID: filteredCategories[catIndex].id, productID: productID)
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
            if let index = categories.firstIndex(where: { $0.id == id }) {
                categories[index].isExpanded.toggle()
            }
        }
    }

    private func toggleProduct(categoryID: UUID, productID: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }),
               let productIndex = categories[categoryIndex].products.firstIndex(where: { $0.id == productID }) {
                categories[categoryIndex].products[productIndex].isExpanded.toggle()
            }
        }
    }
}

struct CategoryAccordionRow: View {
    let category: CategoryItem
    let onToggleCategory: () -> Void
    let onToggleProduct: (UUID) -> Void

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

                    Text("\(category.products.count) products")
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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())

            if category.isExpanded {
                VStack(spacing: 0) {
                    ForEach(category.products) { product in
                        ProductAccordionRow(
                            product: product,
                            onToggle: { onToggleProduct(product.id) }
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

struct ProductAccordionRow: View {
    let product: ProductItem
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(product.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()

                    Text("\(product.trackedItems.count) purchases")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.35))

                    Image(systemName: product.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .animation(.easeInOut(duration: 0.2), value: product.isExpanded)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
            }
            .buttonStyle(PlainButtonStyle())

            Divider()
                .background(Color.white.opacity(0.07))
                .padding(.leading, 14)

            if product.isExpanded {
                VStack(spacing: 0) {
                    ForEach(product.trackedItems) { trackedItem in
                        TrackedItemRow(trackedItem: trackedItem)
                    }
                }
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.04))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct TrackedItemRow: View {
    let trackedItem: TrackedItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(trackedItem.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))

                HStack(spacing: 6) {
                    Text(trackedItem.brand)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))

                    if !trackedItem.notes.isEmpty {
                        Text("·")
                            .foregroundColor(.white.opacity(0.3))
                        Text(trackedItem.notes)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#4A90E2").opacity(0.8))
                    }
                }

                Text(trackedItem.purchasedAt)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))

                Text(String(format: "$%.2f  ($%.2f with HST)", trackedItem.price, trackedItem.priceWithTax))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#4A90E2"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(trackedItem.unit)
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
