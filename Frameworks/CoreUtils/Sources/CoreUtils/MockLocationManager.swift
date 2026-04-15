//
//  MockLocationManager.swift
//  CoreUtils
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreLocation

final class MockLocationManager: LocationManagerProtocol {
    weak var delegate: CLLocationManagerDelegate?

    /// Set this before calling requestLocation() in each test.
    var stubbedStatus: CLAuthorizationStatus = .authorizedWhenInUse

    var authorizationStatus: CLAuthorizationStatus {
        stubbedStatus
    }

    private(set) var didRequestAuthorization = false
    private(set) var didRequestLocation = false

    var onRequestLocation: (() -> Void)?

    func requestWhenInUseAuthorization() {
        didRequestAuthorization = true
    }

    func requestLocation() {
        didRequestLocation = true
        onRequestLocation?()
    }
}

// MARK: Simulation helpers

extension MockLocationManager {
    /// Simulate the delegate receiving a valid location.
    func simulateLocationUpdate(lat: Double, lon: Double) {
        let location = CLLocation(latitude: lat, longitude: lon)
        delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [location])
    }

    /// Simulate the delegate receiving an error.
    func simulateFailure(error: Error) {
        delegate?.locationManager?(CLLocationManager(), didFailWithError: error)
    }

    /// Simulate the user changing authorization status.
    func simulateAuthorizationChange(to status: CLAuthorizationStatus) {
        stubbedStatus = status
        let realManager = CLLocationManager()
        delegate?.locationManagerDidChangeAuthorization?(realManager)
    }
}
