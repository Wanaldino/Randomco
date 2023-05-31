//
//  LoadingState.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 31/5/23.
//

import Foundation

enum LoadingState<T> {
    case notLoaded
    case loading
    case loaded(T)
    case error(Error)
}
