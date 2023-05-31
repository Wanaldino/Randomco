//
//  LocationInteractor.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 30/5/23.
//

import CoreLocation

protocol LocationInteractor {
    func requestLocation()
}

class DefaultLocationInteractor: NSObject, LocationInteractor {
    let appState = AppState.shared
    let locationManager = CLLocationManager()

    override init() {
        super.init()

        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension DefaultLocationInteractor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        appState.location.send(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        appState.location.send(completion: .failure(error))
    }
}
