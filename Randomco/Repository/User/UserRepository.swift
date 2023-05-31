//
//  UserRepository.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import Foundation
import Combine

class UserRepository {
    func fetchUsers() async throws -> UserListResponse {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

        let url = URL(string: "https://randomuser.me/api/1.4?results=100")!

        let data = try await URLSession.shared.data(from: url).0
        let response = try jsonDecoder.decode(UserListResponse.self, from: data)
        return response
    }
}
