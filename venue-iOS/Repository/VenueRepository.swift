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

    static func venueListUrl(latitude: Double, longitude: Double) -> String {
        "\(baseURL)?latitude=\(latitude)&longitude=\(longitude)"
    }

    static func scanURL(venueCode: String) -> String {
        "\(baseURL)\(venueCode)/pax/entry/scan"
    }
}

// MARK: - Repository Protocol

protocol VenueRepositoryProtocol {
    /// Fetches venues for the given coordinate.
    func fetchVenues(latitude: Double, longitude: Double) async throws
        -> [Venue]

    func scanBarcode(venueCode: String, barcode: String) async throws
        -> TicketScanResult
}

// MARK: - Repository Implementation

nonisolated final class VenueRepository: VenueRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchVenues(latitude: Double, longitude: Double) async throws
        -> [Venue]
    {
        let urlString = VenueEndpoint.venueListUrl(
            latitude: latitude,
            longitude: longitude
        )

        let response: VenueListResponse = try await networkService.loadData(
            from: urlString,
            headers: VenueEndpoint.headers
        )

        return response.venues
    }

    func scanBarcode(venueCode: String, barcode: String) async throws
        -> TicketScanResult
    {
        let body = ScanRequest(barcode: barcode)
        let urlString = VenueEndpoint.scanURL(venueCode: venueCode)

        return try await networkService.postData(
            to: urlString,
            body: body,
            headers: VenueEndpoint.headers
        )
    }
}
