////
//  D8573DB7-7F8A-4BBD-8A9E-ACA34318B11C: 2:34 PM 8/18/23
//  UserManagement.swift by Gab
//  

import Vapor

struct UserManagementController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let user = routes.grouped("user")
        let basicAuth = user.grouped(User.credentialsAuthenticator(), User.guardMiddleware())
        let sessionAuth = user.grouped(SessionToken.authenticator(), SessionToken.guardMiddleware())
        
        // TEMP
        user.get(use: index)
        user.post(use: create)
        
        basicAuth.post("login", use: login)
        sessionAuth.get("secure", use: secure)
    }
    
    func index(_ req: Request) async throws -> View { return try await req.view.render("login") }
    func login(_ req: Request) async throws -> SessionToken.Response { return try SessionToken(user: try req.auth.require(User.self)).asResponse(req) }
    func secure(_ req: Request) async throws -> HTTPStatus { let _ = try req.auth.require(SessionToken.self); return .ok }
    
    // TEMP
    func create(_ req: Request) async throws -> User {
        let create = try req.content.decode(User.Create.self)
        let user = User(email: create.email, fullname: create.fullname, password: try Bcrypt.hash(create.password))
        try await user.create(on: req.db)
        return user
    }
}
