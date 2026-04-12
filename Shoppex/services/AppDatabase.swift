import Foundation
import GRDB
import SQLite3

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

struct CategoryRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var icon: String
    var isExpanded: Bool

    init(id: String, name: String, icon: String, isExpanded: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isExpanded = isExpanded
    }
}

struct ProductRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var categoryId: String
    var name: String
    var isExpanded: Bool

    init(id: String, categoryId: String, name: String, isExpanded: Bool = false) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.isExpanded = isExpanded
    }
}

struct TrackedItemRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var productId: String
    var name: String
    var price: Double
    var unit: String
    var brand: String
    var notes: String
    var purchasedAt: String
    var isTaxable: Bool

    init(
        productId: String,
        name: String,
        price: Double,
        unit: String,
        brand: String,
        notes: String = "",
        purchasedAt: String,
        isTaxable: Bool
    ) {
        self.id = UUID().uuidString
        self.productId = productId
        self.name = name
        self.price = price
        self.unit = unit
        self.brand = brand
        self.notes = notes
        self.purchasedAt = purchasedAt
        self.isTaxable = isTaxable
    }
}

enum AppDatabase {
    static func setup(_ dbQueue: DatabaseQueue) throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("createCategoryProductTrackedItemTables") { db in
            try db.create(table: "categories") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("icon", .text).notNull()
                t.column("isExpanded", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: "products") { t in
                t.column("id", .text).primaryKey()
                t.column("categoryId", .text)
                    .notNull()
                    .references("categories", onDelete: .cascade, onUpdate: .cascade)
                t.column("name", .text).notNull()
                t.column("isExpanded", .boolean).notNull().defaults(to: false)
            }

            try db.create(index: "idx_products_categoryId", on: "products", columns: ["categoryId"])

            try db.create(table: "tracked_items") { t in
                t.column("id", .text).primaryKey()
                t.column("productId", .text)
                    .notNull()
                    .references("products", onDelete: .cascade, onUpdate: .cascade)
                t.column("name", .text).notNull()
                t.column("price", .double).notNull()
                t.column("unit", .text).notNull()
                t.column("brand", .text).notNull()
                t.column("notes", .text).notNull().defaults(to: "")
                t.column("purchasedAt", .text).notNull()
                t.column("isTaxable", .boolean).notNull().defaults(to: false)
            }

            try db.create(index: "idx_tracked_items_productId", on: "tracked_items", columns: ["productId"])
        }

        migrator.registerMigration("seedInitialData") { db in
            let existingCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM categories") ?? 0
            guard existingCount == 0 else { return }

            try seed(db)
        }

        try migrator.migrate(dbQueue)
    }

    nonisolated private static func seed(_ db: Database) throws {
        let dairyId = UUID()
        let bakeryId = UUID()
        let produceId = UUID()
        let cleaningId = UUID()
        let medicationId = UUID()

        let categories = [
            CategoryRecord(id: dairyId.uuidString, name: "Dairy", icon: "drop.fill"),
            CategoryRecord(id: bakeryId.uuidString, name: "Bakery", icon: "flame.fill"),
            CategoryRecord(id: produceId.uuidString, name: "Produce", icon: "leaf.fill"),
            CategoryRecord(id: cleaningId.uuidString, name: "Cleaning", icon: "sparkles"),
            CategoryRecord(id: medicationId.uuidString, name: "Medication", icon: "cross.fill")
        ]

        for category in categories {
            try category.insert(db)
        }

        let milkId = UUID()
        let cheeseId = UUID()
        let sourCreamId = UUID()
        let breadId = UUID()
        let bagelsId = UUID()
        let applesId = UUID()
        let bananasId = UUID()
        let detergentId = UUID()
        let dishSoapId = UUID()
        let paperTowelsId = UUID()
        let painReliefId = UUID()

        let products = [
            ProductRecord(id: milkId.uuidString, categoryId: dairyId.uuidString, name: "Milk"),
            ProductRecord(id: cheeseId.uuidString, categoryId: dairyId.uuidString, name: "Cheese"),
            ProductRecord(id: sourCreamId.uuidString, categoryId: dairyId.uuidString, name: "Sour Cream"),
            ProductRecord(id: breadId.uuidString, categoryId: bakeryId.uuidString, name: "Bread"),
            ProductRecord(id: bagelsId.uuidString, categoryId: bakeryId.uuidString, name: "Bagels"),
            ProductRecord(id: applesId.uuidString, categoryId: produceId.uuidString, name: "Apples"),
            ProductRecord(id: bananasId.uuidString, categoryId: produceId.uuidString, name: "Bananas"),
            ProductRecord(id: detergentId.uuidString, categoryId: cleaningId.uuidString, name: "Detergent"),
            ProductRecord(id: dishSoapId.uuidString, categoryId: cleaningId.uuidString, name: "Dish Soap"),
            ProductRecord(id: paperTowelsId.uuidString, categoryId: cleaningId.uuidString, name: "Paper Towels"),
            ProductRecord(id: painReliefId.uuidString, categoryId: medicationId.uuidString, name: "Pain Relief")
        ]

        for product in products {
            try product.insert(db)
        }

        let trackedItems: [TrackedItemRecord] = []

        for trackedItem in trackedItems {
            try trackedItem.insert(db)
        }
    }
}

