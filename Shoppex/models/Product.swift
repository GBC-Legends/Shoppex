import Foundation

struct TrackedItem: Identifiable {
    let id: UUID
    let name: String
    let price: Double
    let unit: String
    let brand: String
    let notes: String
    let purchasedAt: String

    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        unit: String,
        brand: String,
        notes: String,
        purchasedAt: String
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.unit = unit
        self.brand = brand
        self.notes = notes
        self.purchasedAt = purchasedAt
    }

    var priceWithTax: Double { price * 1.13 }
}
