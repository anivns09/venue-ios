//
//  AppCoordinatorTests.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 16/4/2026.
//

import SwiftUI
import XCTest
@testable import venue_iOS

@MainActor
final class AppCoordinatorTests: XCTestCase {
    func testInitStartsWithEmptyPath() {
        let coordinator = AppCoordinator()

        XCTAssertTrue(coordinator.path.isEmpty)
        XCTAssertEqual(coordinator.path.count, 0)
    }

    func testPushAddsRouteToPath() {
        let coordinator = AppCoordinator()

        coordinator.push(.intro)

        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertFalse(coordinator.path.isEmpty)
    }

    func testPopRemovesLastRoute() {
        let coordinator = AppCoordinator()

        coordinator.push(.intro)
        coordinator.push(.list)
        coordinator.pop()

        XCTAssertEqual(coordinator.path.count, 1)
    }

    func testPopOnEmptyDoesNothing() {
        let coordinator = AppCoordinator()

        coordinator.pop()

        XCTAssertTrue(coordinator.path.isEmpty)
    }

    func testPopToRootClearsAllRoutes() {
        let coordinator = AppCoordinator()

        coordinator.push(.intro)
        coordinator.push(.list)
        coordinator.push(.ticketScanner(venueCode: "ABC"))
        coordinator.popToRoot()

        XCTAssertTrue(coordinator.path.isEmpty)
        XCTAssertEqual(coordinator.path.count, 0)
    }
}
