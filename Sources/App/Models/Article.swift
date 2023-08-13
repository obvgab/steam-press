////
//  643F5C28-B5B4-4802-8D29-3A1509D0503B: 11:51 AM 8/13/23
//  Article.swift by Gab
//  

import Foundation
import Fluent

final class Article: Model {
    static let schema = "articles"
    
    @ID(custom: "path", generatedBy: .user) // Path must be unique, can be used as identifier
    var id: String?
    
    @Field(key: "name")
    var name: String
    @Field(key: "author")
    var author: String
    @Field(key: "created")
    var created: Date
    @Field(key: "edited")
    var edited: [Date] // Individual times an article was edited. Make this collapsable view
    
    init(id: String, name: String, author: String, created: Date = Date.now, edited: [Date] = []) {
        self.id = id
        self.name = name
        self.author = author
        self.created = created
        self.edited = edited
    }
    init() {}
}
