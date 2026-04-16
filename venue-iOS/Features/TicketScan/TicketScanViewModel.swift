//
//  TicketScanViewModel.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

internal import Combine
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

    func loadVenues() async {
        
    }

    func retry() async {
        await loadVenues()
    }
}