final class DB {
    static let shared = DB()

    private var db: OpaquePointer?

    private init() {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Shoppex.sqlite")

        if sqlite3_open(url.path, &db) != SQLITE_OK {
            fatalError("Unable to open database")
        }

        execute("PRAGMA foreign_keys = ON;")

        migrateLegacySchemaIfNeeded()
        createTables()
        preseedIfNeeded()
    }

    deinit {
        sqlite3_close(db)
    }

    private func createTables() {
        let categoriesSQL = """
        CREATE TABLE IF NOT EXISTS categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            isExpanded INTEGER NOT NULL DEFAULT 0
        );
        """

        let productsSQL = """
        CREATE TABLE IF NOT EXISTS products (
            id TEXT PRIMARY KEY,
            categoryId TEXT NOT NULL,
            name TEXT NOT NULL,
            isExpanded INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
        );
        """

        let trackedItemsSQL = """
        CREATE TABLE IF NOT EXISTS tracked_items (
            id TEXT PRIMARY KEY,
            productId TEXT NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            unit TEXT NOT NULL,
            brand TEXT NOT NULL,
            notes TEXT NOT NULL DEFAULT '',
            purchasedAt TEXT NOT NULL,
            isTaxable INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE
        );
        """

        execute(categoriesSQL)
        execute(productsSQL)
        execute(trackedItemsSQL)

        execute("CREATE INDEX IF NOT EXISTS idx_products_categoryId ON products(categoryId);")
        execute("CREATE INDEX IF NOT EXISTS idx_tracked_items_productId ON tracked_items(productId);")
    }

    private func migrateLegacySchemaIfNeeded() {
        let hasLegacySuppliesTable = tableExists("supplies")
        let productsUsesOldSchema = tableExists("products") && !tableHasColumn(table: "products", column: "categoryId")
        let missingTrackedItemsTable = !tableExists("tracked_items")
        let trackedItemsMissingTaxFlag = tableExists("tracked_items") && !tableHasColumn(table: "tracked_items", column: "isTaxable")

        guard hasLegacySuppliesTable || productsUsesOldSchema || missingTrackedItemsTable || trackedItemsMissingTaxFlag else {
            return
        }

        execute("DROP TABLE IF EXISTS tracked_items;")
        execute("DROP TABLE IF EXISTS products;")
        execute("DROP TABLE IF EXISTS supplies;")
        execute("DROP TABLE IF EXISTS categories;")
    }

    private func preseedIfNeeded() {
        let count = scalarInt("SELECT COUNT(*) FROM categories LIMIT 1;")
        guard count == 0 else { return }

        let categories = CategoryItem.sampleData

        for category in categories {
            insertCategory(category)

            for product in category.products {
                insertProduct(product, categoryID: category.id.uuidString)

                for trackedItem in product.trackedItems {
                    insertTrackedItem(trackedItem, productID: product.id.uuidString)
                }
            }
        }
    }

