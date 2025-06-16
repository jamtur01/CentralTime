# CentralTime

A Swift menubar app that cycles through and displays time in multiple cities.

## Features

- Displays time for multiple cities in the menu bar
- Automatically cycles through cities every 3 seconds
- Minimalist design with city code and local time

## Cities Displayed

- ORD (Chicago)
- SFO (San Francisco)
- BLR (Bangalore)
- MEL (Melbourne)
- LON (London)

## Building with Swift Package Manager

To build the app using Swift Package Manager:

```bash
swift build
```

For a release build:

```bash
swift build -c release
```

To build and create an app bundle:

```bash
./build-spm.sh
```

To build and install to your /Applications folder:

```bash
./build-spm.sh install
```

## Running the App

After building, you can run the app by:

```bash
open CentralTime.app
```

## Adding to Login Items

To have the app start when you log in:

1. Open System Preferences/Settings
2. Go to Users & Groups/Login Items
3. Add CentralTime.app to the list

## Requirements

- macOS 10.13 or later
- Swift 5.5 or later

## Versioning and Releases

CentralTime follows semantic versioning (SemVer) with version numbers in the format `MAJOR.MINOR.PATCH`.

### Current Version

The current version is tracked in the `VERSION` file at the root of the repository.

### Creating a New Release

To create a new release:

1. Run the release script with the new version number:

```bash
./release.sh 1.0.0
```

This script will:
- Update the version in all necessary files
- Commit the changes
- Create and push a git tag (e.g., v1.0.0)
- Trigger the GitHub Actions release workflow

2. The GitHub Actions workflow will automatically:
- Build the application
- Create a GitHub release
- Attach the built application as a downloadable asset

### Downloading Releases

Pre-built releases can be downloaded from the [GitHub Releases page](https://github.com/YOUR_USERNAME/CentralTime/releases).
