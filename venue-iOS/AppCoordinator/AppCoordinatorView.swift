//
//  AppCoordinatorView.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import SwiftUI

@MainActor
struct AppCoordinatorView<C: AppCoordinatorProtocol>: View {
    @ObservedObject var coordinator: C
    private let viewFactory: AppViewFactory

    init(coordinator: C, viewFactory: AppViewFactory) {
        self.coordinator = coordinator
        self.viewFactory = viewFactory
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            viewFactory.introView(coordinator: coordinator)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .intro:
                        viewFactory.introView(coordinator: coordinator)
                    case .list:
                        viewFactory.venueListView(coordinator: coordinator)
                    case let .ticketScanner(venueCode):
                        viewFactory.ticketScannerView(venueCode: venueCode)
                    }
                }
        }
    }
}

#Preview {
    var coordinator = AppCoordinator()
    AppCoordinatorView(coordinator: coordinator, viewFactory: AppViewFactory())
}
