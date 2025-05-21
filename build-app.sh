#!/bin/bash

# Build script for CentralTime app bundle

set -e  # Exit on error

cd "$(dirname "$0")"  # Navigate to script directory

echo "Building CentralTime..."
swiftc -o CentralTime.app/Contents/MacOS/CentralTime CentralTime/CentralTime.swift -framework Cocoa

# Make the binary executable
chmod +x CentralTime.app/Contents/MacOS/CentralTime

echo "CentralTime.app bundle created successfully!"
echo ""
echo "To run the app:"
echo "open CentralTime.app"
echo ""
echo "To add to login items:"
echo "1. Open System Preferences/Settings"
echo "2. Go to Users & Groups/Login Items"
echo "3. Add CentralTime.app to the list"
echo ""
echo "To install the app permanently:"
echo "cp -r CentralTime.app /Applications/"
