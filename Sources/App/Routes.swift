import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collections: AdminController())
}

extension Application {
    func register(collections: RouteCollection...) throws {
        for collection in collections {
            try self.register(collection: collection)
        }
    }
}
