//
//  AppState.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 29/5/23.
//

import SwiftUI
import Combine

protocol AppStateInput {
    func setUsers(users: [User])
}

protocol AppStateOutput {
    var users: CurrentValueSubject<[User], Never> { get }
}

struct AppState: AppStateInput, AppStateOutput {
    static let shared = AppState()

    var users = CurrentValueSubject<[User], Never>([])

    @MainActor
    func setUsers(users: [User]) {
        self.users.send(users)
    }
}
