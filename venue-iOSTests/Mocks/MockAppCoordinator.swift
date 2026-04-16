//
//  MockAppCoordinator.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 16/4/2026.
//

@testable import venue_iOS
import Combine
import SwiftUI

final class MockAppCoordinator: AppCoordinatorProtocol {

    @Published var path = NavigationPath()
    private(set) var pushedRoutes: [AppRoute] = []
    private(set) var popCalled = false
    private(set) var popToRootCalled = false

    func push(_ route: AppRoute) {
        pushedRoutes.append(route)
        path.append(route)
    }

    func pop() {
        popCalled = true
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        popToRootCalled = true
        path.removeLast(path.count)
    }
}
