////
//  643F5C28-B5B4-4802-8D29-3A1509D0503B: 11:51 AM 8/13/23
//  Article.swift by Gab
//  

import Foundation
import Fluent

final class Article: Model {
    static let schema = "articles"
    
    @ID(custom: "path", generatedBy: .user) var id: String? // Path must be unique, can be used as identifier
    @Field(key: "name") var name: String
    @Parent(key: "author") var author: User
    @Field(key: "created") var created: Date
    @Field(key: "edited") var edited: [Date] // Individual times an article was edited. Make this collapsable view
    
    init() {}
    init(id: String, name: String, authorID: User.IDValue, created: Date = Date.now, edited: [Date] = []) {
        self.id = id
        self.name = name
        self.$author.id = authorID
        self.created = created
        self.edited = edited
    }
}
