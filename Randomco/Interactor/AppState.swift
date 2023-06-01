//
//  AppState.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 29/5/23.
//

import Combine
import CoreLocation

protocol AppStateInput {
    func set(_ users: [User])
    func update(_ users: [User])
}

protocol AppStateOutput {
    var users: CurrentValueSubject<[User]?, Error> { get }
    var location: CurrentValueSubject<CLLocation?, Error> { get }
}

struct AppState: AppStateInput, AppStateOutput {
    static let shared = AppState()

    var users = CurrentValueSubject<[User]?, Error>(nil)
    var location = CurrentValueSubject<CLLocation?, Error>(nil)

    func set(_ users: [User]) {
        self.users.send(users)
    }

    func update(_ users: [User]) {
        guard var _users = self.users.value else { return }

        for user in users {
            guard let userIndex = _users.firstIndex(where: { $0 == user }) else { continue }
            _users.replaceSubrange(userIndex...userIndex, with: [user])
        }

        self.users.send(_users)
    }
}
