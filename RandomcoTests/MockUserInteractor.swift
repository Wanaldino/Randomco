//
//  MockUserInteractor.swift
//  RandomcoTests
//
//  Created by Carlos Martinez Medina on 30/5/23.
//

import Foundation
@testable import Randomco

class MockUserInteractor: UserInteractor {
    var didLoad = false
    var didFetch = false
    var didFavourite = false
    var didDelete = false

    func load() async throws {
        didLoad = true
    }

    func fetch() async throws {
        didFetch = true
    }

    func favourite(_ user: Randomco.User) async throws {
        didFavourite = true
    }

    func delete(_ user: Randomco.User) async throws {
        didDelete = true
    }
}
