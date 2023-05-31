//
//  AppState.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 29/5/23.
//

import SwiftUI
import Combine
import CoreLocation

protocol AppStateInput {
    func setUsers(users: [User])
}

protocol AppStateOutput {
    var users: CurrentValueSubject<[User]?, Error> { get }
    var location: CurrentValueSubject<CLLocation?, Error> { get }
}

struct AppState: AppStateInput, AppStateOutput {
    static let shared = AppState()

    var users = CurrentValueSubject<[User]?, Error>(nil)
    var location = CurrentValueSubject<CLLocation?, Error>(nil)

    @MainActor
    func setUsers(users: [User]) {
        self.users.send(users)
    }
}
