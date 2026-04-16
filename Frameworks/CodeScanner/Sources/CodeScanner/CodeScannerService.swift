//
//  CodeScannerService.swift
//  CodeScanner
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import VisionKit
import UIKit
import Vision

@MainActor
public final class CodeScannerService: CodeScannerServiceProtocol {
    private let scanner: DataScannerProtocol
    private var continuation: AsyncStream<String>.Continuation?
    private var observationTask: Task<Void, Never>?
    private var isScanning = false

    // MARK: Init

    /// - Parameter scanner: injectable for testing; defaults to a live scanner.

    init(scanner: DataScannerProtocol) {
        self.scanner = scanner
    }

    // MARK: CodeScannerServiceProtocol

    /// Returns a stream of decoded barcode strings.
    /// The stream stays open until `stop()` is called or the task is cancelled.
    public func codesStream() -> AsyncStream<String> {
        stopInternal()

        let stream = AsyncStream<String> { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in self?.stopInternal() }
            }
        }

        do {
            try scanner.startScanning()
            isScanning = true
        } catch {
            continuation?.finish()
            return stream
        }

        observationTask = Task { [weak self] in
            guard let self else { return }
            await self.observe()
        }

        return stream
    }

    public func stop() {
        stopInternal()
    }
    
}

private extension CodeScannerService {
    func observe() async {
        // `recognizedItems` is a native AsyncStream — no delegate boilerplate needed.
        for await items in scanner.recognizedItems {
            guard let continuation else { break }
            for item in items {
                if case .barcode(let barcode) = item,
                   let payload = barcode.payloadStringValue {
                    continuation.yield(payload)
                }
            }
        }
    }

    func stopInternal() {
        observationTask?.cancel()
        observationTask = nil
        if isScanning {
            scanner.stopScanning()
            isScanning = false
        }
        continuation?.finish()
        continuation = nil
    }
}
