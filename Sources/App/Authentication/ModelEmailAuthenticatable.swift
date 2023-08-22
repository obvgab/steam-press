////
//  6172661B-CB42-4B3A-BD57-FFD87E7C5BF0: 2:20 PM 8/18/23
//  ModelEmailAuthenticatable.swift by Gab
//  

// effectively ModelCredentialsAuthenticatable but implementing Email instead of username
import Vapor
import Fluent

public protocol ModelEmailAuthenticatable: Model, Authenticatable {
    static var emailKey: KeyPath<Self, Field<String>> { get }
    static var passwordHashKey: KeyPath<Self, Field<String>> { get }
    func verify(password: String) throws -> Bool
}

extension ModelEmailAuthenticatable {
    public static func credentialsAuthenticator(
        database: DatabaseID? = nil
    ) -> AsyncAuthenticator {
        AsyncModelEmailAuthenticator<Self>(database: database)
    }

    var _$email: Field<String> {
        self[keyPath: Self.emailKey]
    }

    var _$passwordHash: Field<String> {
        self[keyPath: Self.passwordHashKey]
    }
}

public struct ModelEmail: Content {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

private struct AsyncModelEmailAuthenticator<User>: AsyncCredentialsAuthenticator
    where User: ModelEmailAuthenticatable
{
    typealias Credentials = ModelEmail

    public let database: DatabaseID?
    
    func authenticate(credentials: ModelEmail, for request: Request) async throws {
        if let user = try await User.query(on: request.db(self.database)).filter(\._$email == credentials.email).first() {
            guard try user.verify(password: credentials.password) else {
                return
            }
            request.auth.login(user)
        }
    }
}
