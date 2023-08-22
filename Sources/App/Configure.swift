import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import JWT

public func configure(_ app: Application) async throws {
    // Stateful configuration
    try app.databases.use(.postgres(
        url: Environment.get("DATABASE_URL") ?? "postgres://postgres:steampress*@localhost:5432/steampress"
    ), as: .psql)
    app.views.use(.leaf)

    // Database migrations
    app.migrations.add(User.Migration())
    app.migrations.add(Article.Migration())
    
    try app.jwt.signers.use(jwksJSON: String(contentsOfFile: app.directory.workingDirectory + "keypair.jwks"))
    
    try routes(app)
}

extension JWKIdentifier {
    static let `public` = JWKIdentifier(string: "public")
    static let `private` = JWKIdentifier(string: "private")
}
