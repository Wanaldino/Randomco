//
//  UserCell.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import SwiftUI

struct UserCell: View {
    let user: User

    var body: some View {
        HStack {
            let url = URL(string: user.picture.thumbnail)
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
        UserCell(user: User.mock)
    }
}
