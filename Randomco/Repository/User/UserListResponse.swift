//
//  UserListResponse.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import Foundation

struct UserListResponse: Decodable {
    struct User: Decodable {
        struct Name: Decodable {
            let title: String
            let first: String
            let last: String
        }

        struct Location: Decodable {
            struct Street: Decodable {
                let number: Int
                let name: String
            }

            let street: Street
            let city: String
            let state: String
        }

        struct Picture: Decodable {
            let large: String
            let medium: String
            let thumbnail: String
        }

        struct Register: Decodable {
            let date: Date
        }

        let gender: String
        let name: Name
        let location: Location
        let email: String
        let picture: Picture
        let phone: String
        let registered: Register
    }

    let results: [User]
}

extension UserListResponse.User {
    var image: URL? {
        URL(string: picture.large)
    }
}
