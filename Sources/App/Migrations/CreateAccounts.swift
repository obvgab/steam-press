////
//  8F7A5440-F2FB-4CA3-9EC6-27ED3D99F5E3: 8:21 PM 8/13/23
//  CreateAccounts.swift by Gab
//  

import Foundation
import Fluent

// MARK: Admins
extension Admin {
    struct Migration: AsyncMigration {
        var name: String { "CreateAdmins" }
        
        func prepare(on database: Database) async throws {
            try await database.schema("admins")
                .id()
                .field("username", .string)
                .field("password", .string)
                .unique(on: "username")
                .create()
        }
        
        func revert(on database: Database) async throws { // purge accounts
            try await database.schema("admins").delete()
        }
    }
}

extension AdminToken {
    struct Migration: AsyncMigration {
        var name: String { "CreateAdminTokens" }
        
        func prepare(on database: Database) async throws {
            try await database.schema("admin_tokens")
                .id()
                .field("value", .string)
                .field("admin", .uuid, .references("admins", "id"))
                .unique(on: "value")
                .create()
        }
        
        func revert(on database: Database) async throws { // purge tokens
            try await database.schema("admin_tokens").delete()
        }
    }
}

// MARK: Editors (optional)
extension Editor {}
extension EditorToken {}

// MARK: Reader (optional)
extension Reader {}
extension ReaderToken {}
