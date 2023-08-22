import Fluent
import Vapor
import Markdown // temp

func routes(_ app: Application) throws {
    app.get { req in // temp
        return try await req.view.render("markdown", ["md": HTMLFormatter.format(Document(parsing: String(contentsOfFile: app.directory.viewsDirectory + "test.md")))])
    }
    
    try app.register(collections: UserManagementController())
}

extension Application {
    func register(collections: RouteCollection...) throws {
        for collection in collections {
            try self.register(collection: collection)
        }
    }
}
