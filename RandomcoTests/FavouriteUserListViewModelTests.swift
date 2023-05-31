//
//  FavouriteUserListViewModelTests.swift
//  RandomcoTests
//
//  Created by Carlos Martinez Medina on 30/5/23.
//

import XCTest
@testable import Randomco

final class FavouriteUserListViewModelTests: XCTestCase {
    var appState: MockAppStateOutput!
    var interactor: MockUserInteractor!
    var model: FavouriteUserListViewModel!

    override func setUp() {
        appState = MockAppStateOutput()
        interactor = MockUserInteractor()
        model = FavouriteUserListViewModel(interactor: interactor, appState: appState)
    }

    func testBindUsers() async throws {
        appState.users.send([.mock])
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertTrue(model.state.value?.isEmpty == false)
    }

//    func testBindError() {
//        let error = NSError(domain: UUID().description, code: 99)
//        appState.users.send(completion: .failure(error))
//
//        XCTAssert(model.state.error?.localizedDescription == error.localizedDescription)
//    }

    func testDidLoad() async throws {
        model.retrieveUsers()
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertTrue(interactor.didLoad)
    }

    func testDidFetch() async throws {
        model.loadMore()
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertFalse(interactor.didFetch)
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
