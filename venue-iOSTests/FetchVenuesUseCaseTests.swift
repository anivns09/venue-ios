//
//  FetchVenuesUseCaseTests.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import XCTest
import CoreNetworking
@testable import venue_iOS

@MainActor
final class FetchVenuesUseCaseTests: XCTestCase {
    private var mockRepository: MockVenueRepository!
    private var useCase: FetchVenuesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockVenueRepository()
        useCase = FetchVenuesUseCase(repository: mockRepository)
    }

    func testExecuteReturnsSortedVenuesByDistance() async throws {
        let venues = [
            Venue.mock(code: "1", name: "A", latitude: 10.0, longitude: 10.0),
            Venue.mock(code: "2", name: "B", latitude: 20.0, longitude: 20.0)
        ]
        mockRepository.fetchVenuesResult = .success(venues)

        let result = try await useCase.execute(latitude: 11.0, longitude: 11.0)
        XCTAssertEqual(result.first?.id, "1")
        XCTAssertEqual(result.last?.id, "2")
    }

    func testExecuteThrowsEmptyDataErrorWhenNoVenues() async {
        mockRepository.fetchVenuesResult = .success([])

        do {
            _ = try await useCase.execute(latitude: 0, longitude: 0)
            XCTFail("Expected to throw VenueError.emptyData")
        } catch let error as VenueError {
            XCTAssertEqual(error, .emptyData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExecuteThrowsErrorWhenRepositoryReturnsError() async {
        // This could be any error.
        let decodeError = NetworkService.NetworkError.decodingError
        mockRepository.fetchVenuesResult = .failure(decodeError)

        do {
            _ = try await useCase.execute(latitude: 0, longitude: 0)
            XCTFail("Expected to throw VenueError.emptyData")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .decodingError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
