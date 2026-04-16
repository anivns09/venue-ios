//
//  TicketScanUseCaseTests.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreNetworking
import XCTest
@testable import venue_iOS

@MainActor
final class TicketScanUseCaseTests: XCTestCase {
    func testExecuteSuccessResponseReturnsScanResultSuccess() async throws {
        let sut = makeSUT(returning: .success(TicketScanResult.successResponse))

        let result = try await sut.execute(
            venueCode: "BEC",
            barcode: "978562123546"
        )

        if case .success(let response) = result {
            XCTAssertEqual(response, TicketScanResult.successResponse)
        } else {
            XCTFail("Expected .success, got \(result)")
        }
    }

    func testExecuteNonSuccessResultReturnsScanResultRejected() async throws
    {
        let sut = makeSUT(
            returning: .success(TicketScanResult.rejectedResponse)
        )

        let result = try await sut.execute(
            venueCode: "BEC",
            barcode: "978562123546"
        )

        if case .rejected(let status) = result {
            XCTAssertEqual(status, TicketScanResult.rejectedResponse.status)
        } else {
            XCTFail("Expected .rejected, got \(result)")
        }
    }

    func testExecuteEmptyBarcode_throwsEmptyBarcodeError() async {
        let sut = makeSUT(returning: .success(TicketScanResult.successResponse))

        await assertThrows(TicketScanUseCase.ScanError.emptyBarcode) {
            let _ = try await sut.execute(venueCode: "BEC", barcode: "")
        }
    }

    func testExecuteWhitespaceOnlyBarcode_throwsEmptyBarcodeError() async {
        let sut = makeSUT(returning: .success(TicketScanResult.successResponse))

        await assertThrows(TicketScanUseCase.ScanError.emptyBarcode) {
            let _ = try await sut.execute(venueCode: "BEC", barcode: "   ")
        }
    }

    func testExecuteEmptyVenueCodeThrowsEmptyVenueCodeError() async {
        let sut = makeSUT(returning: .success(TicketScanResult.successResponse))

        await assertThrows(TicketScanUseCase.ScanError.emptyVenueCode) {
            let _ = try await sut.execute(venueCode: "", barcode: "978562123546")
        }
    }

    func testExecuteTrimsBarcodeBeforeSending() async throws {
        let spy = MockVenueRepository(
            scanResult: .success(TicketScanResult.successResponse)
        )
        let sut = TicketScanUseCase(repository: spy)

        _ = try await sut.execute(venueCode: "BEC", barcode: "  978562123546  ")

        XCTAssertEqual(spy.capturedBarcode, "978562123546")
    }

    func testExecuteTrimsVenueCodeBeforeSending() async throws {
        let spy = MockVenueRepository(
            scanResult: .success(TicketScanResult.successResponse)
        )
        let sut = TicketScanUseCase(repository: spy)

        _ = try await sut.execute(venueCode: "  BEC  ", barcode: "978562123546")

        XCTAssertEqual(spy.capturedVenueCode, "BEC")
    }

    func testExecutePropagatesNetworkError() async {
        let error = NetworkService.NetworkError.httpError(statusCode: 401)
        let sut = makeSUT(returning: .failure(error))

        do {
            _ = try await sut.execute(venueCode: "BEC", barcode: "978562123546")
            XCTFail("Expected error")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .httpError(statusCode: 401))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
   
}

// MARK: - Helpers
private extension TicketScanUseCaseTests {
    func makeSUT(returning response: Result<TicketScanResult, Error>)
        -> TicketScanUseCase
    {
        TicketScanUseCase(
            repository: MockVenueRepository(scanResult: response)
        )
    }

    func assertThrows<E: Error & Equatable>(
        _ expected: E,
        block: () async throws -> Void
    ) async {
        do {
            try await block()
            XCTFail("Expected \(expected) to be thrown")
        } catch let error as E {
            XCTAssertEqual(error, expected)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
