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

struct TrackedShoppingItem: Identifiable, Codable, Equatable {
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

    var quantityValue: Double {
        Double(unit.replacingOccurrences(of: ",", with: ".")) ?? 1
    }

    var priceValue: Double {
        let basePrice = Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0
        return basePrice * quantityValue
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
        static let draftItems = "draft_items"
        static let selectedProvince = "selected_province"
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
    @Published var editingShoppingID: UUID?

    init() {
        loadSavedShoppings()
        loadDraftItems()
        loadSelectedProvince()
    }

    func addProduct(_ product: ProductItem) {
        draftItems.append(TrackedShoppingItem(productID: product.id, productName: product.name))
        persistDraftItems()
    }

    func removeDraftItem(id: UUID) {
        draftItems.removeAll { $0.id == id }
        persistDraftItems()
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

        if let editingID = editingShoppingID,
           let oldShopping = savedShoppings.first(where: { $0.id == editingID }) {
            deleteShopping(oldShopping)
        }

        let savedItems = itemsToSave.map { item -> TrackedShoppingItem in
            let newID = DB.shared.insertTrackedShoppingItem(item, purchasedAt: purchaseDate)

            return TrackedShoppingItem(
                id: item.id,
                productID: item.productID,
                trackedItemID: newID,
                productName: item.productName,
                itemName: item.itemName,
                unit: item.unit,
                brand: item.brand,
                price: item.price,
                notes: item.notes,
                taxable: item.taxable
            )
        }

        let shopping = TrackedShopping(
            province: selectedProvince,
            purchasedAt: purchaseDate,
            items: savedItems
        )

        savedShoppings.insert(shopping, at: 0)

        draftItems = []
        persistDraftItems()
        editingShoppingID = nil

        persistSavedShoppings()
        NotificationCenter.default.post(name: .trackedItemsDidChange, object: nil)
    }

    func currentTaxRateText() -> String {
        let rate = (Self.provinceRates[selectedProvince] ?? 0) * 100
        return "\(rate)%"
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

    func currentMonthTotal() -> Double {
        let currentMonth = currentDateString().prefix(7)

        return savedShoppings
            .filter { $0.purchasedAt.hasPrefix(currentMonth) }
            .reduce(0) { $0 + $1.total(provinceRates: Self.provinceRates) }
    }

    func currentMonthPercent(of budget: Double = 500) -> Int {
        guard budget > 0 else { return 0 }
        return Int((currentMonthTotal() / budget) * 100)
    }

    func deleteShopping(_ shopping: TrackedShopping) {
        for item in shopping.items {
            if let trackedID = item.trackedItemID {
                DB.shared.deleteTrackedItem(id: trackedID)
            }
        }

        savedShoppings.removeAll {$0.id == shopping.id}
        persistSavedShoppings()
    }

    func editShopping(_ shopping: TrackedShopping) {
        draftItems = shopping.items
        selectedProvince = shopping.province
        editingShoppingID = shopping.id
        persistDraftItems()
        persistSelectedProvince()
    }

    func persistDraftItems() {
        guard let data = try? JSONEncoder().encode(draftItems) else { return }
        UserDefaults.standard.set(data, forKey: StorageKey.draftItems)
    }

    func loadDraftItems() {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.draftItems),
              let decoded = try? JSONDecoder().decode([TrackedShoppingItem].self, from: data) else {
            return
        }

        draftItems = decoded
    }

    func updateDraft() {
        persistDraftItems()
    }

    func persistSelectedProvince() {
        UserDefaults.standard.set(selectedProvince, forKey: StorageKey.selectedProvince)
    }

    func loadSelectedProvince() {
        if let province = UserDefaults.standard.string(forKey: StorageKey.selectedProvince) {
            selectedProvince = province
        }
    }
}
