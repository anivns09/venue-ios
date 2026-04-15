//
//  VenueRepository.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreNetworking
import Foundation

/// This enum contains URL template, query
/// parameter names, and required headers.
nonisolated enum VenueEndpoint {
    static let baseURL = "https://ignition.qa.ticketek.net/venues/"
    static let apiKey = "TEq5Mddna23xSNsoDeYt8aP02BJHrvoa6X07nEuD"
    static let authToken = "Basic Yhd9X=38D88!"

    static var headers: [String: String] {
        [
            "content-type": "application/json",
            "x-api-key": apiKey,
            "Accept-Language": "en",
            "Authorization": authToken,
        ]
    }

    static func url(latitude: Double, longitude: Double) -> String {
        "\(baseURL)?latitude=\(latitude)&longitude=\(longitude)"
    }
}

// MARK: - Repository Protocol

protocol VenueRepositoryProtocol {
    /// Fetches venues for the given coordinate.
    func fetchVenues(latitude: Double, longitude: Double) async throws -> [Venue]
}

// MARK: - Repository Implementation

nonisolated final class VenueRepository: VenueRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchVenues(latitude: Double, longitude: Double) async throws -> [Venue] {
        let urlString = VenueEndpoint.url(latitude: latitude, longitude: longitude)

        let response: VenueListResponse = try await networkService.loadData(
            from: urlString,
            headers: VenueEndpoint.headers
        )

        return response.venues
    }
}
