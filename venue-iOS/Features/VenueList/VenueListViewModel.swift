//
//  VenueListViewModel.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import Combine
import CoreLocation
import CoreUtils
import SwiftUI

class VenueListViewModel: ObservableObject {
    enum VenueListState: Equatable {
        case idle
        case loading
        case loaded([Venue])
        case failed(String)
    }

    @Published private(set) var state: VenueListState = .idle
    private let venueFetcher: FetchVenuesUseCaseProtocol
    private let locationService: LocationServiceProtocol
    private var appCoordinator: any AppCoordinatorProtocol

    init(appCoordinator: any AppCoordinatorProtocol, venueFetcher: FetchVenuesUseCaseProtocol, locationService: LocationServiceProtocol = LocationService()) {
        self.appCoordinator = appCoordinator
        self.venueFetcher = venueFetcher
        self.locationService = locationService
    }

    func loadVenues() async {
        state = .loading
        do {
            let coordinate = try await locationService.requestLocation()
            let venues = try await venueFetcher.execute(latitude: coordinate.latitude, longitude: coordinate.longitude)
            state = .loaded(venues)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func didSelectVenue(_ venueCode: String) {
        appCoordinator.push(.ticketScanner(venueCode: venueCode))
    }

    func retry() async {
        await loadVenues()
    }
}
