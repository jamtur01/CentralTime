#!/bin/bash

# Script to validate that everything is ready for a GitHub release

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== CentralTime Release Validation ==="
echo ""

# Check required files
echo "Checking required files..."
REQUIRED_FILES=(
    "build.sh"
    "Sources/Version.swift"
    "CentralTime.entitlements"
    ".github/workflows/swift.yml"
    ".github/workflows/release.yml"
    "Package.swift"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file exists"
    else
        echo -e "${RED}✗${NC} $file missing"
        exit 1
    fi
done

# Check file permissions
echo -e "\nChecking file permissions..."
if [ -x "build.sh" ]; then
    echo -e "${GREEN}✓${NC} build.sh is executable"
else
    echo -e "${RED}✗${NC} build.sh is not executable"
    exit 1
fi

# Extract version info
echo -e "\nExtracting version information..."
VERSION=$(grep -m 1 'public static let version = ' Sources/Version.swift | cut -d '"' -f 2)
BUILD=$(grep -m 1 'public static let build = ' Sources/Version.swift | cut -d '"' -f 2)
echo "Current version: $VERSION (build $BUILD)"

# Test build
echo -e "\nTesting build process..."
if ./build.sh --type release; then
    echo -e "${GREEN}✓${NC} Release build successful"
else
    echo -e "${RED}✗${NC} Release build failed"
    exit 1
fi

# Verify app bundle
echo -e "\nVerifying app bundle..."
if [ -d "CentralTime.app" ]; then
    echo -e "${GREEN}✓${NC} App bundle created"
    
    # Check Info.plist
    if [ -f "CentralTime.app/Contents/Info.plist" ]; then
        echo -e "${GREEN}✓${NC} Info.plist exists"
    else
        echo -e "${RED}✗${NC} Info.plist missing"
        exit 1
    fi
    
    # Check binary
    if [ -f "CentralTime.app/Contents/MacOS/CentralTime" ]; then
        echo -e "${GREEN}✓${NC} Binary exists"
    else
        echo -e "${RED}✗${NC} Binary missing"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} App bundle not found"
    exit 1
fi

# Check GitHub secrets documentation
echo -e "\nGitHub Secrets Required for Release:"
echo "  - MACOS_CERTIFICATE_P12 (base64 encoded .p12 file)"
echo "  - MACOS_CERTIFICATE_PASSWORD"
echo "  - MACOS_CODESIGN_IDENTITY (e.g., 'Developer ID Application: Your Name')"
echo "  - APPLE_ID (for notarization)"
echo "  - MACOS_API_ISSUER_ID (Team ID)"
echo "  - APPLE_APP_SPECIFIC_PASSWORD"

# Suggest next steps
echo -e "\n${GREEN}=== Validation Complete ===${NC}"
echo ""
echo "To create a release:"
echo "1. Ensure all GitHub secrets are configured"
echo "2. Update version in Sources/Version.swift"
echo "3. Commit your changes"
echo "4. Create and push a tag:"
echo "   git tag v$VERSION"
echo "   git push origin v$VERSION"
echo ""
echo "The GitHub Actions workflow will automatically:"
echo "- Run SwiftLint"
echo "- Build and test the app"
echo "- Sign and notarize the app"
echo "- Create a GitHub release with downloadable ZIP"