//
//  UserDBRepository.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 27/5/23.
//

import CoreData

struct UserDBRepository {
    let persistentStore: PersistentStore

    init(persistentStore: PersistentStore = CoreDataStack.shared) {
        self.persistentStore = persistentStore
    }

    func hasUsers() async throws -> Bool {
        let request = UserMO.justOne()
        let count = try await persistentStore.count(request)
        return count > 0
    }

    func users() async throws -> [User] {
        let request = UserMO.users()
        let usersMO = try await persistentStore.fetch(request)
        let users = try await persistentStore.map(values: usersMO) { value in
            User(from: value)
        }
        return users
    }

    func user(_ user: User) async throws -> User {
        let request = UserMO.user(user)
        let userMO = try await persistentStore.fetch(request)
        let user = try await persistentStore.map(values: userMO) { user in
            User(from: user)
        }
        if let user = user.first {
            return user
        } else {
            throw NSError(domain: "", code: 1)
        }
    }

    func store(users: [User]) async throws {
        try await persistentStore.update { context in
            try users.forEach { user in
                let userMO: UserMO
                let exists = UserMO.user(user)
                if let _userMO = try context.fetch(exists).first {
                    userMO = _userMO
                } else {
                    userMO = UserMO.insertNew(in: context)
                }
                userMO.store(user: user)
            }
        }
    }
}

extension UserMO {
    static func justOne() -> NSFetchRequest<UserMO> {
        let request = newFetchRequest()
        request.fetchLimit = 1
        return request
    }

    static func users() -> NSFetchRequest<UserMO> {
        newFetchRequest()
    }

    static func user(_ user: User) -> NSFetchRequest<UserMO> {
        let request = justOne()
        request.predicate = NSPredicate(format: "email = %@", user.email)
        return request
    }
}
