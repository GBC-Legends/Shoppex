import SwiftUI

struct CategoriesScreenView: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject private var shoppingStore: ShoppingStore

    @State private var searchText = ""
    @State private var categories: [CategoryItem] = []
    @State private var newCategoryName = ""
    @State private var newProductName = ""
    @State private var selectedCategoryID: UUID?
    @State private var selectedProductID: UUID?
    @State private var activeAlert: ActiveAlert?

    enum ActiveAlert {
        case category
        case product
        case renameCategory
        case renameProduct
    }

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
                Button(action: {
                    activeAlert = .category
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("New Category")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
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
                                },
                                onAddProduct: addProductToShopping,
                                onAddProductToCategory: { categoryID in
                                    selectedCategoryID = categoryID
                                    activeAlert = .product
                                },
                                onRenameCategory: { categoryID in
                                    selectedCategoryID = categoryID
                                    newCategoryName = categories.first(where: { $0.id == categoryID })?.name ?? ""
                                    activeAlert = .renameCategory
                                },
                                onDeleteCategory: { categoryID in
                                    DB.shared.deleteCategory(id: categoryID)
                                    categories = DB.shared.fetchCategoriesTree()
                                },
                                onRenameProduct: { productID in
                                    selectedProductID = productID
                                    newProductName = categories
                                        .flatMap({ $0.products })
                                        .first(where: { $0.id == productID })?.name ?? ""
                                    activeAlert = .renameProduct
                                },
                                onDeleteProduct: { productID in
                                    DB.shared.deleteProduct(id: productID)
                                    categories = DB.shared.fetchCategoriesTree()
                                },
                                onNavigateToTracking: {
                                    withAnimation(.easeInOut) {
                                        currentScreen = .tracking
                                    }
                                },
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
        .onReceive(NotificationCenter.default.publisher(for: .trackedItemsDidChange)) { _ in
            categories = DB.shared.fetchCategoriesTree()
        }
        .alert(
        activeAlert == .category ? "New Category" :
            activeAlert == .renameCategory ? "Rename Category" :
            activeAlert == .renameProduct ? "Rename Product" : "New Product",
            isPresented: Binding(
                get: { activeAlert != nil },
                set: { if !$0 { activeAlert = nil } }
            )
        ) {
            if activeAlert == .category {
                TextField("Category name", text: $newCategoryName)

                Button("Add") {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    DB.shared.addCategory(name: trimmed, icon: "folder.fill")
                    categories = DB.shared.fetchCategoriesTree()
                    newCategoryName = ""
                    activeAlert = nil
                }
            } else if activeAlert == .renameCategory {
                TextField("Category name", text: $newCategoryName)

                Button("Save") {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard let categoryID = selectedCategoryID,
                          !trimmed.isEmpty else { return }
                    DB.shared.renameCategory(id: categoryID, newName: trimmed)
                    categories = DB.shared.fetchCategoriesTree()
                    newCategoryName = ""
                    selectedCategoryID = nil
                    activeAlert = nil
                }
            } else if activeAlert == .renameProduct {
                TextField("Product name", text: $newProductName)

                Button("Save") {
                    let trimmed = newProductName.trimmingCharacters(in: .whitespacesAndNewlines)

                    guard let productID = selectedProductID,
                          !trimmed.isEmpty else { return }

                    DB.shared.renameProduct(id: productID, newName: trimmed)
                    categories = DB.shared.fetchCategoriesTree()

                    newProductName = ""
                    selectedProductID = nil
                    activeAlert = nil
                }
            } else {
                TextField("Product name", text: $newProductName)

                Button("Add") {
                    let trimmed = newProductName.trimmingCharacters(in: .whitespacesAndNewlines)

                    guard let categoryID = selectedCategoryID,
                          !trimmed.isEmpty else { return }

                    DB.shared.addProduct(name: trimmed, categoryID: categoryID)
                    categories = DB.shared.fetchCategoriesTree()
                    newProductName = ""
                    selectedCategoryID = nil
                    activeAlert = nil
                }
            }

            Button("Cancel", role: .cancel) {
                newCategoryName = ""
                newProductName = ""
                selectedCategoryID = nil
                selectedProductID = nil
                activeAlert = nil
            }
        }
    }

    private func toggleCategory(id: UUID) {
        withAnimation(.easeInOut(duration: 0.25)) {
            if let index = categories.firstIndex(where: { $0.id == id }) {
                categories[index].isExpanded.toggle()
                DB.shared.updateCategoryExpanded(
                    id: id,
                    isExpanded: categories[index].isExpanded
                )
            }
        }
    }

    private func toggleProduct(categoryID: UUID, productID: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }),
               let productIndex = categories[categoryIndex].products.firstIndex(where: { $0.id == productID }) {
               categories[categoryIndex].products[productIndex].isExpanded.toggle()
               DB.shared.updateProductExpanded(
                   id: productID,
                   isExpanded: categories[categoryIndex].products[productIndex].isExpanded
               )
            }
        }
    }

    private func addProductToShopping(_ product: ProductItem) {
        shoppingStore.addProduct(product)
        withAnimation(.easeInOut) {
            currentScreen = .tracking
        }
    }
}

