import Foundation

struct ProductItem: Identifiable {
    let id: UUID
    let name: String
    let trackedItems: [TrackedItem]
    var isExpanded: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        trackedItems: [TrackedItem],
        isExpanded: Bool = false
    ) {
        self.id = id
        self.name = name
        self.trackedItems = trackedItems
        self.isExpanded = isExpanded
    }
}
