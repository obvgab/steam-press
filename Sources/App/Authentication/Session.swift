////
//  812320CC-762E-456E-92C5-08AAF6B4D1EF: 1:07 PM 8/18/23
//  Session.swift by Gab
//  

import Vapor
import JWT

struct SessionToken: Content, Authenticatable, JWTPayload {
    var expiration: ExpirationClaim = ExpirationClaim(value: Date().addingTimeInterval(60*30)) // 30 minute JWT sessions, change this later maybe?
    var userId: UUID
    
    init(user: User) throws { self.userId = try user.requireID() }
    func verify(using signer: JWTSigner) throws { try expiration.verifyNotExpired() }
    func asResponse(_ req: Request) throws -> Self.Response { try Response(token: req.jwt.sign(self)) }
    
    struct Response: Content {
        var token: String
    }
}
