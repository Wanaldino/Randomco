//
//  MockAppState.swift
//  RandomcoTests
//
//  Created by Carlos Martinez Medina on 30/5/23.
//

import Combine
import CoreLocation
@testable import Randomco

class MockAppStateOutput: AppStateOutput {
    var users: CurrentValueSubject<[User]?, Error> = .init(nil)
    var location: CurrentValueSubject<CLLocation?, Error> = .init(nil)
}
