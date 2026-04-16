//
//  AppViewFactory.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 16/4/2026.
//

import CodeScanner
import CoreUtils
import SwiftUI

@MainActor
struct AppViewFactory {
    private let codeScannerService: CodeScannerService

    init() {
        self.codeScannerService = CodeScannerService(scanner: CodeScannerFactory.make())
    }

    init(dataScanner: DataScannerProtocol) {
        self.codeScannerService = CodeScannerService(scanner: dataScanner)
    }

    func introView(coordinator: some AppCoordinatorProtocol) -> AnyView {
        AnyView(
            IntroView {
                coordinator.push(.list)
            }
        )
    }

    func venueListView(coordinator: some AppCoordinatorProtocol) -> AnyView {
        let viewModel = VenueListViewModel(
            appCoordinator: coordinator,
            venueFetcher: FetchVenuesUseCase(),
            locationService: LocationService()
        )
        return AnyView(
            VenueListView(viewModel: viewModel)
                .navigationBarBackButtonHidden(true)
        )
    }

    func ticketScannerView(venueCode: String) -> AnyView {
        let viewModel = TicketScanViewModel(
            venueCode: venueCode,
            scanUseCase: TicketScanUseCase(),
            service: codeScannerService
        )
        return AnyView(TicketScanView(viewModel: viewModel))
    }
}
