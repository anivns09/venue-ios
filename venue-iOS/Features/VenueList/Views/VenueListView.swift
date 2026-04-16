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
            .navigationTitle("ListViewTitle")
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
            venueList(venues)

        case let .failed(message):
            errorView(message)
        }
    }

    private func venueList(_ venues: [Venue]) -> some View {
        List(venues) { venue in
            Button {
                viewModel.didSelectVenue(venue.code)
            } label: {
                VenueRowView(venue: venue)
            }
            .buttonStyle(.plain)
        }
    }

    private func errorView(_ message: String) -> some View {
        ErrorView(actionTitle: "tryAgain", message: message) {
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
        VStack(alignment: .center, spacing: 4) {
            Text(venue.name)
                .multilineTextAlignment(.center)
                .font(.headline)
            Text("\(venue.city), \(venue.state)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}
