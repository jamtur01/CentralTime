# CentralTime

A modern macOS menu bar app that displays and cycles through times in multiple cities around the world.

## Features

- 🌍 **150+ Cities**: Choose from a comprehensive list of global cities
- 🔄 **Auto-Rotation**: Cycles through selected cities every 3 seconds
- 🕐 **Time Slider**: Check times in the past or future with the built-in slider
- 🎨 **Modern UI**: Clean SwiftUI interface with emoji indicators
- ⚡ **Optimized**: Efficient performance with minimal resource usage
- 🔍 **Smart Search**: Quickly find cities with real-time filtering
- 📍 **Timezone Sorting**: Cities automatically sorted by timezone offset

## Building

CentralTime uses a unified build script that handles all build scenarios:

### Quick Start

```bash
# Development build (default)
./build.sh

# Release build with installation
./build.sh --type release --install

# Build with code signing
./build.sh --type release --sign "Developer ID Application: Your Name"
```

### Build Options

- `--type`: Build type (development, release, or ci)
- `--install`: Install to /Applications after build
- `--sign`: Code signing identity
- `--notarize`: Notarize the app
- `--zip`: Create ZIP archive
- `--help`: Show all options

For detailed build instructions, see [BUILD.md](BUILD.md).

## Installation

### From Release (Recommended)

1. Download the latest release from the [Releases page](https://github.com/jamtur01/CentralTime/releases)
2. Unzip the downloaded file
3. Move `CentralTime.app` to your Applications folder
4. Open the app (you may need to right-click and select "Open" the first time)

### From Source

```bash
# Clone the repository
git clone https://github.com/jamtur01/CentralTime.git
cd CentralTime

# Build and install
./build.sh --type release --install
```

### Adding to Login Items

To start CentralTime automatically:

1. Open System Settings
2. Go to General → Login Items
3. Click the + button and add CentralTime.app

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 14.0 or later (for building from source)
- Swift 5.7 or later

## Creating a Release

### For Maintainers

1. Update version in `Sources/Version.swift`
2. Run validation: `./validate-release.sh`
3. Commit changes: `git commit -am "Release v2.0.x"`
4. Create tag: `git tag v2.0.x`
5. Push: `git push origin main v2.0.x`

GitHub Actions will automatically:
- Run tests and linting
- Build and sign the app
- Notarize with Apple
- Create a GitHub release with downloadable ZIP

## Development

### Project Structure

```
CentralTime/
├── Sources/              # Swift source files
│   ├── CentralTimeApp.swift    # Main app and menu bar controller
│   ├── AppState.swift          # State management
│   ├── City.swift              # City data model
│   ├── CitySelectionView.swift # Settings UI
│   ├── TimeZoneData.swift      # Timezone database
│   └── TimeZoneManager.swift   # Timezone utilities
├── Package.swift         # Swift Package Manager config
├── build.sh             # Unified build script
└── CentralTime.entitlements    # App entitlements
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `./build.sh` to verify build
5. Submit a pull request

## License

Copyright © 2025 James Turnbull. All rights reserved.
