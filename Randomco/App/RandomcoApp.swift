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
            UserList()
                .environment(\.userInteractor, .defaultValue)
                .environment(\.appState, .defaultValue)
        }
    }
}

