//
//  MockLocationService.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreUtils
import CoreLocation
@testable import venue_iOS

final class MockLocationService: LocationServiceProtocol {
    var shouldThrow = false
    var coordinateToReturn = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    func requestLocation() async throws -> CLLocationCoordinate2D {
        if shouldThrow {
            throw NSError(domain: "Test", code: 2, userInfo: [NSLocalizedDescriptionKey: "Location failed"])
        }
        return coordinateToReturn
    }
}
