//
//  CodeScannerServiceProtocol.swift
//  CodeScanner
//
//  Created by Anirudh Pandey on 15/4/2026.
//


import VisionKit
import UIKit

// MARK: - Scanner Protocol

@MainActor
public protocol DataScannerProtocol: AnyObject {
    var recognizedItems: AsyncStream<[RecognizedItem]> { get }
    func startScanning() throws
    func stopScanning()
}

// MARK: - Real conformance

/// DataScannerViewController already satisfies the protocol shape —
/// we just need to declare conformance.

@MainActor
extension DataScannerViewController: DataScannerProtocol {}

// MARK: - Service Protocol

@MainActor
public protocol CodeScannerServiceProtocol: AnyObject {
    /// Emits barcode string values as they are recognised.
    
    var isSupported: Bool { get }
    func codesStream() -> AsyncStream<String>
    func stop()
}
