////
//  CCCE1342-1908-4ADF-A0A8-620F203D9354: 10:02 AM 8/14/23
//  AccountAction.swift by Gab
//  

import Foundation
import Fluent
import Vapor

// MARK: Admins
struct AdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let admin = routes.grouped("admin")
        let adminProtected = admin.grouped(Admin.authenticator())
        let adminTokenProtected = admin.grouped(AdminToken.authenticator())
        
        admin.post(use: postAdmin)
        adminProtected.post("login", use: postLoginAdmin)
        adminTokenProtected.get(use: getAdmin) // TEMP
        admin.get("login", use: getLoginAdmin)
    }
    
    func postAdmin(req: Request) async throws -> Admin { // First admin account must be manually added
        try Admin.Create.validate(content: req)
        let instance = try req.content.decode(Admin.Create.self)
        guard instance.password == instance.repeatPassword else { throw Abort(.expectationFailed, reason: "Mismatched passwords") }
        
        let admin = try Admin(username: instance.username, password: Bcrypt.hash(instance.password))
        try await admin.save(on: req.db)
        return admin
    }
    
    func postLoginAdmin(req: Request) async throws -> AdminToken {
        let admin = try req.auth.require(Admin.self)
        let token = try admin.generateToken()
        
        try await token.save(on: req.db)
        return token
    }
    
    func getAdmin(req: Request) async throws -> String { // TEMP
        try req.auth.require(Admin.self)
        return "Admin authed"
    }
    
    func getLoginAdmin(req: Request) async throws -> String { // TEMP LOGIN PAGE
        return "Login page"
    }
}
