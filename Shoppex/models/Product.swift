import Foundation
import Combine

extension Notification.Name {
    static let trackedItemsDidChange = Notification.Name("trackedItemsDidChange")
}

struct TrackedItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let price: Double
    let unit: String
    let brand: String
    let notes: String
    let purchasedAt: String
    let isTaxable: Bool

    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        unit: String,
        brand: String,
        notes: String,
        purchasedAt: String,
        isTaxable: Bool
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.unit = unit
        self.brand = brand
        self.notes = notes
        self.purchasedAt = purchasedAt
        self.isTaxable = isTaxable
    }
}

struct TrackedShoppingItem: Identifiable, Codable {
    let id: UUID
    let productID: UUID
    let trackedItemID: UUID?
    let productName: String
    var itemName: String
    var unit: String
    var brand: String
    var price: String
    var notes: String
    var taxable: Bool

    init(
        id: UUID = UUID(),
        productID: UUID,
        trackedItemID: UUID? = nil,
        productName: String,
        itemName: String,
        unit: String,
        brand: String,
        price: String,
        notes: String,
        taxable: Bool
    ) {
        self.id = id
        self.productID = productID
        self.trackedItemID = trackedItemID
        self.productName = productName
        self.itemName = itemName
        self.unit = unit
        self.brand = brand
        self.price = price
        self.notes = notes
        self.taxable = taxable
    }

    init(productID: UUID, productName: String) {
        self.init(
            productID: productID,
            productName: productName,
            itemName: "",
            unit: "",
            brand: "",
            price: "",
            notes: "",
            taxable: false
        )
    }

    var priceValue: Double {
        Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
}

struct TrackedShopping: Identifiable, Codable {
    let id: UUID
    let province: String
    let purchasedAt: String
    let items: [TrackedShoppingItem]

    init(
        id: UUID = UUID(),
        province: String,
        purchasedAt: String,
        items: [TrackedShoppingItem]
    ) {
        self.id = id
        self.province = province
        self.purchasedAt = purchasedAt
        self.items = items
    }

    func subtotal() -> Double {
        items.reduce(0) { $0 + $1.priceValue }
    }

    func taxAmount(provinceRates: [String: Double]) -> Double {
        let rate = provinceRates[province] ?? 0
        let taxableTotal = items.filter(\.taxable).reduce(0) { $0 + $1.priceValue }
        return taxableTotal * rate
    }

    func total(provinceRates: [String: Double]) -> Double {
        subtotal() + taxAmount(provinceRates: provinceRates)
    }
}

final class ShoppingStore: ObservableObject {
    private enum StorageKey {
        static let savedShoppings = "saved_shoppings"
    }

    static let provinceRates: [String: Double] = [
        "Alberta": 0.05,
        "British Columbia": 0.12,
        "Manitoba": 0.12,
        "New Brunswick": 0.15,
        "Newfoundland and Labrador": 0.15,
        "Northwest Territories": 0.05,
        "Nova Scotia": 0.14,
        "Nunavut": 0.05,
        "Ontario": 0.13,
        "Prince Edward Island": 0.15,
        "Quebec": 0.14975,
        "Saskatchewan": 0.11,
        "Yukon": 0.05
    ]

    @Published var selectedProvince = "Ontario"
    @Published var draftItems: [TrackedShoppingItem] = []
    @Published var savedShoppings: [TrackedShopping] = []

    init() {
        loadSavedShoppings()
    }

    func addProduct(_ product: ProductItem) {
        draftItems.append(TrackedShoppingItem(productID: product.id, productName: product.name))
    }

    func removeDraftItem(id: UUID) {
        draftItems.removeAll { $0.id == id }
    }

    func subtotal() -> Double {
        draftItems.reduce(0) { $0 + $1.priceValue }
    }

    func taxAmount() -> Double {
        let rate = Self.provinceRates[selectedProvince] ?? 0
        let taxableTotal = draftItems.filter(\.taxable).reduce(0) { $0 + $1.priceValue }
        return taxableTotal * rate
    }

    func total() -> Double {
        subtotal() + taxAmount()
    }

    func saveCurrentShopping() {
        guard !draftItems.isEmpty else { return }

        let purchaseDate = currentDateString()
        let itemsToSave = draftItems

        for item in itemsToSave {
            DB.shared.insertTrackedShoppingItem(item, purchasedAt: purchaseDate)
        }

        let shopping = TrackedShopping(
            province: selectedProvince,
            purchasedAt: purchaseDate,
            items: itemsToSave
        )

        savedShoppings.insert(shopping, at: 0)
        draftItems = []
        persistSavedShoppings()
        NotificationCenter.default.post(name: .trackedItemsDidChange, object: nil)
    }

    func currentTaxRateText() -> String {
        String(format: "%.2f%%", (Self.provinceRates[selectedProvince] ?? 0) * 100)
    }

    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func persistSavedShoppings() {
        guard let data = try? JSONEncoder().encode(savedShoppings) else { return }
        UserDefaults.standard.set(data, forKey: StorageKey.savedShoppings)
    }

    private func loadSavedShoppings() {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.savedShoppings),
              let decoded = try? JSONDecoder().decode([TrackedShopping].self, from: data) else {
            return
        }

        savedShoppings = decoded
    }
}
