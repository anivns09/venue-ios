//
//  VenueRepositoryTests.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreNetworking
@testable import venue_iOS
import XCTest

@MainActor
final class VenueRepositoryTests: XCTestCase {
    // MARK: - Happy path

    func testFetchVenuesReturnsDecodedVenues() async throws {
        let sut = makeSucceedingSUT()
        let venues = try await sut.fetchVenues(
            latitude: -33.877,
            longitude: 151.210
        )

        XCTAssertEqual(venues.count, 2)
        XCTAssertEqual(venues[0].code, "AEC")
        XCTAssertEqual(venues[0].name, "Adelaide Entertainment Centre")
        XCTAssertEqual(venues[1].code, "BEC")
    }

    func testFetchVenuesMapsLatLonIntoURL() async {
        let spy = SpyNetworkService()
        let sut = VenueRepository(networkService: spy)

        _ = try? await sut.fetchVenues(latitude: -33.877, longitude: 151.210)

        XCTAssertEqual(spy.capturedURL,
                       VenueEndpoint.url(latitude: -33.877, longitude: 151.210))
    }

    func testFetchVenuesIncludesAllRequiredHeaders() async {
        let spy = SpyNetworkService()
        let sut = VenueRepository(networkService: spy)

        _ = try? await sut.fetchVenues(latitude: -33.877, longitude: 151.210)

        XCTAssertEqual(spy.capturedHeaders?["x-api-key"], VenueEndpoint.apiKey)
        XCTAssertEqual(spy.capturedHeaders?["Authorization"], VenueEndpoint.authToken)
        XCTAssertEqual(spy.capturedHeaders?["content-type"], "application/json")
        XCTAssertEqual(spy.capturedHeaders?["Accept-Language"], "en")
    }

    func testFetchVenuesDecodesNestedPaxLocations() async throws {
        let sut = makeSucceedingSUT()
        let venues = try await sut.fetchVenues(latitude: -33.877, longitude: 151.210)

        let aec = try XCTUnwrap(venues.first { $0.code == "AEC" })
        XCTAssertEqual(aec.paxLocations.count, 1)
        XCTAssertEqual(aec.paxLocations[0].name, "CENTRE")
        XCTAssertEqual(aec.paxLocations[0].gates.map(\.name), ["A", "B"])
    }

    func testFetchVenuesDecodesGatesForMultiplePaxLocations() async throws {
        let sut = makeSucceedingSUT()
        let venues = try await sut.fetchVenues(latitude: -33.877, longitude: 151.210)

        let bec = try XCTUnwrap(venues.first { $0.code == "BEC" })
        XCTAssertEqual(bec.paxLocations.count, 1)
        XCTAssertEqual(bec.paxLocations[0].gates.map(\.name), ["1", "2"])
    }

    // MARK: - Error paths

    func testFetchVenuesPropagatesHTTPError() async {
        let sut = makeSUT(throwing: NetworkService.NetworkError.httpError(statusCode: 401))

        do {
            _ = try await sut.fetchVenues(latitude: 0, longitude: 0)
            XCTFail("Expected an error")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .httpError(statusCode: 401))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchVenuesPropagatesInvalidURLError() async {
        let sut = makeSUT(throwing: NetworkService.NetworkError.invalidURL)

        do {
            _ = try await sut.fetchVenues(latitude: 0, longitude: 0)
            XCTFail("Expected an error")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchVenuesPropagatesDecodingError() async {
        let sut = makeSUT(throwing: NetworkService.NetworkError.decodingError)

        do {
            _ = try await sut.fetchVenues(latitude: 0, longitude: 0)
            XCTFail("Expected an error")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .decodingError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testDecodingRealAPIResponseJSON() throws {
        let json = """
        {
          "venues": [
            {
              "code": "AEC",
              "name": "Adelaide Entertainment Centre",
              "address": "Corner Port Road and Adam Street",
              "city": "Hindmarsh",
              "state": "SA",
              "postcode": "5007",
              "latitude": -34.9098,
              "longitude": 138.57081,
              "timezone": "9.50",
              "pax_locations": [
                {
                  "name": "CENTRE",
                  "gates": [{"name": "A"}, {"name": "B"}, {"name": "C"}]
                }
              ]
            }
          ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(VenueListResponse.self, from: json)
        XCTAssertEqual(decoded.venues.count, 1)
        XCTAssertEqual(decoded.venues[0].code, "AEC")
        XCTAssertEqual(decoded.venues[0].paxLocations[0].gates.count, 3)
    }
    
}

// MARK: - Helpers
private extension VenueRepositoryTests {
    func makeSucceedingSUT() -> VenueRepository {
        VenueRepository(networkService: StubNetworkService(response: Venue.mockVenues))
    }

    func makeSUT(throwing error: Error) -> VenueRepository {
        VenueRepository(networkService: StubNetworkService(response: Venue.mockVenues, error: error))
    }
}

