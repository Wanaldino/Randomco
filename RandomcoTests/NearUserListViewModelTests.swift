//
//  NearUserListViewModelTests.swift
//  RandomcoTests
//
//  Created by Carlos Martinez Medina on 30/5/23.
//

import CoreLocation
import XCTest
@testable import Randomco

final class NearUserListViewModelTests: XCTestCase {
    var appState: MockAppStateOutput!
    var interactor: MockUserInteractor!
    var model: NearUserListViewModel!

    override func setUp() {
        appState = MockAppStateOutput()
        interactor = MockUserInteractor()
        model = NearUserListViewModel(interactor: interactor, appState: appState)
    }

    func testBindUsers() {
        appState.users.send([.mock])

        XCTAssertFalse(model.users?.isEmpty == false)
    }

    func testBindLocation() {
        appState.location.send(CLLocation(latitude: 0, longitude: 0))

        XCTAssertFalse(model.users?.isEmpty == false)
    }

    func testBindUserAndLocation() {
        appState.users.send([.mock])
        appState.location.send(CLLocation(latitude: 0, longitude: 0))

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
