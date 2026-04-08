import Foundation

struct SupplyItem: Identifiable {
    let id: UUID
    let name: String
    let products: [ProductDetail]
    var isExpanded: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        products: [ProductDetail],
        isExpanded: Bool = false
    ) {
        self.id = id
        self.name = name
        self.products = products
        self.isExpanded = isExpanded
    }
}
