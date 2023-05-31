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
                        Label("list", systemImage: "person")
                            .accessibilityIdentifier("list")
                    }

                UserList(viewModel: FavouriteUserListViewModel())
                    .tabItem {
                        Label("favourites", systemImage: "star")
                            .accessibilityIdentifier("favourites")
                    }

                UserList(viewModel: NearUserListViewModel())
                    .tabItem {
                        Label("near", systemImage: "person.3.fill")
                            .accessibilityIdentifier("near")
                    }
            }
        }
    }
}

