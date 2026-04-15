//
//  FetchVenuesUseCase.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreLocation
import Foundation

enum VenueError: Error {
    case emptyData
}

protocol FetchVenuesUseCaseProtocol {
    func execute(latitude: Double, longitude: Double) async throws -> [Venue]
}

final class FetchVenuesUseCase: FetchVenuesUseCaseProtocol {
    private let repository: VenueRepositoryProtocol

    init(repository: VenueRepositoryProtocol = VenueRepository()) {
        self.repository = repository
    }

    func execute(latitude: Double, longitude: Double) async throws -> [Venue] {
        let venues = try await repository.fetchVenues(
            latitude: latitude,
            longitude: longitude
        )

        guard !venues.isEmpty else {
            throw VenueError.emptyData
        }

        // Showing like business rules could be here.
        return venues.sorted {
            distance(from: $0, to: latitude, longitude: longitude) <
                distance(from: $1, to: latitude, longitude: longitude)
        }
    }

    private func distance(from venue: Venue,
                          to lat: Double,
                          longitude lon: Double) -> Double
    {
        let a = CLLocation(latitude: venue.latitude, longitude: venue.longitude)
        let b = CLLocation(latitude: lat, longitude: lon)
        return a.distance(from: b)
    }
}
