//
//  UserInteractor.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import Foundation
import Combine

struct UserInteractor {
    let userRepository: UserRepository
    let userDBRepository: UserDBRepository

    func load() -> AnyPublisher<[User], Error> {
        userDBRepository
            .hasUsers()
            .flatMap { hasUsers in
                if hasUsers {
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                } else {
                    return self.fetchUsers()
                }
            }
            .flatMap { [userDBRepository] _ in
                userDBRepository.users()
            }
            .eraseToAnyPublisher()
    }

    func fetchUsers() -> AnyPublisher<Void, Error> {
        userRepository
            .fetchUsers()
            .map(\.results)
            .map { users in
                users.map(User.init)
            }
            .flatMap({ [userDBRepository] users in
                userDBRepository.store(users: users)
            })
            .eraseToAnyPublisher()
    }

    func favourite(_ user: User) -> AnyPublisher<Void, Error> {
        var user = user
        user.isFavourite.toggle()
        return userDBRepository
            .store(users: [user])
            .eraseToAnyPublisher()
    }

    func delete(_ user: User) -> AnyPublisher<Void, Error> {
        var user = user
        user.isHidden = true
        return userDBRepository
            .store(users: [user])
            .eraseToAnyPublisher()
    }
}
