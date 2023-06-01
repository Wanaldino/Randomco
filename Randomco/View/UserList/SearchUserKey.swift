//
//  SearchUserKey.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 31/5/23.
//

import Foundation

enum SearchUserKey: String, CaseIterable, Identifiable {
    case name, surname, email
    var id: Self { self }
}
