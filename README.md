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

## Building with Original Method

If you prefer, you can also build using the original script:

```bash
./build-app.sh
```

This will compile the app using swiftc directly.

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
