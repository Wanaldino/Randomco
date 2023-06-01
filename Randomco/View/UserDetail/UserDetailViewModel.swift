//
//  UserDetailViewModel.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 1/6/23.
//

import Dispatch
import Combine

protocol UserDetailViewModel: ObservableObject {
    var state: LoadingState<User> { get }

    func didTapFavourite()
    func didTapDelete()
}

class DefaultUserDetailViewModel: UserDetailViewModel {
    @Published var state: LoadingState<User>

    let interactor: UserInteractor = DefaultUserInteractor()
    let appState: AppStateOutput = AppState.shared

    init(user: User) {
        self.state = .loaded(user)
        bind()
    }

    func bind() {
        appState.users
            .catch { error in
                self.state = .error(error)
                return Just<[User]?>(nil).ignoreOutput().eraseToAnyPublisher()
            }
            .compactMap { users in
                guard let user = users?.first(where: { $0 == self.state.value }) else { return nil }
                return user
            }
            .map(LoadingState.loaded)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }

    func didTapFavourite() {
        guard let user = state.value else { return }
        Task {
            try await interactor.favourite(user)
        }
    }

    func didTapDelete() {
        guard let user = state.value else { return }
        Task {
            try await interactor.delete(user)
        }
    }
}
