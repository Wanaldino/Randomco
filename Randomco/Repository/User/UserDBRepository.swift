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

    func users() -> AnyPublisher<[User], Error> {
        let request = UserMO.users()
        return persistentStore
            .fetch(request)
            .flatMap({ userMO in
                persistentStore.map(values: userMO) { value in
                    guard let user = User(from: value) else { throw NSError(domain: "", code: 0) }
                    return user
                }
            })
            .eraseToAnyPublisher()
    }

    func store(users: [User]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update({ context in
                try users.forEach { user in
                    let userMO: UserMO
                    let exists = UserMO.exists(user: user)
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

    static func users() -> NSFetchRequest<UserMO> {
        let request = newFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name.first", ascending: true)]
        request.fetchBatchSize = 10
        return request
    }

    static func exists(user: User) -> NSFetchRequest<UserMO> {
        let request = justOne()
        request.predicate = NSPredicate(format: "email = %@", user.email)
        return request
    }
}
