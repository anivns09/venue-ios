//
//  TicketScanResultMock.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

@testable import venue_iOS

extension TicketScanResult {
    static var successResponse: TicketScanResult {
        TicketScanResult(
            status: "0 Valid Ticket GOOD",
            action: "ENTRY",
            result: "SUCCESS",
            concession: 1
        )
    }

    static var rejectedResponse: TicketScanResult {
        TicketScanResult(
            status: "0 Invalid Ticket",
            action: "ENTRY",
            result: "FAIL",
            concession: 0
        )
    }
}
