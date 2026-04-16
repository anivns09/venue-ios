//
//  TicketScanViewModelTests.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 16/4/2026.
//

import CoreNetworking
import CodeScanner
import XCTest
import Combine
@testable import venue_iOS

final class MockTicketScanUseCase: TicketScanUseCaseProtocol {
    var received: (venueCode: String, barcode: String)?
    var resultProvider: () -> ScanResult = { fatalError("No result provided") }

    func execute(venueCode: String, barcode: String) async throws -> ScanResult {
        received = (venueCode, barcode)
        return resultProvider()
    }
}

final class MockCodeScannerService: CodeScannerServiceProtocol {
    var isSupported: Bool
    private(set) var stopCalled = false
    private var continuation: AsyncStream<String>.Continuation?

    init(isSupported: Bool) {
        self.isSupported = isSupported
    }

    func codesStream() -> AsyncStream<String> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }

    func emit(_ code: String) {
        continuation?.yield(code)
    }

    func stop() {
        stopCalled = true
        continuation?.finish()
    }

    func waitForStreamReady(timeoutMilliseconds: UInt64 = 200) async -> Bool {
        let timeout = Date().addingTimeInterval(Double(timeoutMilliseconds) / 1000.0)
        while continuation == nil && Date() < timeout {
            try? await Task.sleep(for: .milliseconds(5))
        }
        return continuation != nil
    }

    func waitForStopCalled(timeoutMilliseconds: UInt64 = 1200) async -> Bool {
        let timeout = Date().addingTimeInterval(Double(timeoutMilliseconds) / 1000.0)
        while !stopCalled && Date() < timeout {
            try? await Task.sleep(for: .milliseconds(10))
        }
        return stopCalled
    }
}

@MainActor
final class TicketScanViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    private var useCase: MockTicketScanUseCase!
    private var service: MockCodeScannerService!

    func testStartScanningWhenUnsupportedSetsFailedState() async {
        let service = MockCodeScannerService(isSupported: false)
        let useCase = MockTicketScanUseCase()
        let viewModel = TicketScanViewModel(
            venueCode: "VENUE",
            scanUseCase: useCase,
            service: service
        )

        await viewModel.startScanning()

        XCTAssertEqual(viewModel.state, .failed("Camera Unaivailable"))
    }

    func testStartScanningEmitsScannedStateAndStopsService() async {
        let service = MockCodeScannerService(isSupported: true)
        let useCase = MockTicketScanUseCase()
        let viewModel = TicketScanViewModel(
            venueCode: "VENUE",
            scanUseCase: useCase,
            service: service
        )

        let scannedExpectation = expectation(description: "scanned")
        let stateTask = Task {
            for await state in viewModel.$state.values {
                if case let .scanned(code) = state {
                    XCTAssertEqual(code, "12345")
                    scannedExpectation.fulfill()
                    break
                }
            }
        }

        Task { await viewModel.startScanning() }
        let isStreamReady = await service.waitForStreamReady()
        XCTAssertTrue(isStreamReady)
        service.emit("12345")

        await fulfillment(of: [scannedExpectation], timeout: 1.0)
        stateTask.cancel()
        let didStop = await service.waitForStopCalled()
        XCTAssertTrue(didStop)
    }

    func testStopSetsIdleAndStopsService() async {
        let service = MockCodeScannerService(isSupported: true)
        let useCase = MockTicketScanUseCase()
        let viewModel = TicketScanViewModel(
            venueCode: "VENUE",
            scanUseCase: useCase,
            service: service
        )

        Task { await viewModel.startScanning() }
        try? await Task.sleep(for: .milliseconds(50))
        viewModel.stop()

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertTrue(service.stopCalled)
    }
}
