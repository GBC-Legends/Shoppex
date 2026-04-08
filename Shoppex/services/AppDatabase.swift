import Foundation
import GRDB
import SQLite3

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

struct Category: Codable, FetchableRecord, PersistableRecord {
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

struct Supply: Codable, FetchableRecord, PersistableRecord {
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

struct Product: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var supplyId: String
    var name: String
    var price: Double
    var unit: String
    var brand: String
    var notes: String

    init(supplyId: String, name: String, price: Double, unit: String, brand: String, notes: String = "") {
        self.id = UUID().uuidString
        self.supplyId = supplyId
        self.name = name
        self.price = price
        self.unit = unit
        self.brand = brand
        self.notes = notes
    }
}

enum AppDatabase {
    static func setup(_ dbQueue: DatabaseQueue) throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("createCategorySupplyProductTables") { db in
            try db.create(table: "categories") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("icon", .text).notNull()
                t.column("isExpanded", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: "supplies") { t in
                t.column("id", .text).primaryKey()
                t.column("categoryId", .text)
                    .notNull()
                    .references("categories", onDelete: .cascade, onUpdate: .cascade)
                t.column("name", .text).notNull()
                t.column("isExpanded", .boolean).notNull().defaults(to: false)
            }

            try db.create(index: "idx_supplies_categoryId", on: "supplies", columns: ["categoryId"])

            try db.create(table: "products") { t in
                t.column("id", .text).primaryKey()
                t.column("supplyId", .text)
                    .notNull()
                    .references("supplies", onDelete: .cascade, onUpdate: .cascade)
                t.column("name", .text).notNull()
                t.column("price", .double).notNull()
                t.column("unit", .text).notNull()
                t.column("brand", .text).notNull()
                t.column("notes", .text).notNull().defaults(to: "")
            }

            try db.create(index: "idx_products_supplyId", on: "products", columns: ["supplyId"])
        }

        migrator.registerMigration("seedInitialData") { db in
            let existingCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM categories") ?? 0
            guard existingCount == 0 else { return }

            try seed(db)
        }

        try migrator.migrate(dbQueue)
    }

