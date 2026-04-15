//
//  TicketScanResult.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

// MARK: Request Body
struct ScanRequest: Encodable {
    let barcode: String
}

// MARK: - Response

struct TicketScanResult: Decodable, Equatable {
    let status: String
    let action: String
    let result: String
    let concession: Int
}
