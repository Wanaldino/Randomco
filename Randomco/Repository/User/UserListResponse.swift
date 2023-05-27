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

        struct Picture: Decodable {
            let large: String
            let medium: String
            let thumbnail: String
        }

        let name: Name
        let email: String
        let picture: Picture
        let phone: String
    }
    
    let results: [User]
}

extension UserListResponse.User {
    var image: URL? {
        URL(string: picture.large)
    }
}
