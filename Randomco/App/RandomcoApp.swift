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
                UserList()
                    .environment(\.userInteractor, .defaultValue)
                    .environment(\.appState, .defaultValue)
                    .tabItem {
                        Label("List", systemImage: "person")
                    }

                UserList()
                    .environment(\.userInteractor, .defaultValue)
                    .environment(\.appState, .defaultValue)
                    .tabItem {
                        Label("Favourites", systemImage: "star")
                    }
            }
        }
    }
}

