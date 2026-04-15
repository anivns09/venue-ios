//
//  VenueListViewModel.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

internal import Combine
import CoreLocation
import CoreNetworking
import CoreUtils
import SwiftUI

class VenueListViewModel: ObservableObject {
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var error: Error?
    @Published var isLoading = false
    private var venueFetcher: FetchVenuesUseCaseProtocol
    private let locationService: LocationServiceProtocol

    init(venueFetcher: FetchVenuesUseCaseProtocol, locationService: LocationServiceProtocol = LocationService()) {
        self.venueFetcher = venueFetcher
        self.locationService = locationService
    }

    func fetchLocation() async {
        print("Ani: fetching location")
        isLoading = true
        defer { isLoading = false }
        do {
            coordinate = try await locationService.requestLocation()

            let list = try await venueFetcher.execute(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
            print("Ani: list \(list)")

        } catch is CancellationError {
            // silently ignore — user navigated away
            print("Ani: fetching CancellationError")
        } catch {
            self.error = error
            print("Ani:  error \(error)")
        }
    }
}
