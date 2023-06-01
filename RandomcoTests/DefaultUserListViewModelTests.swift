//
//  DefaultUserListViewModelTests.swift
//  RandomcoTests
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import XCTest
import Combine
@testable import Randomco

final class DefaultUserListViewModelTests: XCTestCase {
    var appState: MockAppStateOutput!
    var interactor: MockUserInteractor!
    var model: DefaultUserListViewModel!

    private var cancellables: Set<AnyCancellable> = Set()

    override func setUp() {
        super.setUp()
        appState = MockAppStateOutput()
        interactor = MockUserInteractor()
        model = DefaultUserListViewModel(interactor: interactor, appState: appState)
    }

    override func tearDown() {
        super.tearDown()
        cancellables = []
    }

    func testBindUsers() {
        var users: [User] = []
        let expectation = self.expectation(description: "DefaultUserListViewModelTests.Users")

        model.$state.dropFirst().first().sink { state in
            switch state {
            case .loaded(let _users):
                users = _users
            default:
                break
            }
            expectation.fulfill()
        }.store(in: &cancellables)

        appState.users.send([.mock])
        waitForExpectations(timeout: 10)

        XCTAssertTrue(users.isEmpty == false)
    }

    func testBindError() {
        var error: Error?
        let expectation = self.expectation(description: "DefaultUserListViewModelTests.Error")

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