    func insertCategory(_ category: CategoryItem) {
        let sql = """
        INSERT INTO categories (id, name, icon, isExpanded)
        VALUES (?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_text(stmt, 1, category.id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, category.name.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, category.icon.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 4, category.isExpanded ? 1 : 0)

        stepAndFinalize(stmt)
    }

    func insertProduct(_ product: ProductItem, categoryID: String) {
        let sql = """
        INSERT INTO products (id, categoryId, name, isExpanded)
        VALUES (?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_text(stmt, 1, product.id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, categoryID.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, product.name.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 4, product.isExpanded ? 1 : 0)

        stepAndFinalize(stmt)
    }

    func insertTrackedItem(_ trackedItem: TrackedItem, productID: String) {
        let sql = """
        INSERT INTO tracked_items (id, productId, name, price, unit, brand, notes, purchasedAt, isTaxable)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_text(stmt, 1, trackedItem.id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, productID.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, trackedItem.name.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_double(stmt, 4, trackedItem.price)
        sqlite3_bind_text(stmt, 5, trackedItem.unit.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 6, trackedItem.brand.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 7, trackedItem.notes.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 8, trackedItem.purchasedAt.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 9, trackedItem.isTaxable ? 1 : 0)

        stepAndFinalize(stmt)
    }

    func insertTrackedShoppingItem(_ item: TrackedShoppingItem, purchasedAt: String) -> UUID {
        let newID = UUID()

        let trackedItem = TrackedItem(
            id: newID,
            productID: item.productID,
            name: item.itemName.isEmpty ? item.productName : item.itemName,
            price: item.priceValue,
            unit: item.unit,
            brand: item.brand,
            notes: item.notes,
            purchasedAt: purchasedAt,
            isTaxable: item.taxable
        )

        insertTrackedItem(trackedItem, productID: item.productID.uuidString)
        return newID
    }

    func fetchCategoriesTree() -> [CategoryItem] {
        var result: [CategoryItem] = []

        let categorySQL = """
        SELECT id, name, icon, isExpanded
        FROM categories
        ORDER BY name;
        """

        var categoryStmt: OpaquePointer?
        sqlite3_prepare_v2(db, categorySQL, -1, &categoryStmt, nil)

        while sqlite3_step(categoryStmt) == SQLITE_ROW {
            let categoryID = string(from: categoryStmt, at: 0) ?? ""
            let name = string(from: categoryStmt, at: 1) ?? ""
            let icon = string(from: categoryStmt, at: 2) ?? ""
            let isExpanded = sqlite3_column_int(categoryStmt, 3) == 1

            let products = fetchProducts(categoryID: categoryID)

            let category = CategoryItem(
                id: UUID(uuidString: categoryID) ?? UUID(),
                name: name,
                icon: icon,
                products: products,
                isExpanded: isExpanded
            )

            result.append(category)
        }

        sqlite3_finalize(categoryStmt)
        return result
    }

    private func fetchProducts(categoryID: String) -> [ProductItem] {
        var result: [ProductItem] = []

        let sql = """
        SELECT id, name, isExpanded
        FROM products
        WHERE categoryId = ?
        ORDER BY name;
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, categoryID.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        while sqlite3_step(stmt) == SQLITE_ROW {
            let productID = string(from: stmt, at: 0) ?? ""
            let name = string(from: stmt, at: 1) ?? ""
            let isExpanded = sqlite3_column_int(stmt, 2) == 1

            let trackedItems = fetchTrackedItems(productID: productID)

            let product = ProductItem(
                id: UUID(uuidString: productID) ?? UUID(),
                name: name,
                trackedItems: trackedItems,
                isExpanded: isExpanded
            )

            result.append(product)
        }

        sqlite3_finalize(stmt)
        return result
    }

    private func fetchTrackedItems(productID: String) -> [TrackedItem] {
        var result: [TrackedItem] = []

        let sql = """
        SELECT id, name, price, unit, brand, notes, purchasedAt, isTaxable
        FROM tracked_items
        WHERE productId = ?
        ORDER BY purchasedAt DESC, name;
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, productID.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = string(from: stmt, at: 0) ?? ""
            let name = string(from: stmt, at: 1) ?? ""
            let price = sqlite3_column_double(stmt, 2)
            let unit = string(from: stmt, at: 3) ?? ""
            let brand = string(from: stmt, at: 4) ?? ""
            let notes = string(from: stmt, at: 5) ?? ""
            let purchasedAt = string(from: stmt, at: 6) ?? ""
            let isTaxable = sqlite3_column_int(stmt, 7) == 1

            let trackedItem = TrackedItem(
                id: UUID(uuidString: id) ?? UUID(),
                productID: UUID(uuidString: productID) ?? UUID(),
                name: name,
                price: price,
                unit: unit,
                brand: brand,
                notes: notes,
                purchasedAt: purchasedAt,
                isTaxable: isTaxable
            )

            result.append(trackedItem)
        }

        sqlite3_finalize(stmt)
        return result
    }

    func updateCategoryExpanded(id: UUID, isExpanded: Bool) {
        let sql = "UPDATE categories SET isExpanded = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_int(stmt, 1, isExpanded ? 1 : 0)
        sqlite3_bind_text(stmt, 2, id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        stepAndFinalize(stmt)
    }

    func updateProductExpanded(id: UUID, isExpanded: Bool) {
        let sql = "UPDATE products SET isExpanded = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_int(stmt, 1, isExpanded ? 1 : 0)
        sqlite3_bind_text(stmt, 2, id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        stepAndFinalize(stmt)
    }

    private func execute(_ sql: String) {
        var errorMessage: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &errorMessage) != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Unknown SQL error"
            fatalError(message)
        }
    }

    private func scalarInt(_ sql: String) -> Int {
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        defer { sqlite3_finalize(stmt) }

        if sqlite3_step(stmt) == SQLITE_ROW {
            return Int(sqlite3_column_int(stmt, 0))
        }

        return 0
    }

    private func tableExists(_ tableName: String) -> Bool {
        let sql = "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, tableName.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        defer { sqlite3_finalize(stmt) }

        if sqlite3_step(stmt) == SQLITE_ROW {
            return sqlite3_column_int(stmt, 0) > 0
        }

        return false
    }

    private func tableHasColumn(table: String, column: String) -> Bool {
        let sql = "PRAGMA table_info(\(table));"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        defer { sqlite3_finalize(stmt) }

        while sqlite3_step(stmt) == SQLITE_ROW {
            if let columnName = string(from: stmt, at: 1), columnName == column {
                return true
            }
        }

        return false
    }

    private func stepAndFinalize(_ stmt: OpaquePointer?) {
        if sqlite3_step(stmt) != SQLITE_DONE {
            let message = db.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "SQLite step error"
            sqlite3_finalize(stmt)
            fatalError(message)
        }
        sqlite3_finalize(stmt)
    }

    private func string(from stmt: OpaquePointer?, at index: Int32) -> String? {
        guard let cString = sqlite3_column_text(stmt, index) else { return nil }
        return String(cString: cString)
    }

    func deleteTrackedItem(id: UUID) {
        let sql = "DELETE FROM tracked_items WHERE id = ?;"
        var stmt: OpaquePointer?

        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        stepAndFinalize(stmt)

        NotificationCenter.default.post(name: .trackedItemsDidChange, object: nil)
    }

    func addCategory(name: String, icon: String) {
        let category = CategoryItem(
            name: name,
            icon: icon,
            products: []
        )

        insertCategory(category)
    }

    func addProduct(name: String, categoryID: UUID) {
        let product = ProductItem(
            name: name,
            trackedItems: []
        )

        insertProduct(product, categoryID: categoryID.uuidString)
    }

    func deleteCategory(id: UUID) {
        let sql = "DELETE FROM categories WHERE id = ?;"
        var stmt: OpaquePointer?

        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        stepAndFinalize(stmt)
    }

    func deleteProduct(id: UUID) {
        let sql = "DELETE FROM products WHERE id = ?;"
        var stmt: OpaquePointer?

        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        stepAndFinalize(stmt)
    }

    func renameCategory(id: UUID, newName: String) {
        let sql = "UPDATE categories SET name = ? WHERE id = ?;"
        var stmt: OpaquePointer?

        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, newName.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        stepAndFinalize(stmt)
    }

    func renameProduct(id: UUID, newName: String) {
        let sql = "UPDATE products SET name = ? WHERE id = ?;"
        var stmt: OpaquePointer?

        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, newName.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        stepAndFinalize(stmt)
    }
}
