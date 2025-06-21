# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CentralTime is a modern macOS menu bar application written in SwiftUI that displays the current time for multiple cities, cycling through them every 3 seconds. The app is built using Swift Package Manager and follows SwiftUI's declarative architecture pattern.

## Architecture

CentralTime uses a hybrid SwiftUI + AppKit architecture for optimal menu bar integration. The current implementation (v2.0) is a complete rewrite from the legacy version.

### Core Architecture Components

**Application Entry & Lifecycle**
- `Sources/CentralTimeApp.swift` - SwiftUI App with @main attribute using NSApplicationDelegateAdaptor pattern
- `AppDelegate` class handles NSApplication lifecycle and menu bar setup
- `StatusBarController` manages NSStatusItem, NSPopover, and timer coordination
- Uses `.accessory` activation policy to hide from dock

**State Management & Data Flow**
- `Sources/AppState.swift` - Central ObservableObject with @Published properties for reactive UI updates
- Manages selected cities, current display rotation, time slider offset, and settings window state
- Timer-based city rotation every 3 seconds with RunLoop.common integration
- Automatic timezone-offset sorting for consistent display order

**UI Architecture (SwiftUI + AppKit Hybrid)**
- `StatusBarController` - Pure AppKit for menu bar button and NSPopover management
- `PopoverView` - SwiftUI view embedded in NSHostingController within NSPopover
- `CitySelectionView` - Full SwiftUI settings window with search, selection, and keyboard shortcuts
- `CentralTimeMenuView` - Alternative SwiftUI menu implementation (appears unused in current version)

**Data Layer**
- `Sources/City.swift` - Core data model with timezone integration and optional display customization
- `Sources/TimeZoneManager.swift` - Smart timezone management with 50+ curated major cities
- `Sources/TimeZoneData.swift` - Comprehensive database of 150+ global cities with emojis and airport codes
- Dual data sources: curated major cities vs. comprehensive global database

**Window & Settings Management**
- `SettingsWindowDelegate` - Custom NSWindowDelegate preventing app termination on window close
- Dynamic window creation with proper sizing (500x600) and centering
- Modal-like behavior with single instance enforcement and proper cleanup

### Key Architectural Patterns

**Timer Management**
- Dual timer system: StatusBarController (menu bar updates) + AppState (city rotation)
- RunLoop.common integration ensures updates during menu interactions
- 3-second interval with tolerance for power efficiency

**Data Binding & Updates**
- @ObservableObject/@Published pattern for reactive state updates
- @EnvironmentObject injection for deep view hierarchies
- Manual timer-based updates for menu bar text (AppKit limitation)

**Legacy vs Current Implementation**
- Legacy code in `CentralTime/` directory: Simple NSApplication with hardcoded 5 cities
- Current implementation in `Sources/`: Full SwiftUI hybrid with 150+ cities, search, time controls
- Both implementations coexist (legacy appears unused but kept for reference)

### Time Management Features
- **Time Slider**: Navigate forward/backward in time with hourly increments
- **Timezone Sorting**: Automatic west-to-east sorting by GMT offset
- **Format Consistency**: 12-hour format with locale enforcement (en_US)
- **Real-time Updates**: 3-second rotation with immediate updates on state changes

### Development Architecture Notes

**File Organization**
- `Sources/` contains the active v2.0 SwiftUI implementation
- `CentralTime/` contains legacy v1.0 code (NSApplication-only, appears unused)
- Both use Swift Package Manager but only `Sources/` is referenced in `Package.swift`

**Data Management Strategy**
- `TimeZoneManager.majorCities`: Curated list of ~50 major world cities with proper airport codes and emojis
- `TimeZoneData.allTimezones`: Comprehensive database of 150+ cities for user selection
- Default cities: NYC, London, Melbourne, Los Angeles, Chicago (timezone-sorted)
- City selection persistence through AppState with automatic sorting

**SwiftUI Integration Patterns**
- Menu bar button: Pure AppKit (NSStatusItem) due to SwiftUI MenuBarExtra limitations
- Popover content: SwiftUI views in NSHostingController for modern UI
- Settings window: Pure SwiftUI with custom NSWindowDelegate for lifecycle management
- State flow: AppKit → SwiftUI via @ObservedObject, SwiftUI → AppKit via closures/delegates

**Timer Architecture**
- AppState timer: Handles city rotation and time updates for UI state
- StatusBarController timer: Updates menu bar button text (required due to AppKit/SwiftUI boundary)
- Both use 3-second intervals with RunLoop.common for uninterrupted operation
- Proper cleanup in deinit/applicationWillTerminate

