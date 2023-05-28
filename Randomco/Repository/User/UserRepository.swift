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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

        let url = URL(string: "https://randomuser.me/api/1.4?results=100&seed=asd")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: UserListResponse.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
}