    private static func seed(_ db: Database) throws {
        let dairyId = UUID()
        let bakeryId = UUID()
        let produceId = UUID()
        let cleaningId = UUID()
        let medicationId = UUID()

        let categories = [
            Category(id: dairyId.uuidString, name: "Dairy", icon: "drop.fill"),
            Category(id: bakeryId.uuidString, name: "Bakery", icon: "flame.fill"),
            Category(id: produceId.uuidString, name: "Produce", icon: "leaf.fill"),
            Category(id: cleaningId.uuidString, name: "Cleaning", icon: "sparkles"),
            Category(id: medicationId.uuidString, name: "Medication", icon: "cross.fill")
        ]

        for var category in categories {
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

        let supplies = [
            Supply(id: milkId.uuidString, categoryId: dairyId.uuidString, name: "Milk"),
            Supply(id: cheeseId.uuidString, categoryId: dairyId.uuidString, name: "Cheese"),
            Supply(id: sourCreamId.uuidString, categoryId: dairyId.uuidString, name: "Sour Cream"),

            Supply(id: breadId.uuidString, categoryId: bakeryId.uuidString, name: "Bread"),
            Supply(id: bagelsId.uuidString, categoryId: bakeryId.uuidString, name: "Bagels"),

            Supply(id: applesId.uuidString, categoryId: produceId.uuidString, name: "Apples"),
            Supply(id: bananasId.uuidString, categoryId: produceId.uuidString, name: "Bananas"),

            Supply(id: detergentId.uuidString, categoryId: cleaningId.uuidString, name: "Detergent"),
            Supply(id: dishSoapId.uuidString, categoryId: cleaningId.uuidString, name: "Dish Soap"),
            Supply(id: paperTowelsId.uuidString, categoryId: cleaningId.uuidString, name: "Paper Towels"),

            Supply(id: painReliefId.uuidString, categoryId: medicationId.uuidString, name: "Pain Relief")
        ]

        for var supply in supplies {
            try supply.insert(db)
        }

        let products = [
            Product(supplyId: milkId.uuidString, name: "Whole Milk 1L", price: 4.29, unit: "1L", brand: "Natrel", notes: "Refrigerated"),
            Product(supplyId: milkId.uuidString, name: "2% Milk 2L", price: 6.49, unit: "2L", brand: "Beatrice", notes: "Refrigerated"),
            Product(supplyId: milkId.uuidString, name: "Skim Milk 1L", price: 3.99, unit: "1L", brand: "Lactantia", notes: "Refrigerated"),

            Product(supplyId: cheeseId.uuidString, name: "Cheddar Block 400g", price: 8.99, unit: "400g", brand: "Black Diamond", notes: "Refrigerated"),
            Product(supplyId: cheeseId.uuidString, name: "Mozzarella 200g", price: 5.49, unit: "200g", brand: "Saputo", notes: "Refrigerated"),

            Product(supplyId: sourCreamId.uuidString, name: "Sour Cream 500mL", price: 3.79, unit: "500mL", brand: "Astro", notes: "Refrigerated"),

            Product(supplyId: breadId.uuidString, name: "White Sandwich Bread", price: 3.49, unit: "675g", brand: "Wonder"),
            Product(supplyId: breadId.uuidString, name: "Whole Wheat Loaf", price: 4.29, unit: "600g", brand: "Dempster's", notes: "High fibre"),

            Product(supplyId: bagelsId.uuidString, name: "Plain Bagels", price: 4.49, unit: "6 pack", brand: "Montreal Style"),

            Product(supplyId: applesId.uuidString, name: "Green Apples", price: 7.99, unit: "bag 1.5kg", brand: "Local Farm", notes: "Granny Smith"),
            Product(supplyId: applesId.uuidString, name: "Gala Apples", price: 6.99, unit: "bag 1.5kg", brand: "Local Farm"),

            Product(supplyId: bananasId.uuidString, name: "Bananas", price: 2.49, unit: "bunch", brand: "Chiquita"),

            Product(supplyId: detergentId.uuidString, name: "Laundry Pods 42ct", price: 15.00, unit: "42 count", brand: "Tide"),
            Product(supplyId: detergentId.uuidString, name: "Liquid Detergent 1.47L", price: 12.99, unit: "1.47L", brand: "Gain", notes: "Fresh scent"),

            Product(supplyId: dishSoapId.uuidString, name: "Dish Soap 532mL", price: 4.99, unit: "532mL", brand: "Dawn", notes: "Original"),

            Product(supplyId: paperTowelsId.uuidString, name: "Paper Towels 6-Roll", price: 8.99, unit: "6 rolls", brand: "Bounty", notes: "Select-A-Size"),

            Product(supplyId: painReliefId.uuidString, name: "Ibuprofen 200mg 100ct", price: 11.99, unit: "100 tablets", brand: "Advil", notes: "Take with food"),
            Product(supplyId: painReliefId.uuidString, name: "Acetaminophen 500mg", price: 9.49, unit: "100 tablets", brand: "Tylenol")
        ]

        for var product in products {
            try product.insert(db)
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

        let suppliesSQL = """
        CREATE TABLE IF NOT EXISTS supplies (
            id TEXT PRIMARY KEY,
            categoryId TEXT NOT NULL,
            name TEXT NOT NULL,
            isExpanded INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
        );
        """

        let productsSQL = """
        CREATE TABLE IF NOT EXISTS products (
            id TEXT PRIMARY KEY,
            supplyId TEXT NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            unit TEXT NOT NULL,
            brand TEXT NOT NULL,
            notes TEXT NOT NULL DEFAULT '',
            FOREIGN KEY (supplyId) REFERENCES supplies(id) ON DELETE CASCADE
        );
        """

        execute(categoriesSQL)
        execute(suppliesSQL)
        execute(productsSQL)

        execute("CREATE INDEX IF NOT EXISTS idx_supplies_categoryId ON supplies(categoryId);")
        execute("CREATE INDEX IF NOT EXISTS idx_products_supplyId ON products(supplyId);")
    }

    private func preseedIfNeeded() {
        let count = scalarInt("SELECT COUNT(*) FROM categories LIMIT 1;")
        guard count == 0 else { return }

        let categories = CategoryItem.sampleData

        for category in categories {
            insertCategory(category)

            for supply in category.items {
                insertSupply(supply, categoryID: category.id.uuidString)

                for product in supply.products {
                    insertProduct(product, supplyID: supply.id.uuidString)
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

    func insertSupply(_ supply: SupplyItem, categoryID: String) {
        let sql = """
        INSERT INTO supplies (id, categoryId, name, isExpanded)
        VALUES (?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_text(stmt, 1, supply.id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, categoryID.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, supply.name.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 4, supply.isExpanded ? 1 : 0)

        stepAndFinalize(stmt)
    }

    func insertProduct(_ product: ProductDetail, supplyID: String) {
        let sql = """
        INSERT INTO products (id, supplyId, name, price, unit, brand, notes)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        sqlite3_bind_text(stmt, 1, product.id.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, supplyID.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, product.name.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_double(stmt, 4, product.price)
        sqlite3_bind_text(stmt, 5, product.unit.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 6, product.brand.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 7, product.notes.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        stepAndFinalize(stmt)
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

            let supplies = fetchSupplies(categoryID: categoryID)

            let category = CategoryItem(
                id: UUID(uuidString: categoryID) ?? UUID(),
                name: name,
                icon: icon,
                items: supplies,
                isExpanded: isExpanded
            )

            result.append(category)
        }

        sqlite3_finalize(categoryStmt)
        return result
    }

    private func fetchSupplies(categoryID: String) -> [SupplyItem] {
        var result: [SupplyItem] = []

        let sql = """
        SELECT id, name, isExpanded
        FROM supplies
        WHERE categoryId = ?
        ORDER BY name;
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, categoryID.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        while sqlite3_step(stmt) == SQLITE_ROW {
            let supplyID = string(from: stmt, at: 0) ?? ""
            let name = string(from: stmt, at: 1) ?? ""
            let isExpanded = sqlite3_column_int(stmt, 2) == 1

            let products = fetchProducts(supplyID: supplyID)

            let supply = SupplyItem(
                id: UUID(uuidString: supplyID) ?? UUID(),
                name: name,
                products: products,
                isExpanded: isExpanded
            )

            result.append(supply)
        }

        sqlite3_finalize(stmt)
        return result
    }

    private func fetchProducts(supplyID: String) -> [ProductDetail] {
        var result: [ProductDetail] = []

        let sql = """
        SELECT id, name, price, unit, brand, notes
        FROM products
        WHERE supplyId = ?
        ORDER BY name;
        """

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, supplyID.cString(using: .utf8), -1, SQLITE_TRANSIENT)

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = string(from: stmt, at: 0) ?? ""
            let name = string(from: stmt, at: 1) ?? ""
            let price = sqlite3_column_double(stmt, 2)
            let unit = string(from: stmt, at: 3) ?? ""
            let brand = string(from: stmt, at: 4) ?? ""
            let notes = string(from: stmt, at: 5) ?? ""

            let product = ProductDetail(
                id: UUID(uuidString: id) ?? UUID(),
                name: name,
                price: price,
                unit: unit,
                brand: brand,
                notes: notes
            )

            result.append(product)
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

    func updateSupplyExpanded(id: UUID, isExpanded: Bool) {
        let sql = "UPDATE supplies SET isExpanded = ? WHERE id = ?;"
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


}
