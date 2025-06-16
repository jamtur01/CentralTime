#!/bin/bash

# Simple release script for CentralTime
# Usage: ./release-simple.sh

set -e

# Get version from Version.swift
VERSION=$(grep -o '"[0-9]*\.[0-9]*\.[0-9]*"' Sources/Version.swift | tr -d '"')

if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from Sources/Version.swift"
    exit 1
fi

echo "Preparing release v$VERSION..."

# Update VERSION file
echo "$VERSION" > VERSION
echo "Updated VERSION file to $VERSION"

# Update legacy Info.plist if it exists
if [ -f "CentralTime/Info.plist" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" CentralTime/Info.plist
    echo "Updated CentralTime/Info.plist"
fi

# Test build
echo "Testing build..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "Build successful!"
else
    echo "Build failed. Aborting release."
    exit 1
fi

# Build app bundle
echo "Creating app bundle..."
./build-spm.sh

echo "Release v$VERSION is ready!"
echo ""
echo "To complete the release:"
echo "1. git add VERSION Sources/Version.swift CHANGELOG.md"
echo "2. git commit -m 'Release v$VERSION'"
echo "3. git tag -a 'v$VERSION' -m 'Release v$VERSION'"
echo "4. git push origin main"
echo "5. git push origin 'v$VERSION'"
echo ""
echo "The GitHub Actions workflow will automatically create the release."