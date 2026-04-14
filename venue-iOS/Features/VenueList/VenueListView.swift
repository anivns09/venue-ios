//
//  VenueListView.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import SwiftUI

struct VenueListView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 75)
            Text("Venu List")
                .font(.largeTitle)
                .bold()
                .padding(.top, 16)
            Spacer()
        }
        .padding()
    }
}
