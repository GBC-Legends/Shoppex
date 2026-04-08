import Foundation
import GRDB

final class DB {
    static let shared = DB()
    let dbQueue: DatabaseQueue

    private init() {
        let url = try! FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Shoppex.sqlite")

        dbQueue = try! DatabaseQueue(path: url.path)
    }
}
