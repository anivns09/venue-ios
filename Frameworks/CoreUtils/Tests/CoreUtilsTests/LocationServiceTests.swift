//
//  LocationServiceTests.swift
//  CoreUtils
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import XCTest
@testable import CoreUtils
import CoreLocation

final class LocationServiceTests: XCTestCase {

    func testShouldReturnSuccessWhenRequestLocation() async throws {
        let mock = MockLocationManager()
        mock.stubbedStatus = .authorizedWhenInUse
        mock.onRequestLocation = {
            mock.simulateLocationUpdate(lat: -33.8688, lon: 151.2093)
        }
        let sut = LocationService(manager: mock)

        let coord = try await sut.requestLocation()

        XCTAssertEqual(coord.latitude,  -33.8688, accuracy: 0.0001)
        XCTAssertEqual(coord.longitude, 151.2093, accuracy: 0.0001)
        XCTAssertTrue(mock.didRequestLocation)
    }
    
    func testShouldReturnDeniedBeforeRequestWhenRequestLocation() async {
        let mock = MockLocationManager()
        mock.stubbedStatus = .denied
        let sut = LocationService(manager: mock)

        do {
            _ = try await sut.requestLocation()
            XCTFail("Expected permissionDenied")
        } catch let error as LocationError {
            XCTAssertEqual(error, .permissionDenied)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertFalse(mock.didRequestLocation)
    }
    
    func testShouldReturDidRequestAuthorizationWhenRequestLocationAndStatusIsNotDetermined() async throws {
        let mock = MockLocationManager()
        mock.stubbedStatus = .notDetermined

        // Change to authorised then fire a location so the continuation resolves.
        mock.onRequestLocation = {
            mock.simulateLocationUpdate(lat: 0, lon: 0)
        }

        // Manually bump status so requestLocation() doesn't throw
        mock.stubbedStatus = .authorizedWhenInUse

        let sut = LocationService(manager: mock)
        _ = try await sut.requestLocation()

        XCTAssertTrue(mock.didRequestAuthorization)
    }

    func testShouldReturnCoreLocationFailureWhenRequestLocation() async {
        let mock = MockLocationManager()
        mock.stubbedStatus = .authorizedWhenInUse
        let expectedError = CLError(.locationUnknown)

        mock.onRequestLocation = {
            mock.simulateFailure(error: expectedError)
        }
        let sut = LocationService(manager: mock)

        do {
            _ = try await sut.requestLocation()
            XCTFail("Expected CLError")
        } catch let error as CLError {
            XCTAssertEqual(error.code, .locationUnknown)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testShouldReturnDeniedDuringRequestWhenRequestLocation() async {
        let mock = MockLocationManager()
        mock.stubbedStatus = .authorizedWhenInUse

        mock.onRequestLocation = {
            mock.simulateAuthorizationChange(to: .denied)
        }
        let sut = LocationService(manager: mock)

        do {
            _ = try await sut.requestLocation()
            XCTFail("Expected permissionDenied")
        } catch let error as LocationError {
            XCTAssertEqual(error, .permissionDenied)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

