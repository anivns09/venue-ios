//
//  CodeScannerTests.swift
//  CodeScanner
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import XCTest
import VisionKit
@testable import CodeScanner

@MainActor
final class CodeScannerTests: XCTestCase {
    private var scanner: FakeDataScanner!
    private var sut: CodeScannerService!

    override func setUp() async throws {
        try await super.setUp()
        scanner = FakeDataScanner()
        sut = CodeScannerService(scanner: scanner)
    }

    override func tearDown() async throws {
        sut.stop()
        sut     = nil
        scanner = nil
        try await super.tearDown()
    }

    func testCodesStreamCallsStartScanning() {
        _ = sut.codesStream()
        XCTAssertEqual(scanner.startScanningCallCount, 1)
    }

    func testStopCallsStopScanning() {
        _ = sut.codesStream()
        sut.stop()
        XCTAssertEqual(scanner.stopScanningCallCount, 1)
    }

    func testStopFinishesStream() async {
        let stream = sut.codesStream()
        var received: [String] = []
        let task = Task { @MainActor in
            for await code in stream {
                received.append(code)
            }
        }
        sut.stop()
        await task.value
        XCTAssertTrue(received.isEmpty)
    }

    func testStopBeforeCodesStreamDoesNotCrash() {
        XCTAssertNoThrow(sut.stop())
    }

    func testCodesStreamWhenStartThrowsFinishesImmediately() async {
        scanner.shouldThrowOnStart = true
        var received: [String] = []
        for await code in sut.codesStream() {
            received.append(code)
        }
        XCTAssertTrue(received.isEmpty)
    }

    func testCallingCodesStreamTwiceStopsFirstSession() {
        _ = sut.codesStream()
        _ = sut.codesStream()
        XCTAssertEqual(scanner.stopScanningCallCount, 1)
        XCTAssertEqual(scanner.startScanningCallCount, 2)
    }

    func testCancellingConsumerTaskStopsScanner() async {
        let stream = sut.codesStream()
        let task = Task { @MainActor in
            for await _ in stream { }
        }
        task.cancel()
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(scanner.stopScanningCallCount, 1)
    }

    func testCodesStreamEmitsError() async {
        scanner.shouldThrowOnStart = true
        var received: [String] = []
        for await code in sut.codesStream() {
            received.append(code)
            XCTAssertTrue(received.isEmpty)
        }
    }
}

