import Foundation

struct CategoryItem: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    var items: [SupplyItem]
    var isExpanded: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        items: [SupplyItem],
        isExpanded: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.items = items
        self.isExpanded = isExpanded
    }
}

extension CategoryItem {
    static var sampleData: [CategoryItem] {
        let milk = ProductDetail(name: "Whole Milk 1L", price: 4.29, unit: "1L", brand: "Natrel", notes: "Refrigerated")
        let milk2 = ProductDetail(name: "2% Milk 2L", price: 6.49, unit: "2L", brand: "Beatrice", notes: "Refrigerated")
        let cheese = ProductDetail(name: "Cheddar Block 400g", price: 8.99, unit: "400g", brand: "Black Diamond", notes: "Refrigerated")
        let sourCream = ProductDetail(name: "Sour Cream 500mL", price: 3.79, unit: "500mL", brand: "Astro", notes: "Refrigerated")
        let bread = ProductDetail(name: "White Sandwich Bread", price: 3.49, unit: "675g", brand: "Wonder", notes: "")
        let wholeWheat = ProductDetail(name: "Whole Wheat Loaf", price: 4.29, unit: "600g", brand: "Dempster's", notes: "High fibre")
        let bagels = ProductDetail(name: "Plain Bagels", price: 4.49, unit: "6 pack", brand: "Montreal Style", notes: "")
        let apples = ProductDetail(name: "Green Apples", price: 7.99, unit: "bag 1.5kg", brand: "Local Farm", notes: "Granny Smith")
        let galaApples = ProductDetail(name: "Gala Apples", price: 6.99, unit: "bag 1.5kg", brand: "Local Farm", notes: "")
        let bananas = ProductDetail(name: "Bananas", price: 2.49, unit: "bunch", brand: "Chiquita", notes: "")
        let detergent = ProductDetail(name: "Laundry Pods 42ct", price: 15.00, unit: "42 count", brand: "Tide", notes: "")
        let liquidDetergent = ProductDetail(name: "Liquid Detergent 1.47L", price: 12.99, unit: "1.47L", brand: "Gain", notes: "Fresh scent")
        let dishSoap = ProductDetail(name: "Dish Soap 532mL", price: 4.99, unit: "532mL", brand: "Dawn", notes: "Original")
        let paperTowels = ProductDetail(name: "Paper Towels 6-Roll", price: 8.99, unit: "6 rolls", brand: "Bounty", notes: "Select-A-Size")
        let ibuprofen = ProductDetail(name: "Ibuprofen 200mg 100ct", price: 11.99, unit: "100 tablets", brand: "Advil", notes: "Take with food")
        let acetaminophen = ProductDetail(name: "Acetaminophen 500mg", price: 9.49, unit: "100 tablets", brand: "Tylenol", notes: "")

        let milkSupply = SupplyItem(name: "Milk", products: [milk, milk2], isExpanded: true)
        let cheeseSupply = SupplyItem(name: "Cheese", products: [cheese], isExpanded: true)
        let sourCreamSupply = SupplyItem(name: "Sour Cream", products: [sourCream], isExpanded: true)
        let breadSupply = SupplyItem(name: "Bread", products: [bread, wholeWheat], isExpanded: true)
        let bagelsSupply = SupplyItem(name: "Bagels", products: [bagels], isExpanded: true)
        let applesSupply = SupplyItem(name: "Apples", products: [apples, galaApples], isExpanded: true)
        let bananasSupply = SupplyItem(name: "Bananas", products: [bananas], isExpanded: true)
        let detergentSupply = SupplyItem(name: "Detergent", products: [detergent, liquidDetergent], isExpanded: true)
        let dishSoapSupply = SupplyItem(name: "Dish Soap", products: [dishSoap], isExpanded: true)
        let paperTowelsSupply = SupplyItem(name: "Paper Towels", products: [paperTowels], isExpanded: true)
        let painReliefSupply = SupplyItem(name: "Pain Relief", products: [ibuprofen, acetaminophen], isExpanded: true)

        let dairy = CategoryItem(name: "Dairy", icon: "drop.fill", items: [milkSupply, cheeseSupply, sourCreamSupply], isExpanded: true)
        let bakery = CategoryItem(name: "Bakery", icon: "flame.fill", items: [breadSupply, bagelsSupply], isExpanded: true)
        let produce = CategoryItem(name: "Produce", icon: "leaf.fill", items: [applesSupply, bananasSupply], isExpanded: true)
        let cleaning = CategoryItem(name: "Cleaning", icon: "sparkles", items: [detergentSupply, dishSoapSupply, paperTowelsSupply], isExpanded: true)
        let medication = CategoryItem(name: "Medication", icon: "cross.fill", items: [painReliefSupply], isExpanded: true)

        return [dairy, bakery, produce, cleaning, medication]
    }
}
