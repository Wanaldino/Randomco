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
                NavigationLink {
                    UserDetail(user: user)
                } label: {
                    UserCell(user: user)
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                favourite(user)
                            }, label: {
                                let image = user.isFavourite ? "star.slash" : "star"
                                Label("Favourite", systemImage: image)
                            })
                            .tint(.yellow)

                            Button(action: {
                                delete(user)
                            }, label: {
                                Label("Delete", systemImage: "trash")
                            })
                            .tint(.red)
                        }
                        .listRowBackground(user.isFavourite ? Color.yellow : nil)
                }
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
                withAnimation {
                    self.users = response
                }
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

    func favourite(_ user: User) {
        userInteractor.favourite(user)
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

    func delete(_ user: User) {
        userInteractor.delete(user)
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
