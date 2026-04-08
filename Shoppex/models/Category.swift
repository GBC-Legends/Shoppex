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
