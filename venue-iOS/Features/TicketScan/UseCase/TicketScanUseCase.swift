//
//  TicketScanUseCase.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import CoreLocation
import Foundation

protocol TicketScanUseCaseProtocol {
    func execute(venueCode: String, barcode: String) async throws -> ScanResult
}

final class TicketScanUseCase: TicketScanUseCaseProtocol {
    enum ScanError: Error, Equatable {
        case emptyBarcode
        case emptyVenueCode
    }

    private let repository: VenueRepositoryProtocol

    init(repository: VenueRepositoryProtocol = VenueRepository()) {
        self.repository = repository
    }

    func execute(venueCode: String, barcode: String) async throws -> ScanResult {
        let trimmedVenue   = venueCode.trimmingCharacters(in: .whitespaces)
        let trimmedBarcode = barcode.trimmingCharacters(in: .whitespaces)

        guard !trimmedVenue.isEmpty   else { throw ScanError.emptyVenueCode }
        guard !trimmedBarcode.isEmpty else { throw ScanError.emptyBarcode   }

        let response = try await repository.scanBarcode(
            venueCode: trimmedVenue,
            barcode:   trimmedBarcode
        )

        return response.result == "SUCCESS"
            ? .success(response)
            : .rejected(status: response.status)
    }
}
