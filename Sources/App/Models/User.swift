////
//  AB4A5D5E-03AD-48C6-850E-2B8213844C2D: 9:11 AM 8/18/23
//  User.swift by Gab
//  

import Vapor
import Fluent
import JWT

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "email") var email: String
    @Field(key: "fullname") var fullname: String // can change this to a tuple eventually, var name: (first: String, last: String)
    @Field(key: "password") var password: String // HASH
    
    init() {}
    init(id: UUID? = nil, email: String, fullname: String, password: String) {
        self.id = id
        self.email = email
        self.fullname = fullname
        self.password = password
    }
}

extension User: ModelEmailAuthenticatable {
    static let emailKey = \User.$email
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool { try Bcrypt.verify(password, created: self.password) }
}

extension User {
    struct Create: Content {
        var email: String
        var fullname: String
        var password: String
    }
}

extension User {
    struct Migration: AsyncMigration {
        var name: String { "CreateUsers" }
        
        func prepare(on database: Database) async throws {
            try await database.schema("users")
                .id()
                .field("fullname", .string, .required)
                .field("email", .string, .required)
                .field("password", .string, .required)
                .unique(on: "email")
                .create()
        }
        
        func revert(on database: Database) async throws { try await database.schema("users").delete() }
    }
}
