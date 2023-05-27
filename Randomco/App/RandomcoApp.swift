//
//  RandomcoApp.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI

@main
struct RandomcoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            UserList()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.userInteractor, .defaultValue)
        }
    }
}

