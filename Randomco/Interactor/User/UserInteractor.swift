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
    let appState: AppState

    init(
        userRepository: UserRepository = UserRepository(),
        userDBRepository: UserDBRepository = UserDBRepository(),
        appState: AppState = AppState.defaultValue
    ) {
        self.userRepository = userRepository
        self.userDBRepository = userDBRepository
        self.appState = appState
    }

    func load() async throws {
        if try await userDBRepository.hasUsers() == false {
            try await fetchUsers()
        }

        let users = try await userDBRepository.users()
        await appState.setUsers(users: users)
    }

    func loadFavourites() async throws {
        let users = try await userDBRepository.favouriteUsers()
        await appState.setFavouriteUsers(users: users)
    }

    func fetchUsers() async throws {
        let usersResponse = try await userRepository.fetchUsers()
        let fetchedUsers = usersResponse.results.map(User.init)
        let storedUsers = try await userDBRepository.allUsers()

        var users = [User]()
        fetchedUsers.forEach { user in
            if let storedUser = storedUsers.first(where: { $0.id == user.id }) {
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
        try await load()
        try await loadFavourites()
    }

    func delete(_ user: User) async throws {
        var user = user
        user.isHidden = true
        try await userDBRepository.store(users: [user])
        try await load()
    }
}
