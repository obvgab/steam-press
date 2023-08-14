////
//  1A409C5E-919A-4671-AB79-AE35B3BD4823: 8:16 PM 8/13/23
//  Account.swift by Gab
//

import Foundation
import Fluent
import Vapor

protocol Tokenable {
    associatedtype Token
    func generateToken() throws -> Token
}


// MARK: Admins
/// Admins have full control over the Steam Press content
final class Admin: Model, Content {
    static let schema = "admins"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "username") var username: String
    @Field(key: "password") var password: String
    
    init() {}
    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}

extension Admin {
    struct Create: Content, Validatable {
        var username: String
        var password: String
        var repeatPassword: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("username", as: String.self, is: !.empty)
            validations.add("password", as: String.self, is: .count(8...64))
        }
    }
}

extension Admin: ModelAuthenticatable {
    static let usernameKey = \Admin.$username
    static let passwordHashKey = \Admin.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension Admin: Tokenable {
    typealias Token = AdminToken
    
    func generateToken() throws -> AdminToken {
        try .init(
            value: [UInt8].random(count: 16).base64, // 128 bit base64
            admin: self.requireID()
        )
    }
}

final class AdminToken: Model, Content {
    static let schema = "admin_tokens"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "value") var value: String
    @Parent(key: "admin") var admin: Admin
    @Field(key: "created") var created: Date
    
    init() {}
    init(id: UUID? = nil, created: Date = Date.now, value: String, admin: Admin.IDValue) {
        self.id = id
        self.value = value
        self.$admin.id = admin
        self.created = created
    }
}

extension AdminToken: ModelTokenAuthenticatable {
    static let valueKey = \AdminToken.$value
    static let userKey = \AdminToken.$admin
    
    var isValid: Bool { return created.timeIntervalSinceNow < 60 * 60 * 25 * 7 * -1 } // Make sure the token is less than a week old
}

// MARK: Editors (optional)
final class Editor {}
final class EditorToken {}

// MARK: Reader (optional)
final class Reader {}
final class ReaderToken {}
