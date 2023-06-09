//
//  UserInteractor.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import Foundation
import Combine

protocol UserInteractor {
    func load() async throws
    func fetch() async throws
    func favourite(_ user: User) async throws
    func delete(_ user: User) async throws
}

class DefaultUserInteractor: UserInteractor {
    let userRepository: UserRepository
    let userDBRepository: UserDBRepository
    let appState: AppState

    init(
        userRepository: UserRepository = UserRepository(),
        userDBRepository: UserDBRepository = UserDBRepository(),
        appState: AppState = .shared
    ) {
        self.userRepository = userRepository
        self.userDBRepository = userDBRepository
        self.appState = appState
    }

    func load() async throws {
        guard try await userDBRepository.hasUsers() else {
            return try await fetch()
        }

        let users = try await userDBRepository.users()
        appState.set(users)
    }

    func fetch() async throws {
        let usersResponse = try await userRepository.fetchUsers()
        let fetchedUsers = usersResponse.results.map(User.init)
        let storedUsers = try await userDBRepository.users()

        var users = [User]()
        fetchedUsers.forEach { user in
            if let storedUser = storedUsers.first(where: { $0 == user }) {
                var user = user
                user.isHidden = storedUser.isHidden
                user.isFavourite = storedUser.isFavourite
                users.append(user)
            } else {
                users.append(user)
            }
        }
        try await userDBRepository.store(users: users)
        try await load()
    }

    func favourite(_ user: User) async throws {
        var user = user
        user.isFavourite.toggle()
        try await userDBRepository.store(users: [user])
        appState.update([user])
    }

    func delete(_ user: User) async throws {
        var user = user
        user.isHidden = true
        try await userDBRepository.store(users: [user])
        appState.update([user])
    }
}
