//
//  LocationService.swift
//  CoreUtils
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreLocation
import Foundation

public protocol LocationManagerProtocol: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestWhenInUseAuthorization()
    func requestLocation()
}

extension CLLocationManager: LocationManagerProtocol {}

public protocol LocationServiceProtocol {
    func requestLocation() async throws -> CLLocationCoordinate2D
}

// MARK: - LocationService

public final class LocationService: NSObject, LocationServiceProtocol {
    private var manager: LocationManagerProtocol
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    public init(manager: LocationManagerProtocol = CLLocationManager()) {
        self.manager = manager
        super.init()
        self.manager.delegate = self
    }

    public func requestLocation() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        if status == .denied || status == .restricted {
            throw LocationError.permissionDenied
        }
        print("Ani: Requesting location...\(status)")
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        continuation?.resume(returning: location.coordinate)
        continuation = nil
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = self.manager.authorizationStatus
        if status == .denied || status == .restricted {
            continuation?.resume(throwing: LocationError.permissionDenied)
            continuation = nil
        }
    }
}

// MARK: - Errors

enum LocationError: Error, Equatable {
    case permissionDenied
}
