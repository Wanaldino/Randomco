//
//  UserList.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI
import Combine

struct UserList: View {
    @Environment(\.userInteractor) var userInteractor
    @State var users: [User] = []
    @State fileprivate(set) var subscriptions = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Users")
                .navigationBarItems(trailing: Button(action: loadMore) {
                    Image(systemName: "plus")
                })

        }
    }

    @ViewBuilder
    var content: some View {
        if users.isEmpty {
            EmptyView()
        } else {
            ListView()
        }
    }

    @ViewBuilder
    func EmptyView() -> some View {
        List {
            ForEach((0 ..< 3)) { _ in
                UserCell(user: .mock)
                    .redacted(reason: .placeholder)
                    .animatePlaceholder()
            }
        }
        .onAppear(perform: retrieveUsers)
    }

    @ViewBuilder
    func ListView() -> some View {
        List {
            ForEach(users) { user in
                UserCell(user: user)
            }
        }
    }
}

extension UserList {
    func retrieveUsers() {
        userInteractor.load()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("finished")
                }
            } receiveValue: { response in
                self.users = response
            }
            .store(in: &subscriptions)
    }

    func loadMore() {
        userInteractor.fetchUsers()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("finished")
                }
            } receiveValue: { _ in
                retrieveUsers()
            }
            .store(in: &subscriptions)
    }
}

struct UserList_Previews: PreviewProvider {
    static var previews: some View {
        UserList()
    }
}