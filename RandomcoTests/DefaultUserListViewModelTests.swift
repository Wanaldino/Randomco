//
//  DefaultUserListViewModelTests.swift
//  RandomcoTests
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import XCTest
@testable import Randomco

final class DefaultUserListViewModelTests: XCTestCase {
    var appState: MockAppStateOutput!
    var interactor: MockUserInteractor!
    var model: DefaultUserListViewModel!

    override func setUp() {
        appState = MockAppStateOutput()
        interactor = MockUserInteractor()
        model = DefaultUserListViewModel(interactor: interactor, appState: appState)
    }

    func testBindUsers() {
        appState.users.send([.mock])

        XCTAssertTrue(model.users?.isEmpty == false)
    }

    func testBindError() {
        let error = NSError(domain: UUID().description, code: 99)
        appState.users.send(completion: .failure(error))

        XCTAssert(model.error?.localizedDescription == error.localizedDescription)
    }

    func testDidLoad() async throws {
        model.retrieveUsers()
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertTrue(interactor.didLoad)
    }

    func testDidFetch() async throws {
        model.loadMore()
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertTrue(interactor.didFetch)
    }

    func testDidFavourite() async throws {
        model.favourite(.mock)
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertTrue(interactor.didFavourite)
    }

    func testDidDelete() async throws {
        model.delete(.mock)
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertTrue(interactor.didDelete)
    }
}
