//
//  UserDetail.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 28/5/23.
//

import SwiftUI

struct UserDetail: View {
    let user: User

    var body: some View {
        List {
            GeometryReader {
                let url = URL(string: user.picture.large)
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: $0.size.width)
                .clipShape(Circle())
            }
            .frame(height: 200)

            Section {
                Text(user.email)
                    .font(.subheadline)
                Text(user.phone)
                    .font(.subheadline)
                Text(user.gender)
                    .font(.subheadline)
            } header: {
                Text("info")
                    .font(.headline)
            }

            Section {
                Text(user.location.street.fullName)
                    .font(.subheadline)
                Text(user.location.state)
                    .font(.subheadline)
                Text(user.location.city)
                    .font(.subheadline)
            } header: {
                Text("location")
                    .font(.headline)
            }

            Section {
                Text(user.registered.date, style: .date)
                    .font(.subheadline)
            } header: {
                Text("register")
                    .font(.headline)
            }
        }
        .navigationTitle(user.name.fullName)
    }
}

struct UserDetail_Previews: PreviewProvider {
    static var previews: some View {
        UserDetail(user: .mock)
    }
}
