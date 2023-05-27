//
//  UserRepository.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import Foundation
import Combine

class UserRepository {
    func fetchUsers() -> AnyPublisher<UserListResponse, Error> {
        let url = URL(string: "https://randomuser.me/api/1.4?results=100")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: UserListResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
