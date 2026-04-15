//
//  VenuAPIModels.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import Foundation

struct VenueListResponse: Decodable {
    let venues: [Venue]
}

// MARK: - Venue

struct Venue: Decodable, Identifiable, Hashable {
    let code: String
    let name: String
    let address: String
    let city: String
    let state: String
    let postcode: String
    let latitude: Double
    let longitude: Double
    /// Raw string from API e.g. "9.50" → UTC+9:30 (Adelaide).
    let timezone: String
    let paxLocations: [PaxLocation]

    /// Identifiable — `code` is unique per venue (e.g. "AEC", "BEC").
    var id: String {
        code
    }

    enum CodingKeys: String, CodingKey {
        case code, name, address, city, state, postcode
        case latitude, longitude, timezone
        case paxLocations = "pax_locations"
    }
}

struct PaxLocation: Decodable, Hashable {
    let name: String
    let gates: [Gate]
}

struct Gate: Decodable, Hashable {
    let name: String
}
