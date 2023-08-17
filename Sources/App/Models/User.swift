////
//  BAE7DAF3-E383-459F-8EC5-0EA44112022C: 12:02 PM 8/17/23
//  User.swift by Gab
//  

import Foundation
import Vapor
import Fluent

// MARK: User Model
final class User: Model, Content, ModelAuthenticatable {
    static let schema = "users"
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash
    
    @ID(key: .id) var id: UUID?
    @Field(key: "email") var email: String
    @Field(key: "name") var name: String
    @Field(key: "password") var passwordHash: String // implement passkeys
    @Field(key: "privileges") var privileges: [User.Privilege]
    
    enum Privilege: String, Content { // privileges, extendable
        case normal // default
        case edit // editoral
        case create // writing
        case admin // server changes
        case debug // for developing
    }
    
    init() {}
    init(id: UUID? = nil, name: String, passwordHash: String, privileges: [User.Privilege] = .Preset.READER) {
        self.id = id
        self.email = email
        self.name = name
        self.passwordHash = passwordHash
        self.privileges = privileges
    }
    
    func verify(password: String) throws -> Bool { try Bcrypt.verify(password, created: passwordHash) }
}

extension Array where Element == User.Privilege {
    enum Preset { // preset namespace, extendable
        static let READER = [User.Privilege.normal]
        static let EDITOR = [User.Privilege.normal, User.Privilege.edit]
        static let WRITER = [User.Privilege.normal, User.Privilege.edit, User.Privilege.create]
        static let MANAGER = [User.Privilege.normal, User.Privilege.admin]
        static let DEVELOPER = [User.Privilege.normal, User.Privilege.debug]
        static let ADMIN = [User.Privilege.normal, User.Privilege.edit, User.Privilege.create, User.Privilege.admin, User.Privilege.debug]
    }
}

extension User {
    func createToken() throws -> Token { try .init(value: [UInt8].random(count: 32).base64, userID: self.requireID()) }
}

// MARK: Token Holding
final class Token: Model, Content, ModelTokenAuthenticatable {
    static let schema = "tokens"
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    
    @ID(key: .id) var id: UUID?
    @Field(key: "value") var value: String
    @Parent(key: "user") var user: User
    @Field(key: "created") var created: Date
    @Field(key: "revoked") var revoked: Bool
    var isValid: Bool { created.timeIntervalSinceNow * -1 > 60 * 60 * 24 * 7 && !revoked }
    
    init() {}
    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
        self.created = Date.now
        self.revoked = false
    }
}
