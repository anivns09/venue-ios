//
//  MockVenueRepository.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

@testable import venue_iOS
import XCTest

final class MockVenueRepository: VenueRepositoryProtocol {
    var fetchVenuesResult: Result<[Venue], Error> = .success([])
    var scanResult:  Result<TicketScanResult, Error> = .success(TicketScanResult.successResponse)
    var receivedLat: Double?
    var receivedLon: Double?
    var capturedVenueCode: String?
    var capturedBarcode: String?
    
    init(fetchVenuesResult: Result<[Venue], Error> = .success([]),
         scanResult: Result<TicketScanResult, Error> = .success(TicketScanResult.successResponse),
         receivedLat: Double? = nil,
         receivedLon: Double? = nil,
         capturedVenueCode: String? = nil,
         capturedBarcode: String? = nil
    ) {
        self.fetchVenuesResult = fetchVenuesResult
        self.scanResult = scanResult
        self.receivedLat = receivedLat
        self.receivedLon = receivedLon
        self.capturedVenueCode = capturedVenueCode
        self.capturedBarcode = capturedBarcode
    }

    func fetchVenues(latitude: Double, longitude: Double) async throws -> [Venue] {
        receivedLat = latitude
        receivedLon = longitude
        return try fetchVenuesResult.get()
    }
    
    func scanBarcode(venueCode: String, barcode: String) async throws
        -> TicketScanResult
    {
        capturedVenueCode = venueCode
        capturedBarcode = barcode
        return try scanResult.get()
    }
}
