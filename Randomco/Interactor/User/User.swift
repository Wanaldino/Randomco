//
//  User.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 27/5/23.
//

import Foundation

struct User {
    struct Name {
        let title: String
        let first: String
        let last: String

        var fullName: String {
            String(format: "%@ %@", first, last)
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

        init?(from nameMO: NameMO) {
            guard let title = nameMO.title,
                  let first = nameMO.first,
                  let last = nameMO.last
            else { return nil }

            self.init(title: title, first: first, last: last)
        }
    }

    struct Location {
        struct Street {
            let name: String
            let number: Int

            init(name: String, number: Int) {
                self.name = name
                self.number = number
            }

            init(from response: UserListResponse.User.Location.Street) {
                name = response.name
                number = response.number
            }

            init?(from streetMO: StreetMO) {
                guard let name = streetMO.name else { return nil }

                self.init(name: name, number: Int(streetMO.number))
            }
        }

        let street: Street
        let city: String
        let state: String

        init(street: Street, city: String, state: String) {
            self.street = street
            self.city = city
            self.state = state
        }

        init(from response: UserListResponse.User.Location) {
            street = Street(from: response.street)
            city = response.city
            state = response.state
        }

        init?(from locationMO: LocationMO) {
            guard let city = locationMO.city,
                  let state = locationMO.state,
                  let streetMO = locationMO.street, let street = Street(from: streetMO)
            else { return nil }

            self.street = street
            self.city = city
            self.state = state
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

        init?(from pictureMO: PictureMO) {
            guard let large = pictureMO.large,
                  let medium = pictureMO.medium,
                  let thumbnail = pictureMO.thumbnail
            else { return nil }

            self.init(large: large, medium: medium, thumbnail: thumbnail)
        }
    }

    struct Register {
        let date: Date

        init(date: Date) {
            self.date = date
        }

        init(from response: UserListResponse.User.Register) {
            date = response.date
        }

        init?(from registeredMO: RegisterMO) {
            guard let date = registeredMO.date else { return nil }

            self.init(date: date)
        }
    }

    let gender: String
    let name: Name
    let location: Location
    let email: String
    let registered: Register
    let picture: Picture
    let phone: String

    var isFavourite: Bool
    var isHidden: Bool

    init(
        gender: String,
        name: Name,
        location: Location,
        email: String,
        registered: Register,
        picture: Picture,
        phone: String,
        isFavourite: Bool,
        isHidden: Bool
    ) {
        self.gender = gender
        self.name = name
        self.location = location
        self.email = email
        self.registered = registered
        self.picture = picture
        self.phone = phone
        self.isFavourite = isFavourite
        self.isHidden = isHidden
    }

    init(from response: UserListResponse.User) {
        gender = response.gender
        name = Name(from: response.name)
        location = Location(from: response.location)
        email = response.email
        registered = Register(from: response.registered)
        picture = Picture(from: response.picture)
        phone = response.phone
        isFavourite = false
        isHidden = false
    }

    init?(from userMO: UserMO) {
        guard let gender = userMO.gender,
              let nameMO = userMO.name, let name = Name(from: nameMO),
              let locationMO = userMO.location, let location = Location(from: locationMO),
              let email = userMO.email,
              let registerMO = userMO.registered, let register = Register(from: registerMO),
              let pictureMO = userMO.picture, let picture = Picture(from: pictureMO),
              let phone = userMO.phone
        else { return nil }

        self.init(
            gender: gender,
            name: name,
            location: location,
            email: email,
            registered: register,
            picture: picture,
            phone: phone,
            isFavourite: userMO.isFavourite,
            isHidden: userMO.isHidden
        )
    }
}

extension User: Identifiable {
    var id: String { email }
}

extension User {
    static let mock = User(
        gender: "male",
        name: User.Name(
            title: "Mr.",
            first: "Carlos",
            last: "Martinez"
        ),
        location: Location(
            street: Location.Street(
                name: "Carrer Antonio cubells",
                number: 22
            ),
            city: "Valencia",
            state: "Comunitat Valenciana"
        ),
        email: "example@example.com",
        registered: Register(date: .now),
        picture: User.Picture(
            large: "",
            medium: "",
            thumbnail: ""
        ),
        phone: "665 987 324",
        isFavourite: true,
        isHidden: false
    )
}
