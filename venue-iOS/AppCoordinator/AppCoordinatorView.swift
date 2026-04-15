//
//  AppCoordinatorView.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

internal import Combine
import SwiftUI

struct AppCoordinatorView<C: AppCoordinatorProtocol>: View {
    @ObservedObject var coordinator: C

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            introView
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .intro:
                        introView
                    case .list:
                        VenueListView()
                            .navigationBarBackButtonHidden(true)
                    case .scanner:
                        VenueListView()
                    }
                }
        }
    }
}

private extension AppCoordinatorView {
    var introView: some View {
        IntroView {
            coordinator.push(.list)
        }
    }
}

#Preview {
    var coordinator = AppCoordinator()
    AppCoordinatorView(coordinator: coordinator)
}
