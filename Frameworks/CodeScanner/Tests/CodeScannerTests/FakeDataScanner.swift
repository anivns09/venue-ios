//
//  FakeDataScanner.swift
//  CodeScanner
//
//  Created by Anirudh Pandey on 15/4/2026.
//

@testable import CodeScanner
import VisionKit

@MainActor
final class FakeDataScanner: DataScannerProtocol {
    var recognizedItems: AsyncStream<[RecognizedItem]> {
        AsyncStream { continuation in
            // For a fake, just finish the stream immediately.
            continuation.finish()
        }
    }
    var startScanningCallCount = 0
    var stopScanningCallCount = 0
    var shouldThrowOnStart = false

    private(set) var isScanning = false

    func startScanning() throws {
        startScanningCallCount += 1
        if shouldThrowOnStart {
            throw NSError(domain: "FakeDataScanner", code: 1)
        }
        isScanning = true
    }

    func stopScanning() {
        stopScanningCallCount += 1
        isScanning = false
    }
}