struct CategoryAccordionRow: View {
    let category: CategoryItem
    let onToggleCategory: () -> Void
    let onToggleProduct: (UUID) -> Void
    let onAddProduct: (ProductItem) -> Void
    let onAddProductToCategory: (UUID) -> Void
    let onRenameCategory: (UUID) -> Void
    let onDeleteCategory: (UUID) -> Void
    let onRenameProduct: (UUID) -> Void
    let onDeleteProduct: (UUID) -> Void
    let onNavigateToTracking: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Button(action: onToggleCategory) {
                        HStack(spacing: 14) {
                            Image(systemName: category.icon)
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "#4A90E2"))
                                .frame(width: 28)

                            Text(category.name)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)

                                Spacer()

                                Text("\(category.products.count)")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.4))
                                    .frame(minWidth: 20)

                                Menu {
                                    Button("Add Product") {
                                        onAddProductToCategory(category.id)
                                    }

                                    Button("Rename") {
                                        onRenameCategory(category.id)
                                    }

                                    Button("Delete", role: .destructive) {
                                        onDeleteCategory(category.id)
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                }

                                Image(systemName: category.isExpanded ? "chevron.down" : "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .buttonStyle(.plain)
                }

                if category.isExpanded {
                    VStack(spacing: 0) {
                        ForEach(category.products) { product in
                            ProductAccordionRow(
                                product: product,
                                onToggle: { onToggleProduct(product.id) },
                                onAdd: { onAddProduct(product) },
                                onRename: {
                                    onRenameProduct(product.id)
                                },
                                onDelete: {
                                    onDeleteProduct(product.id)
                                },
                                onNavigateToTracking: onNavigateToTracking
                            )
                            .padding(.leading, 6)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
            .padding(.bottom, 10)
        }
    }

    struct ProductAccordionRow: View {
        let product: ProductItem
        let onToggle: () -> Void
        let onAdd: () -> Void
        let onRename: () -> Void
        let onDelete: () -> Void
        let onNavigateToTracking: () -> Void

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Button(action: onToggle) {
                        HStack {
                            Text(product.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))

                            Spacer()

                            Image(systemName: product.isExpanded ? "chevron.down" : "chevron.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                                .animation(.easeInOut(duration: 0.2), value: product.isExpanded)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                    }
                    .buttonStyle(PlainButtonStyle())

                    HStack(spacing: 12) {
                        Button(action: onAdd) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(Color(hex: "#0A84FF"))
                        }

                        Menu {
                            Button("Rename") {
                                onRename()
                            }

                            Button("Delete", role: .destructive) {
                                onDelete()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.trailing, 12)
                }

                Divider()
                    .background(Color.white.opacity(0.07))
                    .padding(.leading, 14)

                if product.isExpanded {
                    VStack(spacing: 0) {
                        ForEach(product.trackedItems) { trackedItem in
                            TrackedItemRow(
                                trackedItem: trackedItem,
                                onDelete: {
                                    DB.shared.deleteTrackedItem(id: trackedItem.id)
                                },
                                onReAdd: {
                                    onNavigateToTracking()
                                }
                            )
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
        @EnvironmentObject private var shoppingStore: ShoppingStore

        let trackedItem: TrackedItem
        let onDelete: () -> Void
        let onReAdd: () -> Void

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

                    Text(String(format: "$%.2f", trackedItem.price))
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#4A90E2"))

                    Text(trackedItem.isTaxable ? "Taxable item" : "Non-taxable item")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(trackedItem.unit)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.35))

                    HStack(spacing: 10) {
                        Button(action: {
                            let draft = TrackedShoppingItem(
                                productID: trackedItem.productID,
                                productName: trackedItem.name,
                                itemName: trackedItem.name,
                                unit: trackedItem.unit,
                                brand: trackedItem.brand,
                                price: String(format: "%.2f", trackedItem.price),
                                notes: trackedItem.notes,
                                taxable: trackedItem.isTaxable
                            )

                            shoppingStore.draftItems.append(draft)
                            shoppingStore.persistDraftItems()
                            onReAdd()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "#0A84FF"))
                        }

                        Button(action: onDelete) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.red.opacity(0.8))
                        }
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
}
