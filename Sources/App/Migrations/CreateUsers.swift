////
//  F77F4095-790F-4DBC-9A2C-56C10014B7FB: 12:28 PM 8/17/23
//  CreateUsers.swift by Gab
//  

import Foundation
import Fluent

extension User {
    struct Migration: AsyncMigration {
        var name: String { "CreateUsers" }
        
        func prepare(on database: Database) async throws {
            try await database.schema("users")
                .id()
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("password", .string, .required)
                .field("privileges", .array(of: .string)) // we can change to .enum later
                .unique(on: "email")
                .create()
        }
        
        func revert(on database: Database) async throws { try await database.schema("users").delete() }
    }
}

extension Token {
    struct Migration: AsyncMigration {
        var name: String { "CreateTokens" }
        
        func prepare(on database: Database) async throws {
            try await database.schema("tokens")
                .id()
                .field("value", .string, .required)
                .field("user", .uuid, .references("users", "id"))
                .field("created", .date, .required)
                .field("revoked", .bool, .required)
                .unique(on: "value")
                .create()
        }
        
        func revert(on database: Database) async throws { try await database.schema("tokens").delete() }
    }
}
