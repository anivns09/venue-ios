//
//  ScanResult.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

enum ScanResult: Equatable {
    case success(TicketScanResult)
    case rejected(status: String)

    var isSuccess: Bool {
        if case .success(let r) = self { return r.result == "SUCCESS" }
        return false
    }
}
