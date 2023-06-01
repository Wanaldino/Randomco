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

extension LoadingState {
    var value: T? {
        switch self {
        case .loaded(let value): return value
        default: return nil
        }
    }

    var error: Error? {
        switch self {
        case .error(let error): return error
        default: return nil
        }
    }
}
