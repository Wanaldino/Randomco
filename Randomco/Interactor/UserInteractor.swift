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

    func fetchUsers() -> AnyPublisher<UserListResponse, Error> {
        userRepository.fetchUsers()
    }
}
