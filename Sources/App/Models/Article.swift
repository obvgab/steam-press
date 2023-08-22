////
//  643F5C28-B5B4-4802-8D29-3A1509D0503B: 11:51 AM 8/13/23
//  Article.swift by Gab
//  

import Fluent

final class Article: Model {
    static let schema = "articles"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String
    //@Parent(key: "author") var author: User
    @Field(key: "path") var path: String
    @Field(key: "author") var author: String
    @Field(key: "created") var created: Date
    @Field(key: "edited") var edited: [Date] // Individual times an article was edited. Make this collapsable view
    
    init() {}
    init(id: UUID? = nil, name: String, path: String, author: String, created: Date, edited: [Date] = []) {
        self.id = id
        self.name = name
        self.path = path
        self.author = author
        self.created = created
        self.edited = edited
    }
}

extension Article {
    struct Migration: AsyncMigration {
        var name: String { "CreateArticles" }
        
        func prepare(on database: Database) async throws {
            try await database.schema("articles")
                .id()
                .field("name", .string, .required)
                .field("author", .string)//, .references("users", "id"), .required)
                .field("path", .string)
                .field("created", .date)
                .field("edited", .array(of: .date))
                .unique(on: "path")
                .create()
        }
        
        func revert(on database: Database) async throws { try await database.schema("articles").delete() }
    }
}
