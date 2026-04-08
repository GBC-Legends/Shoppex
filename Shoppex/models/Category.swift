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
        let milkWhole = TrackedItem(name: "Whole Milk 1L", price: 4.29, unit: "1L", brand: "Natrel", notes: "Refrigerated", purchasedAt: "2026-04-08")
        let milkTwoPercent = TrackedItem(name: "2% Milk 2L", price: 6.49, unit: "2L", brand: "Beatrice", notes: "Refrigerated", purchasedAt: "2026-04-08")
        let cheeseBlock = TrackedItem(name: "Cheddar Block 400g", price: 8.99, unit: "400g", brand: "Black Diamond", notes: "Refrigerated", purchasedAt: "2026-04-08")
        let sourCreamTub = TrackedItem(name: "Sour Cream 500mL", price: 3.79, unit: "500mL", brand: "Astro", notes: "Refrigerated", purchasedAt: "2026-04-08")
        let whiteBread = TrackedItem(name: "White Sandwich Bread", price: 3.49, unit: "675g", brand: "Wonder", notes: "", purchasedAt: "2026-04-08")
        let wholeWheatLoaf = TrackedItem(name: "Whole Wheat Loaf", price: 4.29, unit: "600g", brand: "Dempster's", notes: "High fibre", purchasedAt: "2026-04-08")
        let plainBagels = TrackedItem(name: "Plain Bagels", price: 4.49, unit: "6 pack", brand: "Montreal Style", notes: "", purchasedAt: "2026-04-08")
        let greenApples = TrackedItem(name: "Green Apples", price: 7.99, unit: "bag 1.5kg", brand: "Local Farm", notes: "Granny Smith", purchasedAt: "2026-04-08")
        let galaApples = TrackedItem(name: "Gala Apples", price: 6.99, unit: "bag 1.5kg", brand: "Local Farm", notes: "", purchasedAt: "2026-04-08")
        let bananaBunch = TrackedItem(name: "Bananas", price: 2.49, unit: "bunch", brand: "Chiquita", notes: "", purchasedAt: "2026-04-08")
        let laundryPods = TrackedItem(name: "Laundry Pods 42ct", price: 15.00, unit: "42 count", brand: "Tide", notes: "", purchasedAt: "2026-04-08")
        let liquidDetergent = TrackedItem(name: "Liquid Detergent 1.47L", price: 12.99, unit: "1.47L", brand: "Gain", notes: "Fresh scent", purchasedAt: "2026-04-08")
        let dishSoapBottle = TrackedItem(name: "Dish Soap 532mL", price: 4.99, unit: "532mL", brand: "Dawn", notes: "Original", purchasedAt: "2026-04-08")
        let paperTowelsPack = TrackedItem(name: "Paper Towels 6-Roll", price: 8.99, unit: "6 rolls", brand: "Bounty", notes: "Select-A-Size", purchasedAt: "2026-04-08")
        let ibuprofenBottle = TrackedItem(name: "Ibuprofen 200mg 100ct", price: 11.99, unit: "100 tablets", brand: "Advil", notes: "Take with food", purchasedAt: "2026-04-08")
        let acetaminophenBottle = TrackedItem(name: "Acetaminophen 500mg", price: 9.49, unit: "100 tablets", brand: "Tylenol", notes: "", purchasedAt: "2026-04-08")

        let milkProduct = ProductItem(name: "Milk", trackedItems: [milkWhole, milkTwoPercent], isExpanded: true)
        let cheeseProduct = ProductItem(name: "Cheese", trackedItems: [cheeseBlock], isExpanded: true)
        let sourCreamProduct = ProductItem(name: "Sour Cream", trackedItems: [sourCreamTub], isExpanded: true)
        let breadProduct = ProductItem(name: "Bread", trackedItems: [whiteBread, wholeWheatLoaf], isExpanded: true)
        let bagelsProduct = ProductItem(name: "Bagels", trackedItems: [plainBagels], isExpanded: true)
        let applesProduct = ProductItem(name: "Apples", trackedItems: [greenApples, galaApples], isExpanded: true)
        let bananasProduct = ProductItem(name: "Bananas", trackedItems: [bananaBunch], isExpanded: true)
        let detergentProduct = ProductItem(name: "Detergent", trackedItems: [laundryPods, liquidDetergent], isExpanded: true)
        let dishSoapProduct = ProductItem(name: "Dish Soap", trackedItems: [dishSoapBottle], isExpanded: true)
        let paperTowelsProduct = ProductItem(name: "Paper Towels", trackedItems: [paperTowelsPack], isExpanded: true)
        let painReliefProduct = ProductItem(name: "Pain Relief", trackedItems: [ibuprofenBottle, acetaminophenBottle], isExpanded: true)

        let dairy = CategoryItem(name: "Dairy", icon: "drop.fill", products: [milkProduct, cheeseProduct, sourCreamProduct], isExpanded: true)
        let bakery = CategoryItem(name: "Bakery", icon: "flame.fill", products: [breadProduct, bagelsProduct], isExpanded: true)
        let produce = CategoryItem(name: "Produce", icon: "leaf.fill", products: [applesProduct, bananasProduct], isExpanded: true)
        let cleaning = CategoryItem(name: "Cleaning", icon: "sparkles", products: [detergentProduct, dishSoapProduct, paperTowelsProduct], isExpanded: true)
        let medication = CategoryItem(name: "Medication", icon: "cross.fill", products: [painReliefProduct], isExpanded: true)

        return [dairy, bakery, produce, cleaning, medication]
    }
}
