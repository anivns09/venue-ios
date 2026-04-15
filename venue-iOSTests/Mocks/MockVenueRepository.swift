//
//  MockVenueRepository.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

@testable import venue_iOS
import XCTest

final class MockVenueRepository: VenueRepositoryProtocol {
    var fetchVenuesResult: Result<[Venue], Error> = .success([])
    var receivedLat: Double?
    var receivedLon: Double?

    func fetchVenues(latitude: Double, longitude: Double) async throws -> [Venue] {
        receivedLat = latitude
        receivedLon = longitude
        return try fetchVenuesResult.get()
    }
}
