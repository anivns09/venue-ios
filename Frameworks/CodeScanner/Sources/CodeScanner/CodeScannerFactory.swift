//
//  CodeScannerFactory.swift
//  CodeScanner
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import VisionKit
import Vision

@MainActor
public enum CodeScannerFactory {
    private static var shared: DataScannerViewController?

    public static func make() -> DataScannerViewController {
        if let shared { return shared }
        let scanner = DataScannerViewController(
            recognizedDataTypes: [
                .barcode(symbologies: [
                    .ean8, .ean13, .pdf417, .qr,
                    .code128, .code39, .code93,
                    .upce, .aztec, .itf14, .dataMatrix
                ])
            ],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        self.shared = scanner
        return scanner
    }
}
