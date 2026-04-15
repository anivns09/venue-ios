//
//  Untitled.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreLocation
@testable import venue_iOS

final class MockVenueFetcher: FetchVenuesUseCaseProtocol {
    var shouldThrow = false
    var venuesToReturn: [Venue] = []
    func execute(latitude: Double, longitude: Double) async throws -> [Venue] {
        if shouldThrow {
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fetch failed"])
        }
        return venuesToReturn
    }
}
