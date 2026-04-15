//
//  VenueAPIModelMock.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

@testable import venue_iOS

extension Venue {
    /// Valid response matching the real API shape.
    static var mockVenues: VenueListResponse {
        VenueListResponse(venues: [
            Venue(
                code: "AEC",
                name: "Adelaide Entertainment Centre",
                address: "Corner Port Road and Adam Street",
                city: "Hindmarsh",
                state: "SA",
                postcode: "5007",
                latitude: -34.9098,
                longitude: 138.57081,
                timezone: "9.50",
                paxLocations: [
                    PaxLocation(name: "CENTRE", gates: [Gate(name: "A"), Gate(name: "B")]),
                ]
            ),
            Venue(
                code: "BEC",
                name: "Brisbane Entertainment Centre",
                address: "Melaleuca Drive",
                city: "Boondall",
                state: "QLD",
                postcode: "4034",
                latitude: -27.34438,
                longitude: 153.07008,
                timezone: "10.00",
                paxLocations: [
                    PaxLocation(name: "PLAYHOUSE", gates: [Gate(name: "1"), Gate(name: "2")]),
                ]
            ),
        ])
    }

    static func mock(code: String, name: String) -> Venue {
        Venue(code: code, name: name, address: "", city: "", state: "", postcode: "", latitude: 0, longitude: 0, timezone: "", paxLocations: [])
    }
}
