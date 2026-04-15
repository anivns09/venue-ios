//
//  MockNetworkService.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreNetworking
@testable import venue_iOS

/// Returns a hardcoded `VenueListResponse` regardless of URL or headers.
final class StubNetworkService: NetworkServiceProtocol {
    private let response: VenueListResponse
    private let error: Error?
    
    init(response: VenueListResponse, error: Error? = nil) {
        self.response = response
        self.error = error
    }

    func loadData<T: Decodable>(from _: String) async throws -> T {
        guard error == nil else {
            throw error!
        }
        return response as! T
    }

    func loadData<T: Decodable>(from _: String,
                                headers _: [String: String]) async throws -> T
    {
        guard error == nil else {
            throw error!
        }
        return response as! T
    }
}

/// Spy to store URL and headers it was called with so tests can assert on them.
final class SpyNetworkService: NetworkServiceProtocol {
    private(set) var capturedURL: String?
    private(set) var capturedHeaders: [String: String]?

    func loadData<T: Decodable>(from urlString: String) async throws -> T {
        capturedURL = urlString
        throw NetworkService.NetworkError.decodingError
    }

    func loadData<T: Decodable>(from urlString: String,
                                headers: [String: String]) async throws -> T
    {
        capturedURL = urlString
        capturedHeaders = headers
        throw NetworkService.NetworkError.decodingError
        
    }
}
