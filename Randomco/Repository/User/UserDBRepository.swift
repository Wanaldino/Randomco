//
//  UserDBRepository.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 27/5/23.
//

import CoreData
import Combine

struct UserDBRepository {
    let persistentStore: PersistentStore = CoreDataStack()

    func hasUsers() -> AnyPublisher<Bool, Error> {
        let request = UserMO.justOne()
        return persistentStore
            .count(request)
            .map({ $0 > 0 })
            .eraseToAnyPublisher()
    }

    func _users(for request: NSFetchRequest<UserMO>) -> AnyPublisher<[User], Error> {
        return persistentStore
            .fetch(request)
            .flatMap({ userMO in
                persistentStore.map(values: userMO) { value in
                    User(from: value)
                }
            })
            .eraseToAnyPublisher()
    }

    func allUsers() -> AnyPublisher<[User], Error> {
        _users(for: UserMO.allUsers())
    }

    func users() -> AnyPublisher<[User], Error> {
        _users(for: UserMO.users())
    }

    func user(_ user: User) -> AnyPublisher<User, Error> {
        let request = UserMO.user(user)
        return persistentStore
            .fetch(request)
            .flatMap({ userMO in
                persistentStore.map(values: userMO) { value in
                    User(from: value)
                }
            })
            .flatMap({ users in
                if let user = users.first {
                    return Just(user).setFailureType(to: Error.self).eraseToAnyPublisher()
                } else {
                    return Fail<User, Error>(error: NSError(domain: "", code: 2)).eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }

    func store(users: [User]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update({ context in
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
            })
            .eraseToAnyPublisher()
    }
}

extension UserMO {
    static func justOne() -> NSFetchRequest<UserMO> {
        let request = newFetchRequest()
        request.fetchLimit = 1
        return request
    }

    static func allUsers() -> NSFetchRequest<UserMO> {
        newFetchRequest()
    }

    static func users() -> NSFetchRequest<UserMO> {
        let request = newFetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name.first", ascending: true),
            NSSortDescriptor(key: "name.last", ascending: true)
        ]
        request.predicate = NSPredicate(format: "isHidden = false")
        request.fetchBatchSize = 10
        return request
    }

    static func user(_ user: User) -> NSFetchRequest<UserMO> {
        let request = justOne()
        request.predicate = NSPredicate(format: "email = %@", user.email)
        return request
    }
}
