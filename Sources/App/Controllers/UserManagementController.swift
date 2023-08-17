////
//  B1A22184-E124-463B-A6FD-6D760357D5CB: 12:59 PM 8/17/23
//  UserManagementController.swift by Gab
//  

import Foundation
import Vapor
import Fluent

struct UserManagementController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("users")
        let basicAuthRoutes = userRoutes.grouped(User.authenticator())
        let tokenAuthRoutes = userRoutes.grouped(Token.authenticator(), User.guardMiddleware())
        let adminLooseAuthRoutes = tokenAuthRoutes.grouped(UserMiddleware(permissions: [.admin], strict: false))
        
        basicAuthRoutes.post("login", use: login)
        
        // // // // // // // // // //
        // DEBUG, DELETE THIS
        userRoutes.get(use: list)
        userRoutes.post(use: create)
        
        tokenAuthRoutes.get("protected", use: protected)
        // DEBUG, DELETE THIS
        // // // // // // // // // //
    }
    
    func list(_ req: Request) async throws -> [User] {
        return try await User.query(on: req.db).all()
    }
    
    func create(_ req: Request) async throws -> User {
        print("Create request")
        let data = try req.content.decode(User.Create.self)
        print("Decoded user create")
        let passwordHash = try Bcrypt.hash(data.password)
        
        let user = User(email: data.email, name: data.name, passwordHash: passwordHash) // privlege escalation later
        try await user.save(on: req.db)
        return user
    }
    
    func login(_ req: Request) async throws -> Token {
        let user = try req.auth.require(User.self)
        let token = try user.createToken()
        try await token.save(on: req.db)
        return token
    }
    
    // // // // // // // // // // // // // // // // // // // // //
    // DEBUG, DELETE THIS
    func protected(_ req: Request) async throws -> User {
        try req.auth.require(User.self)
    }
    // DEBUG, DELETE THIS
    // // // // // // // // // // // // // // // // // // // // //
}
