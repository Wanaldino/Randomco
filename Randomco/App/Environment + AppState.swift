//
//  Environment + AppState.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 29/5/23.
//

import SwiftUI

extension AppState: EnvironmentKey {
    static var defaultValue: AppState {
        return AppState.default
    }
    private static let `default` = AppState()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppState.self] }
        set { self[AppState.self] = newValue }
    }
}
