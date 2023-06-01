//
//  NearUserListViewModelTests.swift
//  RandomcoTests
//
//  Created by Carlos Martinez Medina on 30/5/23.
//

import CoreLocation
import XCTest
import Combine
@testable import Randomco

final class NearUserListViewModelTests: XCTestCase {
    var appState: MockAppStateOutput!
    var interactor: MockUserInteractor!
    var model: NearUserListViewModel!

    private var cancellables: Set<AnyCancellable> = Set()

    override func setUp() {
        super.setUp()
        appState = MockAppStateOutput()
        interactor = MockUserInteractor()
        model = NearUserListViewModel(interactor: interactor, appState: appState)
    }

    override func tearDown() {
        super.tearDown()
        cancellables = []
    }

    func testBindUsers() async throws {
        appState.users.send([.mock])
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertFalse(model.state.value?.isEmpty == false)
    }

    func testBindLocation() async throws {
        appState.location.send(CLLocation(latitude: 0, longitude: 0))
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertFalse(model.state.value?.isEmpty == false)
    }

    func testBindUserAndLocation() async throws {
        appState.users.send([.mock])
        appState.location.send(CLLocation(latitude: 0, longitude: 0))
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertTrue(model.state.value?.isEmpty == false)
    }

    func testBindError() {
        var error: Error?
        let expectation = self.expectation(description: "NearUserListViewModelTests.Error")

        model.$state.dropFirst().first().sink { state in
            switch state {
            case .error(let _error):
                error = _error
            default:
                break
            }
            expectation.fulfill()
        }.store(in: &cancellables)

        let sentError = NSError(domain: UUID().description, code: 99)
        appState.users.send(completion: .failure(sentError))
        waitForExpectations(timeout: 10)

        XCTAssert(error?.localizedDescription == sentError.localizedDescription)
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
