//
//  UserList.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI

struct UserList<Model>: View where Model: UserListViewModel {
    @StateObject var viewModel: Model

    var body: some View {
        NavigationView {
            content
                .navigationTitle("users")
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
        switch viewModel.state {
        case .notLoaded, .loading:
            LoadingView()
        case .loaded(let users):
            ListView(users: users)
                .searchable(text: $viewModel.search)
                .searchSuggestions {
                    Picker("Search", selection: $viewModel.searchKey) {
                        ForEach(SearchUserKey.allCases) { key in
                            Text(key.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    ForEach(viewModel.searchHints, id: \.self) { hint in
                        Text(hint)
                            .searchCompletion(hint)
                    }
                }
        case .error:
            Text("generic_error")
        }
    }

    @ViewBuilder
    func LoadingView() -> some View {
        List {
            ForEach((0 ..< 3)) { _ in
                UserCell(user: .mock)
                    .redacted(reason: .placeholder)
                    .animatePlaceholder()
            }
        }
    }

    @ViewBuilder
    func ListView(users: [User]) -> some View {
        List {
            if users.isEmpty {
                EmptyView()
            }
            
            ForEach(users) { user in
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
                        Label("favourite", systemImage: image)
                    })
                    .tint(.yellow)

                    Button(action: {
                        viewModel.delete(user)
                    }, label: {
                        Label("delete", systemImage: "trash")
                    })
                    .tint(.red)
                }
                .listRowBackground(user.isFavourite ? Color.yellow : nil)
            }
        }
    }

    @ViewBuilder
    func EmptyView() -> some View {
        Text("users_empty")
    }
}

struct UserList_Previews: PreviewProvider {
    static var previews: some View {
        UserList(viewModel: DefaultUserListViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))


        UserList(viewModel: FavouriteUserListViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))


        UserList(viewModel: NearUserListViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
    }
}
