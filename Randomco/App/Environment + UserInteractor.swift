//
//  Environment + UserInteractor.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI

extension UserInteractor: EnvironmentKey {
    static var defaultValue: Self {
        return Self.default
    }
    private static let `default` = Self(userRepository: UserRepository(), userDBRepository: UserDBRepository())
}

extension EnvironmentValues {
    var userInteractor: UserInteractor {
        get { self[UserInteractor.self] }
        set { self[UserInteractor.self] = newValue }
    }
}
