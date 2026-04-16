//
//  TicketScanViewModel.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import Combine
import CodeScanner
import CoreUtils
import SwiftUI

class TicketScanViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case scanning
        case loading
        case scanned(String)
        case loaded(ScanResult)
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    private let scanUseCase: TicketScanUseCaseProtocol
    private let venueCode: String
    private let service: CodeScannerServiceProtocol

    init(venueCode: String, scanUseCase: TicketScanUseCaseProtocol, service: CodeScannerServiceProtocol) {
        self.scanUseCase = scanUseCase
        self.venueCode = venueCode
        self.service = service
    }

    func checkTicket(barCode: String) async throws {
        state = .loading
        let scanResult = try await scanUseCase.execute(venueCode: venueCode, barcode: barCode)
        state = .loaded(scanResult)
    }

    func startScanning() async {
        guard service.isSupported else {
            state = .failed("Camera Unaivailable")
            return
        }

        state = .scanning

        for await code in service.codesStream() {
            state = .scanned(code)
            try? await Task.sleep(for: .milliseconds(800))
            service.stop()
            return
        }

        // Stream finished without a scan (stop() was called externally).
        if case .scanning = state { state = .idle }
    }

    func stop() {
        service.stop()
        state = .idle
    }
}
