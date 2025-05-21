# CentralTime

A macOS menu bar app that displays the current time in different cities, automatically handling daylight saving changes.

## Features

- Displays current time for multiple cities in the menu bar
- Automatically rotates through configured cities every 3 seconds
- Handles daylight saving time changes automatically
- Menu bar app with minimal footprint

## Cities

The app displays time for the following cities:
- ORD (Chicago)
- SFO (San Francisco)
- BLR (Bangalore)
- MEL (Melbourne)
- LON (London)

## Installation

### Building the App Bundle

To build a proper app bundle:

```bash
./build_app.sh
```

Then run the app:

```bash
open CentralTime.app
```

### Permanent Installation

To install permanently:

```bash
cp -r CentralTime.app /Applications/
```

Then run it from the Applications folder.

## Auto-Launch at Login

To make the app start automatically when you log in:

1. Open System Preferences/Settings
2. Go to Users & Groups
3. Select your user account and go to "Login Items"
4. Click the "+" button and add CentralTime.app

## Quitting the App

Click on the time display in the menu bar and select "Quit" from the menu.

## License

MIT - https://opensource.org/licenses/MIT

## Author

James Turnbull <james@ltl.so>
