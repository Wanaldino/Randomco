//
//  SortUserKey.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 1/6/23.
//

import Foundation

enum SortUserKey: String, CaseIterable, Identifiable {
    case name, gender
    var id: Self { self }
}
