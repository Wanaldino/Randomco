//
//  AppState.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 29/5/23.
//

import SwiftUI
import Combine

struct AppState {
    var users = CurrentValueSubject<[User], Never>([])
    var favouriteUsers = CurrentValueSubject<[User], Never>([])

    @MainActor
    func setUsers(users: [User]) {
        self.users.send(users)
    }

    @MainActor
    func setFavouriteUsers(users: [User]) {
        self.favouriteUsers.send(users)
    }
}