## Build Commands

### Development Build
```bash
swift build
```

### Release Build
```bash
swift build -c release
```

### Create App Bundle
```bash
./build-spm.sh
```

### Build and Install to Applications
```bash
./build-spm.sh install
```

### Development Build with Signing
For local development with proper signing to avoid "damaged" warnings:
```bash
./build-dev.sh
```

## Code Quality

### Linting
The project uses SwiftLint for code quality. Install and run:
```bash
brew install swiftlint
swiftlint --strict
```

### Testing
Run tests (if any exist):
```bash
swift test -v
```

## CI/CD and Release Process

### GitHub Actions Workflows

#### Continuous Integration (`.github/workflows/swift.yml`)
- Triggers on push/PR to main branch
- Runs `swift build -v` on macOS-latest
- Basic build verification

#### Release Workflow (`.github/workflows/release.yml`)
- Triggers on version tags (v*)
- Multi-stage process: lint → build-and-test → create-release
- Includes SwiftLint checking, Swift building/testing
- Full code signing, notarization, and GitHub release creation

### Creating a New Release

1. **Update version information in multiple places:**
   - `VERSION` file (root level)
   - `Sources/Version.swift` (version and build constants)
   - Optionally update `CHANGELOG.md`

2. **Create and push version tag:**
   ```bash
   git tag v2.0.0
   git push origin v2.0.0
   ```

3. **GitHub Actions automatically:**
   - Runs SwiftLint and builds the project
   - Signs the app with Developer ID certificate
   - Applies hardened runtime and entitlements
   - Notarizes with Apple (requires secrets configuration)
   - Creates GitHub release with downloadable ZIP

### Required GitHub Secrets for Release
- `MACOS_CERTIFICATE_P12`: Base64-encoded Developer ID certificate
- `MACOS_CERTIFICATE_PASSWORD`: Certificate password
- `MACOS_CODESIGN_IDENTITY`: Developer ID signing identity
- `APPLE_ID`: Apple ID for notarization
- `MACOS_API_ISSUER_ID`: Team ID for notarization
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password for notarization

## Code Signing and Security

### Entitlements (`CentralTime.entitlements`)
- Configured for hardened runtime with minimal permissions
- Network client access enabled for potential timezone updates
- Sandboxing disabled, most security features enabled
- JIT and unsigned memory execution disabled

### Build Script Features
- `build-spm.sh`: Creates app bundle with proper Info.plist, handles both Developer ID and ad-hoc signing
- `build-dev.sh`: Wrapper for local development with hardened runtime signing
- Automatic quarantine attribute removal for local builds
- Version extraction from `Sources/Version.swift`

## Key Files

- `build-spm.sh`: Custom build script that creates macOS app bundle with proper Info.plist and code signing
- `build-dev.sh`: Development build script with hardened runtime signing for local testing  
- `Package.swift`: Swift Package Manager configuration (requires macOS 13.0+ for SwiftUI MenuBarExtra)
- `CentralTime.entitlements`: Security entitlements for hardened runtime and code signing
- `VERSION`: Simple version file used by build scripts and GitHub Actions
- `CHANGELOG.md`: Detailed changelog with version history and feature descriptions
- `.github/workflows/swift.yml`: CI workflow for build verification
- `.github/workflows/release.yml`: Complete release workflow with signing and notarization

## Features

### Core Functionality
- **Menu Bar Display**: Rotates through selected cities every 3 seconds with emoji and time
- **Dropdown Menu**: Shows all selected cities with real-time updates when clicked
- **Time Slider**: Navigate forward/backward in time to check future/past times
- **Timezone Management**: Add/remove cities from extensive global timezone database

### City Database
- **100+ Global Cities**: Comprehensive timezone coverage across all continents
- **Emoji Support**: Each city has a representative emoji for visual identification
- **Personalization**: Custom display names and emoji selection
- **Smart Defaults**: Starts with NYC, Chicago, LA, London, and Tokyo

### User Interface
- Clean, minimal SwiftUI menu bar presence with rotating city display showing emoji + airport code + time
- Native SwiftUI dropdown menu with all selected cities and their current times
- Modern city selection interface with real-time search filtering
- Interactive checkboxes with visual selection feedback and current time preview
- Time slider controls with visual offset indicators for checking different time periods
- Keyboard shortcuts (Return to save, Escape to cancel) and native SwiftUI styling
- Reactive updates using SwiftUI's @StateObject and @ObservableObject patterns