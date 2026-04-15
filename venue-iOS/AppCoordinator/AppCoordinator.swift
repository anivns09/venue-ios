//
//  AppCoordinator.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

internal import Combine
import SwiftUI

enum AppRoute: Hashable {
    case intro
    case list
    case scanner
}

protocol AppCoordinatorProtocol: ObservableObject {
    var path: NavigationPath { get set }
    func push(_ route: AppRoute)
    func pop()
    func popToRoot()
}

// MARK: - Coordinator

final class AppCoordinator: AppCoordinatorProtocol {
    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
