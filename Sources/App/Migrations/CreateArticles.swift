////
//  A833C435-9E1D-483B-86E1-4CDBDCBE96C1: 12:03 PM 8/13/23
//  CreateArticles.swift by Gab
//

import Foundation
import Fluent

struct CreateArticles: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("articles")
            .id()
            .field("name", .string)
            .field("author", .string)
            .field("created", .date)
            .field("edited", .array(of: .date))
            .create()
    }

    func revert(on database: Database) async throws { // purge articles
        try await database.schema("articles").delete()
    }
}
