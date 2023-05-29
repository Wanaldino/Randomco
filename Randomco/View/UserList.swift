//
//  UserList.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI

struct UserList: View {
    @Environment(\.userInteractor) var userInteractor
    @Environment(\.appState) var appState

    @State var users: [User] = []

    var body: some View {
        NavigationView {
            content
                .onReceive(appState.users, perform: { users in
                    withAnimation {
                        self.users = users
                    }
                })
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
                }
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

extension UserList {
    func retrieveUsers() {
        Task {
            try? await userInteractor.load()
        }
    }

    func loadMore() {
        Task {
            try? await userInteractor.fetchUsers()
        }
    }

    func favourite(_ user: User) {
        Task {
            try? await userInteractor.favourite(user)
        }
    }

    func delete(_ user: User) {
        Task {
            try? await userInteractor.delete(user)
        }
    }
}

struct UserList_Previews: PreviewProvider {
    static var previews: some View {
        UserList()
            .environment(\.userInteractor, .defaultValue)
            .environment(\.appState, .defaultValue)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
    }
}
