# venue-iOS

An iOS app for listing venues and scanning tickets with a barcode scanner. The app uses an app coordinator for navigation, a view-model driven SwiftUI UI, and modular Swift packages for networking, scanning, and utilities.

## Features
- Venue list fetched from location-aware use cases
- Ticket scanning flow with barcode scanner
- Coordinator-based navigation
- Unit tests for key view models and use cases

## Architecture
- **SwiftUI** for UI
- **MVVM** with view models per feature
- **Coordinator** pattern for navigation
- **Swift Package Manager** for modular frameworks

## Requirements
- macOS with Xcode
- iOS Simulator (or device)

## Getting Started
1. Open the project in Xcode:
   - `venue-iOS.xcodeproj`
2. Select the `venue-iOS` scheme.
3. Run on an iOS Simulator.

## Running Tests
In Xcode, use **Product > Test** or run from the terminal:

```bash
cd /Users/pandeyani/Downloads/venue-ios
xcodebuild -scheme venue-iOSTests -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Project Structure
```
venue-iOS/
  Frameworks/
    CodeScanner/
    CoreNetworking/
    CoreUtils/
  venue-iOS/
    AppCoordinator/
    Features/
      Intro/
      TicketScan/
      VenueList/
    Repository/
  venue-iOSTests/
  venue-iOSUITests/
```

## Notable Modules
- **CodeScanner**: scanning service wrapper and factory
- **CoreNetworking**: networking utilities
- **CoreUtils**: location services and utilities

## License
TBD
