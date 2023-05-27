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

    func fetchUsers() -> AnyPublisher<[User], Error> {
        userRepository
            .fetchUsers()
            .map(\.results)
            .map { $0.map(User.init) }
            .eraseToAnyPublisher()
    }
}
