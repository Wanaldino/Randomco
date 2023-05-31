//
//  UserListViewModel.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 30/5/23.
//

import Dispatch
import Combine
import CoreLocation

protocol UserListViewModel: ObservableObject {
    var state: LoadingState<[User]> { get }
    var canLoadMore: Bool { get }

    func loadMore()
    func favourite(_ user: User)
    func delete(_ user: User)
}

class DefaultUserListViewModel: UserListViewModel {
    let appState: AppStateOutput
    let interactor: UserInteractor

    @Published var state: LoadingState<[User]> = .notLoaded
    fileprivate var cancelables = Set<AnyCancellable>()

    var canLoadMore: Bool { true }
    var canRemove: Bool { true }

    var usersPublisher: AnyPublisher<[User], Never> {
        appState.users
            .catch(handle(error:))
            .compactMap(filter(users:))
            .map(filter(users:))
            .eraseToAnyPublisher()
    }

    init(interactor: UserInteractor = DefaultUserInteractor(), appState: AppStateOutput = AppState.shared) {
        self.interactor = interactor
        self.appState = appState

        bind()
    }

    func bind() {
        usersPublisher
            .map(LoadingState.loaded)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }

    func handle(error: Error) -> AnyPublisher<[User]?, Never> {
        self.state = .error(error)
        return Just<[User]?>(nil).eraseToAnyPublisher()
    }

    func filter(users: [User]?) -> [User]? {
        if let users {
            return users
        } else {
            self.retrieveUsers()
            return nil
        }
    }

    func filter(users: [User]) -> [User] {
        users.filter({ $0.isHidden == false })
            .sorted(by: { $0.name.fullName < $1.name.fullName })
    }

    func retrieveUsers() {
        self.state = .loading
        Task {
            try? await interactor.load()
        }
    }

    func loadMore() {
        guard canLoadMore else { return }
        Task {
            try? await interactor.fetch()
        }
    }

    func favourite(_ user: User) {
        Task {
            try? await interactor.favourite(user)
        }
    }

    func delete(_ user: User) {
        Task {
            try? await interactor.delete(user)
        }
    }
}

class FavouriteUserListViewModel: DefaultUserListViewModel {
    override var canLoadMore: Bool { false }

    override func filter(users: [User]) -> [User] {
        super.filter(users: users).filter(\.isFavourite)
    }
}

class NearUserListViewModel: DefaultUserListViewModel {
    let locationInteractor: LocationInteractor

    init(
        interactor: UserInteractor = DefaultUserInteractor(),
        locationInteractor: LocationInteractor = DefaultLocationInteractor(),
        appState: AppStateOutput = AppState.shared
    ) {
        self.locationInteractor = locationInteractor
        super.init(interactor: interactor, appState: appState)
    }

    override var usersPublisher: AnyPublisher<[User], Never> {
        let location = appState.location
            .catch(handle(error:))
            .compactMap(filter(location:))

        return super.usersPublisher
            .zip(location)
            .map(filter)
            .eraseToAnyPublisher()
    }

    func handle(error: Error) -> AnyPublisher<CLLocation?, Never> {
        self.state = .error(error)
        return Just<CLLocation?>(nil).eraseToAnyPublisher()
    }

    func filter(location: CLLocation?) -> CLLocation? {
        if let location {
            return location
        } else {
            locationInteractor.requestLocation()
            return nil
        }
    }

    func filter(users: [User], by location: CLLocation) -> [User] {
        users.filter { user in
            user.location.coordinates.distance(to: location) < 1000
        }
    }
}
