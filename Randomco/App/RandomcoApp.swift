//
//  RandomcoApp.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI

@main
struct RandomcoApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                UserList(viewModel: DefaultUserListViewModel())
                    .tabItem {
                        Label("List", systemImage: "person")
                    }

                UserList(viewModel: FavouriteUserListViewModel())
                    .tabItem {
                        Label("Favourites", systemImage: "star")
                    }
            }
        }
    }
}

