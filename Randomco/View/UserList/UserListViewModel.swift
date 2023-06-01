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

    var search: String { get set }
    var searchKey: SearchUserKey { get set }
    var searchHints: [String] { get }

    var sortKey: SortUserKey { get set }

    var canLoadMore: Bool { get }
    var title: String { get }

    func loadMore()
    func favourite(_ user: User)
    func delete(_ user: User)
}

class DefaultUserListViewModel: UserListViewModel {
    let appState: AppStateOutput
    let interactor: UserInteractor

    @Published var state: LoadingState<[User]> = .notLoaded
    @Published var search: String = ""
    @Published var searchKey: SearchUserKey = .name
    @Published var searchHints: [String] = []
    @Published var sortKey: SortUserKey = .name

    fileprivate var cancelables = Set<AnyCancellable>()

    var canLoadMore: Bool { true }
    var canRemove: Bool { true }
    var title: String { "users" }

    var usersPublisher: AnyPublisher<[User], Never> {
        appState.users
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .catch(handle(error:))
            .compactMap(filter(users:))
            .combineLatest($search, $searchKey)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .map(filter(users:by:on:))
            .map(filter(users:))
            .combineLatest($sortKey)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .map(sort(users:by:))
            .eraseToAnyPublisher()
    }

    init(interactor: UserInteractor = DefaultUserInteractor(), appState: AppStateOutput = AppState.shared) {
        self.interactor = interactor
        self.appState = appState

        bind()
    }

    func bind() {
        usersPublisher
            .map(hints(of:))
            .map(Set.init)
            .map(Array.init)
            .map({ $0.sorted() })
            .receive(on: DispatchQueue.main)
            .assign(to: &$searchHints)

        usersPublisher
            .map(LoadingState.loaded)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }

    func hints(of users: [User]) -> [String] {
        users.map { user in
            switch searchKey {
            case .name:
                return user.name.first
            case .surname:
                return user.name.last
            case .email:
                return user.email
            }
        }
    }

    func handle(error: Error) -> AnyPublisher<[User]?, Never> {
        self.state = .error(error)
        return Just<[User]?>(nil).ignoreOutput().eraseToAnyPublisher()
    }

    func filter(users: [User]?) -> [User]? {
        if let users {
            return users
        } else {
            self.retrieveUsers()
            return nil
        }
    }

    func filter(users: [User], by search: String, on key: SearchUserKey) -> [User] {
        guard search.isEmpty == false else { return users }
        return users.filter { user in
            switch key {
            case .name:
                return user.name.first.range(of: search, options: .caseInsensitive) != nil
            case .surname:
                return user.name.last.range(of: search, options: .caseInsensitive) != nil
            case .email:
                return user.email.range(of: search, options: .caseInsensitive) != nil
            }
        }
    }

    func filter(users: [User]) -> [User] {
        users.filter({ $0.isHidden == false })
    }

    func sort(users: [User], by key: SortUserKey) -> [User] {
        switch key {
        case .name:
            return users.sorted(by: { $0.name.fullName < $1.name.fullName })
        case .gender:
            return users.sorted(by: { $0.gender < $1.gender })
        }
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
    override var title: String { "favourites" }

    override func filter(users: [User]) -> [User] {
        super.filter(users: users).filter(\.isFavourite)
    }
}

class NearUserListViewModel: DefaultUserListViewModel {
    let locationInteractor: LocationInteractor

    override var title: String { "near" }

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
            .combineLatest(location)
            .map(filter(users:by:))
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
