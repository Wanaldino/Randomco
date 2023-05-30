//
//  UserListViewModel.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 30/5/23.
//

import Combine

protocol UserListViewModel: ObservableObject {
    var users: [User] { get }
    var canLoadMore: Bool { get }

    func retrieveUsers()
    func loadMore()
    func favourite(_ user: User)
    func delete(_ user: User)
}

class DefaultUserListViewModel: UserListViewModel {
    let appState = AppState.shared
    let interactor: UserInteractor

    @Published var users: [User] = []
    fileprivate var cancelables = Set<AnyCancellable>()

    var canLoadMore: Bool { true }
    var canRemove: Bool { true }

    init(interactor: UserInteractor = DefaultUserInteractor()) {
        self.interactor = interactor

        bind()
    }

    func bind() {
        appState.users.sink { users in
            self.users = users
        }.store(in: &cancelables)
    }

    func retrieveUsers() {
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

    override func bind() {
        appState.users.map { users in
            users.filter(\.isFavourite)
        }.sink { users in
            self.users = users
        }.store(in: &cancelables)
    }
}
