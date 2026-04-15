//
//  MockNetworkService.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreNetworking

@testable import venue_iOS

/// Returns a hardcoded `VenueListResponse` OR  `TicketScanResult` regardless of URL or headers.
final class StubNetworkService: NetworkServiceProtocol {
    private let venueResponse: VenueListResponse
    private let scanResult: TicketScanResult
    private let error: Error?

    init(venueResponse: VenueListResponse, scanResult: TicketScanResult = .successResponse, error: Error? = nil) {
        self.venueResponse = venueResponse
        self.scanResult = scanResult
        self.error = error
    }

    func postData<T, B>(
        to urlString: String,
        body: B,
        headers: [String: String]
    ) async throws -> T where T: Decodable, B: Encodable {
        guard error == nil else {
            throw error!
        }
        return scanResult as! T
    }

    func loadData<T: Decodable>(
        from _: String,
        headers _: [String: String]
    ) async throws -> T {
        guard error == nil else {
            throw error!
        }
        return venueResponse as! T
    }
}

/// Spy to store URL and headers it was called with so tests can assert on them.
final class SpyNetworkService: NetworkServiceProtocol {

    private(set) var capturedURL: String?
    private(set) var capturedHeaders: [String: String]?

    func postData<T: Decodable, B: Encodable>(
        to urlString: String,
        body: B,
        headers: [String: String]
    ) async throws -> T {
        capturedURL = urlString
        capturedHeaders = headers
        throw NetworkService.NetworkError.decodingError
    }

    func loadData<T: Decodable>(
        from urlString: String,
        headers: [String: String]
    ) async throws -> T {
        capturedURL = urlString
        capturedHeaders = headers
        throw NetworkService.NetworkError.decodingError
    }
}
