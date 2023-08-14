import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    try app.register(collections: AdminController())
}

extension Application {
    func register(collections: RouteCollection...) throws {
        for collection in collections {
            try self.register(collection: collection)
        }
    }
}
