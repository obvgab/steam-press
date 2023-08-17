////
//  60DE3953-227F-4B53-90B0-D964CEA4D51C: 12:40 PM 8/17/23
//  UserMiddleware.swift by Gab
//  

import Foundation
import Vapor

struct UserMiddleware: AsyncMiddleware {
    let permissions: Set<User.Privilege>
    let strict: Bool
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.auth.get(User.self), strict ? Set(user.privileges) == permissions : permissions.map({ p in user.privileges.contains(p) }).reduce(true, { p, c in p && c }) else {
            throw Abort(.unauthorized)
        }
        
        return try await next.respond(to: request)
    }
}
