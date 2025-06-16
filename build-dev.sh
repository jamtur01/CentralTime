#!/bin/bash

# Development build script with proper local signing
# This creates a version that should run without "damaged" warnings

set -e

echo "Building CentralTime for local development..."

# Build the app
./build-spm.sh

echo "Applying development-specific fixes..."

# Remove quarantine attributes
xattr -c CentralTime.app 2>/dev/null || true
find CentralTime.app -type f -exec xattr -c {} \; 2>/dev/null || true

# Re-sign with ad-hoc signature including hardened runtime
echo "Re-signing with hardened runtime..."
codesign --force --deep --options runtime --sign - CentralTime.app

echo "Development build complete!"
echo ""
echo "The app should now run without 'damaged' warnings."
echo "If you still get warnings, try:"
echo "  1. Right-click the app and select 'Open'"
echo "  2. Or run: sudo spctl --master-disable (temporarily)"