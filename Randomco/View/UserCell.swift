//
//  UserCell.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI

struct UserCell: View {
    var user: UserListResponse.User

    var body: some View {
        HStack {
            let url = URL(string: user.picture.medium)
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(user.name.fullName)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                Text(user.phone)
                    .font(.subheadline)
            }
        }
    }
}

struct UserCell_Previews: PreviewProvider {
    static var previews: some View {
        UserCell(user: UserListResponse.User(
            name: UserListResponse.User.Name(
                title: "Mr.",
                first: "Carlos",
                last: "Martinez"
            ),
            email: "example@example.com",
            picture: UserListResponse.User.Picture(
                large: "",
                medium: "",
                thumbnail: ""
            ),
            phone: "665 987 324"
        ))
    }
}
