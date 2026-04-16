//
//  TicketScanView.swift
//  venue-iOS
//
//  Created by Anirudh Pandey on 15/4/2026.
//

import SwiftUI
import CodeScanner
import VisionKit

struct TicketScanView: View {
    enum Metrics {
        static let delayToHideTick: TimeInterval = 5
    }

    @StateObject var viewModel: TicketScanViewModel
    // Card dimensions
    private let cardWidth:  CGFloat = 320
    private let cardHeight: CGFloat = 440
    private let cornerRadius: CGFloat = 24
    @State var shouldShowSuccessAlert: Bool = false

    var body: some View {
        ZStack {
            card
        }
        .navigationTitle("Scan Ticket")
        .task { await viewModel.startScanning() }
        .onChange(of: viewModel.state) { newState in
            guard case let .scanned(barCode) = newState else { return }
            Task {
                try? await viewModel.checkTicket(barCode: barCode)
            }
        }
    }
}

private struct DataScannerRepresentable: UIViewControllerRepresentable {

    let viewController: DataScannerViewController

    func makeUIViewController(context: Context) -> DataScannerViewController {
        return viewController  // return shared instance, never create a new one
    }

    func updateUIViewController(_ vc: DataScannerViewController, context: Context) {}
}

extension TicketScanView {
    private var card: some View {
        ZStack {
            switch viewModel.state {
            case let .failed(message):
                errorView(message)
            case .scanning, .idle:
                DataScannerRepresentable(viewController: CodeScannerFactory.make())
                overlayLayer
            case .loading:
                ProgressView("Checking Ticket")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .scanned:
                ProgressView("Checking Ticket")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .loaded(result):
                Group {
                    if result.isSuccess {
                        TickOverlayView(isVisible: $shouldShowSuccessAlert)
                    } else {
                        errorView("Ticket Not Valid")
                    }
                }
                .task {
                    print("Ani: ticket result loaded: \(result)")
                    shouldShowSuccessAlert = result.isSuccess
                    guard result.isSuccess else { return }
                    try? await Task.sleep(for: .seconds(Metrics.delayToHideTick))
                    // Set it back to false
                    shouldShowSuccessAlert = false
                    await viewModel.startScanning()
                }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: .black.opacity(0.4), radius: 32, y: 8)
    }

    private func errorView(_ message: String) -> some View {
        ErrorView(title: "Not available", message: message)
    }

    // MARK: - Overlay layer

    private var overlayLayer: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            viewfinderRect
                .frame(width: 280, height: 180)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var viewfinderRect: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(Color.white.opacity(0.8), lineWidth: 3)
    }
}
