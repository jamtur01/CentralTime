#!/bin/bash

# Build script for CentralTime v2.0.0 with Swift Package Manager
# New design with timezone-sorted cities and modern SwiftUI interface

# Extract version from Version.swift
VERSION=$(grep -m 1 "public static let version = " Sources/Version.swift | cut -d '"' -f 2)
BUILD=$(grep -m 1 "public static let build = " Sources/Version.swift | cut -d '"' -f 2)

echo "Building CentralTime version $VERSION (build $BUILD) with Swift Package Manager..."
swift build -c release

# Create app bundle
echo "Creating app bundle..."
APP_NAME="CentralTime.app"
APP_CONTENTS="$APP_NAME/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"

mkdir -p "$APP_MACOS"
mkdir -p "$APP_RESOURCES"

# Copy binary
cp ./.build/release/CentralTime "$APP_MACOS/"

# Code sign the binary and app bundle
echo "Code signing..."
codesign --force --deep --sign - "$APP_MACOS/CentralTime"
codesign --force --deep --sign - "$APP_NAME"

# Remove quarantine attributes that might cause "damaged" warnings
echo "Removing quarantine attributes..."
xattr -c "$APP_NAME" 2>/dev/null || true
find "$APP_NAME" -type f -exec xattr -c {} \; 2>/dev/null || true

# Create Info.plist
echo "Creating Info.plist..."
cat > "$APP_CONTENTS/Info.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CentralTime</string>
    <key>CFBundleIdentifier</key>
    <string>com.jamtur01.CentralTime</string>
    <key>CFBundleName</key>
    <string>CentralTime</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$BUILD</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 James Turnbull. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSApplicationSupportsSecureRestorableState</key>
    <true/>
</dict>
</plist>
EOL

echo "App bundle created: $APP_NAME"

# Install option
if [ "$1" = "install" ]; then
    echo "Installing to /Applications..."
    cp -R "$APP_NAME" /Applications/
    echo "Installation complete!"
fi

echo "Done!"
