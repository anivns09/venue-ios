//
//  TickOverlayView.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 16/4/2026.
//

import SwiftUI

struct TickOverlayView: View {
    @Binding var isVisible: Bool

    @State private var animateCircle = false
    @State private var animateCheck = false
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Optional dim background
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .foregroundColor(.green)
                    .frame(width: 200, height: 200)
                    .scaleEffect(animateCircle ? 1 : 0.8)
                    .opacity(animateCircle ? 1 : 0)

                CheckmarkShape()
                    .trim(from: 0, to: animateCheck ? 1 : 0)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.green)
                    .frame(width: 100, height: 100)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            playAnimation()
        }
        .onChange(of: isVisible) { visible in
            if visible {
                playAnimation()
            }
        }
    }

    private func playAnimation() {
        scale = 0.6
        opacity = 0
        animateCircle = false
        animateCheck = false

        withAnimation(.easeOut(duration: 0.3)) {
            scale = 1.0
            opacity = 1
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            animateCircle = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            animateCheck = true
        }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.2,
                             y: rect.midY))

        path.addLine(to: CGPoint(x: rect.midX,
                                 y: rect.maxY * 0.75))

        path.addLine(to: CGPoint(x: rect.maxX * 0.8,
                                 y: rect.minY + rect.height * 0.25))

        return path
    }
}
