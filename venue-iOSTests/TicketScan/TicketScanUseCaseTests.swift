//
//  TicketScanUseCaseTests.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreNetworking
import XCTest
@testable import venue_iOS

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

    func test_execute_nonSuccessResult_returnsScanResultRejected() async throws
    {
        let sut = makeSUT(returning: .success(TicketScanResult.rejectedResponse))

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

    // MARK: - Validation

    func test_execute_emptyBarcode_throwsEmptyBarcodeError() async {
        let sut = makeSUT(returning: .success(TicketScanResult.successResponse))

        await assertThrows(TicketScanUseCase.ScanError.emptyBarcode) {
            try await sut.execute(venueCode: "BEC", barcode: "")
        }
    }

    func test_execute_whitespaceOnlyBarcode_throwsEmptyBarcodeError() async {
        let sut = makeSUT(returning: .success(TicketScanResult.successResponse))

        await assertThrows(TicketScanUseCase.ScanError.emptyBarcode) {
            try await sut.execute(venueCode: "BEC", barcode: "   ")
        }
    }

    func test_execute_emptyVenueCode_throwsEmptyVenueCodeError() async {
        let sut = makeSUT(returning: .success(TicketScanResult.successResponse))

        await assertThrows(TicketScanUseCase.ScanError.emptyVenueCode) {
            try await sut.execute(venueCode: "", barcode: "978562123546")
        }
    }

    func test_execute_trimsBarcodeBeforeSending() async throws {
        let spy = MockVenueRepository(scanResult: .success(TicketScanResult.successResponse))
        let sut = TicketScanUseCase(repository: spy)

        _ = try await sut.execute(venueCode: "BEC", barcode: "  978562123546  ")

        XCTAssertEqual(spy.capturedBarcode, "978562123546")
    }

    func test_execute_trimsVenueCodeBeforeSending() async throws {
        let spy = MockVenueRepository(scanResult: .success(TicketScanResult.successResponse))
        let sut = TicketScanUseCase(repository: spy)

        _ = try await sut.execute(venueCode: "  BEC  ", barcode: "978562123546")

        XCTAssertEqual(spy.capturedVenueCode, "BEC")
    }

    // MARK: - Error propagation

    func test_execute_propagatesNetworkError() async {
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

    // MARK: - Helpers

    private func makeSUT(returning response: Result<TicketScanResult, Error>) -> TicketScanUseCase
    {
        TicketScanUseCase(
            repository: MockVenueRepository(scanResult: response)
        )
    }

    private func assertThrows<E: Error & Equatable>(
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
