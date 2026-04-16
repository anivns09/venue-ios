//
//  TicketScanView.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import SwiftUI

struct TicketScanView: View {

    var body: some View {
        VStack {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 75)
            Text("Welcome to TICKETEK")
                .font(.largeTitle)
                .bold()
                .padding(.top, 16)
            Spacer()
        }
        .padding()
        .task {
            
        }
    }
}

