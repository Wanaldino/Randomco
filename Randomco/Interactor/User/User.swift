//
//  User.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 27/5/23.
//

import Foundation

struct User {
    struct Name {
        private let title: String
        private let first: String
        private let last: String

        var fullName: String {
            String(format: "%@ %@ %@", title, first, last)
        }

        init(title: String, first: String, last: String) {
            self.title = title
            self.first = first
            self.last = last
        }

        init(from response: UserListResponse.User.Name) {
            title = response.title
            first = response.first
            last = response.last
        }
    }

    struct Picture {
        let large: String
        let medium: String
        let thumbnail: String

        init(large: String, medium: String, thumbnail: String) {
            self.large = large
            self.medium = medium
            self.thumbnail = thumbnail
        }

        init(from response: UserListResponse.User.Picture) {
            large = response.large
            medium = response.medium
            thumbnail = response.thumbnail
        }
    }

    let name: Name
    let email: String
    let picture: Picture
    let phone: String

    init(name: Name, email: String, picture: Picture, phone: String) {
        self.name = name
        self.email = email
        self.picture = picture
        self.phone = phone
    }

    init(from response: UserListResponse.User) {
        name = Name(from: response.name)
        email = response.email
        picture = Picture(from: response.picture)
        phone = response.phone
    }
}

extension User: Identifiable {
    var id: String { email }
}

extension User {
    static let mock = User(
        name: User.Name(
            title: "Mr.",
            first: "Carlos",
            last: "Martinez"
        ),
        email: "example@example.com",
        picture: User.Picture(
            large: "",
            medium: "",
            thumbnail: ""
        ),
        phone: "665 987 324"
    )
}
