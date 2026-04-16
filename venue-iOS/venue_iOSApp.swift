//
//  venue_iOSApp.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import SwiftUI

@main
struct venue_iOSApp: App {
    @StateObject private var coordinator = AppCoordinator()
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator, viewFactory: AppViewFactory())
        }
    }
}
