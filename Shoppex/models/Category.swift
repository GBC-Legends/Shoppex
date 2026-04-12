import Foundation

struct CategoryItem: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    var products: [ProductItem]
    var isExpanded: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        products: [ProductItem],
        isExpanded: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.products = products
        self.isExpanded = isExpanded
    }
}

extension CategoryItem {
    static var sampleData: [CategoryItem] {
        let milkProduct = ProductItem(name: "Milk", trackedItems: [], isExpanded: true)
        let cheeseProduct = ProductItem(name: "Cheese", trackedItems: [], isExpanded: true)
        let sourCreamProduct = ProductItem(name: "Sour Cream", trackedItems: [], isExpanded: true)
        let breadProduct = ProductItem(name: "Bread", trackedItems: [], isExpanded: true)
        let bagelsProduct = ProductItem(name: "Bagels", trackedItems: [], isExpanded: true)
        let applesProduct = ProductItem(name: "Apples", trackedItems: [], isExpanded: true)
        let bananasProduct = ProductItem(name: "Bananas", trackedItems: [], isExpanded: true)
        let detergentProduct = ProductItem(name: "Detergent", trackedItems: [], isExpanded: true)
        let dishSoapProduct = ProductItem(name: "Dish Soap", trackedItems: [], isExpanded: true)
        let paperTowelsProduct = ProductItem(name: "Paper Towels", trackedItems: [], isExpanded: true)
        let painReliefProduct = ProductItem(name: "Pain Relief", trackedItems: [], isExpanded: true)

        let dairy = CategoryItem(
            name: "Dairy",
            icon: "drop.fill",
            products: [milkProduct, cheeseProduct, sourCreamProduct],
            isExpanded: true
        )

        let bakery = CategoryItem(
            name: "Bakery",
            icon: "flame.fill",
            products: [breadProduct, bagelsProduct],
            isExpanded: true
        )

        let produce = CategoryItem(
            name: "Produce",
            icon: "leaf.fill",
            products: [applesProduct, bananasProduct],
            isExpanded: true
        )

        let cleaning = CategoryItem(
            name: "Cleaning",
            icon: "sparkles",
            products: [detergentProduct, dishSoapProduct, paperTowelsProduct],
            isExpanded: true
        )

        let medication = CategoryItem(
            name: "Medication",
            icon: "cross.fill",
            products: [painReliefProduct],
            isExpanded: true
        )

        return [dairy, bakery, produce, cleaning, medication]
    }
}
