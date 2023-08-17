import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.databases.use(.postgres(
        url: Environment.get("DATABASE_URL") ?? "postgres://postgres:steampress*@localhost:5432/steampress"
    ), as: .psql)

    app.migrations.add(User.Migration())
    app.migrations.add(Article.Migration())
    app.migrations.add(Token.Migration())

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
