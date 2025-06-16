# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CentralTime is a modern macOS menu bar application written in SwiftUI that displays the current time for multiple cities, cycling through them every 3 seconds. The app is built using Swift Package Manager and follows SwiftUI's declarative architecture pattern.

## Architecture

- **Main Entry Point**: `Sources/CentralTimeApp.swift` - SwiftUI App with @main attribute and MenuBarExtra
- **State Management**: `Sources/AppState.swift` - ObservableObject managing application state and timer
- **Menu Interface**: `Sources/CentralTimeMenuView.swift` - SwiftUI dropdown menu with city list and controls
- **City Selection**: `Sources/CitySelectionView.swift` - Modern SwiftUI interface with search and selection
- **Data Models**: `Sources/City.swift` - City struct with timezone, display name, and emoji support
- **Timezone Data**: `Sources/TimeZoneData.swift` - Comprehensive database of 100+ global timezones
- **Version Management**: `Sources/Version.swift` - Centralized version and build number constants

The app uses SwiftUI's MenuBarExtra for menu bar presence, @StateObject/@ObservableObject for reactive state management, and declarative SwiftUI views for all interfaces. Features include time slider functionality, real-time search, customizable city lists, and modern SwiftUI styling.

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
./build-smp.sh install
```

## Version Management

The project uses semantic versioning with version information stored in multiple places:
- `VERSION` file (root level)
- `Sources/Version.swift` (code constants)
- `CentralTime/Info.plist` (bundle info)

To create a new release:
```bash
./release.sh 1.0.0
```

This script automatically updates all version files, commits changes, creates a git tag, and triggers the GitHub Actions release workflow.

## CI/CD

- **Build Testing**: `.github/workflows/swift.yml` runs `swift build -v` on pushes and PRs
- **Release Process**: `.github/workflows/release.yml` triggers on version tags, builds the app bundle, creates a ZIP archive, and publishes a GitHub release

## Key Files

- `build-spm.sh`: Custom build script that creates macOS app bundle with proper Info.plist
- `release.sh`: Version bump and release automation script
- `Package.swift`: Swift Package Manager configuration (requires macOS 13.0+ for SwiftUI MenuBarExtra)

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