//
//  VenueListView.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import SwiftUI

struct VenueListView: View {
    @StateObject var viewModel: VenueListViewModel

    var body: some View {
        content
            .navigationTitle("Nearby Venues")
            .task { await viewModel.loadVenues() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear

        case .loading:
            ProgressView("Finding venues…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .loaded(venues):
            let _ = print("Ani: Loaded \(venues.count) venues")
            venueList(venues)

        case let .failed(message):
            let _ = print("Ani: Loaded Error \(message)")
            errorView(message)
        }
    }

    private func venueList(_ venues: [Venue]) -> some View {
        List(venues) { venue in
            VenueRowView(venue: venue)
        }
    }

    private func errorView(_ message: String) -> some View {
        ErrorView(actionTitle: "Try again", message: message) {
            Task {
                await viewModel.loadVenues()
            }
        }
    }
}

// MARK: - Row

struct VenueRowView: View {
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(venue.name)
                .font(.headline)
            Text("\(venue.city), \(venue.state)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(venue.address)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
