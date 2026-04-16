//
//  VenueListViewModelTests.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import XCTest
import CoreUtils
import CoreLocation
import Combine
import SwiftUI
@testable import venue_iOS

@MainActor
final class VenueListViewModelTests: XCTestCase {
    private var mockRepository: MockVenueRepository!
    private var fetcher: FetchVenuesUseCase!
    private var locationService: MockLocationService!
    private var sut: VenueListViewModel!
    private var appCoordinator: MockAppCoordinator!

    override func setUp() {
        super.setUp()
        mockRepository = MockVenueRepository()
        mockRepository.fetchVenuesResult = .success([Venue.mock(code: "1", name: "Test Venue")])
        fetcher = FetchVenuesUseCase(repository: mockRepository)
        locationService = MockLocationService()
        appCoordinator = MockAppCoordinator()
        sut = VenueListViewModel(appCoordinator: appCoordinator, venueFetcher: fetcher, locationService: locationService)
    }

    func testLoadVenuesSuccess() async {
        await sut.loadVenues()

        if case .loaded(let venues) = sut.state {
            XCTAssertEqual(venues.count, 1)
            XCTAssertEqual(venues.first?.name, "Test Venue")
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func testLoadVenuesLocationFailure() async {
        locationService.shouldThrow = true

        await sut.loadVenues()

        if case .failed(let message) = sut.state {
            XCTAssertTrue(message.contains("Location failed"))
        } else {
            XCTFail("Expected failed state")
        }
    }

    func testLoadVenuesFetchFailure() async {
        mockRepository.fetchVenuesResult = .failure(MockError.mock)

        await sut.loadVenues()

        XCTAssertTrue({
            if case .failed = sut.state { return true }
            return false
        }(), "Expected failed state")
    }

    func testLoadVenuesFetchFailureWhenVenueListEmpty() async {
        mockRepository.fetchVenuesResult = .failure(VenueError.emptyData)

        await sut.loadVenues()

        XCTAssertTrue({
            if case .failed = sut.state { return true }
            return false
        }(), "Expected failed state")
    }

    func testRetryCallsLoadVenues() async {
        mockRepository.fetchVenuesResult = .success([Venue.mock(code: "2", name: "Retry Venue")])
        
        await sut.retry()

        if case .loaded(let venues) = sut.state {
            XCTAssertEqual(venues.first?.name, "Retry Venue")
        } else {
            XCTFail("Expected loaded state after retry")
        }
    }

    func testDidSelectVenuePushesTicketScannerRoute() {
        XCTAssertEqual(appCoordinator.pushedRoutes.count, 0)
        
        sut.didSelectVenue("VENUE-123")

        XCTAssertEqual(appCoordinator.pushedRoutes.count, 1)
        XCTAssertEqual(appCoordinator.pushedRoutes.first, .ticketScanner(venueCode: "VENUE-123"))
    }
}

private enum MockError: Error {
    case mock
}
