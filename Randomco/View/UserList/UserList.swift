//
//  UserList.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI

struct UserList<Model>: View where Model: UserListViewModel {
    @ObservedObject var viewModel: Model

    init(viewModel: Model) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Users")
                .toolbar {
                    if viewModel.canLoadMore {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: viewModel.loadMore) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }

        }
    }

    @ViewBuilder
    var content: some View {
        if viewModel.users.isEmpty {
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
        .onAppear(perform: viewModel.retrieveUsers)
    }

    @ViewBuilder
    func ListView() -> some View {
        List {
            ForEach(viewModel.users) { user in
                NavigationLink {
                    UserDetail(user: user)
                } label: {
                    UserCell(user: user)
                }
                .swipeActions(edge: .trailing) {
                    Button(action: {
                        viewModel.favourite(user)
                    }, label: {
                        let image = user.isFavourite ? "star.slash" : "star"
                        Label("Favourite", systemImage: image)
                    })
                    .tint(.yellow)

                    Button(action: {
                        viewModel.delete(user)
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

struct UserList_Previews: PreviewProvider {
    static var previews: some View {
        UserList(viewModel: DefaultUserListViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
    }
}
