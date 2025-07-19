#!/bin/bash

# Consolidated build script for CentralTime
# Supports development, release, and CI builds with proper code signing

set -e

# Script configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Default values
BUILD_TYPE="development"
INSTALL_APP=false
SIGN_IDENTITY=""
NOTARIZE=false
CREATE_ZIP=false
OUTPUT_DIR="."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE        Build type: development, release, or ci (default: development)"
    echo "  -i, --install          Install app to /Applications after build"
    echo "  -s, --sign IDENTITY    Code signing identity (for release/ci builds)"
    echo "  -n, --notarize         Notarize the app (requires Apple ID credentials)"
    echo "  -z, --zip              Create ZIP archive of the app"
    echo "  -o, --output DIR       Output directory for build artifacts (default: .)"
    echo "  -h, --help             Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Development build"
    echo "  $0 --type release --install           # Release build and install"
    echo "  $0 --type ci --sign \"Developer ID\"   # CI build with signing"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -i|--install)
            INSTALL_APP=true
            shift
            ;;
        -s|--sign)
            SIGN_IDENTITY="$2"
            shift 2
            ;;
        -n|--notarize)
            NOTARIZE=true
            shift
            ;;
        -z|--zip)
            CREATE_ZIP=true
            shift
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(development|release|ci)$ ]]; then
    echo -e "${RED}Invalid build type: $BUILD_TYPE${NC}"
    usage
    exit 1
fi

# Extract version information
VERSION=$(grep -m 1 "public static let version = " Sources/Version.swift | cut -d '"' -f 2)
BUILD=$(grep -m 1 "public static let build = " Sources/Version.swift | cut -d '"' -f 2)

echo -e "${GREEN}Building CentralTime version $VERSION (build $BUILD)${NC}"
echo "Build type: $BUILD_TYPE"

# Step 1: Clean previous builds
echo -e "\n${YELLOW}Cleaning previous builds...${NC}"
rm -rf .build
rm -rf CentralTime.app
rm -f CentralTime*.zip

# Step 2: Build with Swift Package Manager
echo -e "\n${YELLOW}Building with Swift Package Manager...${NC}"
if [[ "$BUILD_TYPE" == "development" ]]; then
    swift build -c debug
else
    swift build -c release
fi

# Step 3: Create app bundle structure
echo -e "\n${YELLOW}Creating app bundle...${NC}"
APP_NAME="CentralTime.app"
APP_CONTENTS="$APP_NAME/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"

mkdir -p "$APP_MACOS"
mkdir -p "$APP_RESOURCES"

# Copy binary
if [[ "$BUILD_TYPE" == "development" ]]; then
    cp ./.build/debug/CentralTime "$APP_MACOS/"
else
    cp ./.build/release/CentralTime "$APP_MACOS/"
fi

# Create Info.plist
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

# Step 4: Code signing
echo -e "\n${YELLOW}Code signing...${NC}"

if [[ -n "$SIGN_IDENTITY" ]] || [[ -n "$MACOS_CODESIGN_IDENTITY" ]]; then
    # Use provided identity or environment variable
    IDENTITY="${SIGN_IDENTITY:-$MACOS_CODESIGN_IDENTITY}"
    echo "Using Developer ID: $IDENTITY"
    
    if [[ "$BUILD_TYPE" == "ci" ]] || [[ "$BUILD_TYPE" == "release" ]]; then
        # Sign with hardened runtime and entitlements for release/CI
        codesign --force --deep --options runtime --entitlements CentralTime.entitlements --sign "$IDENTITY" "$APP_NAME"
    else
        # Simple signing for development
        codesign --force --deep --sign "$IDENTITY" "$APP_NAME"
    fi
else
    # Ad-hoc signing for local development
    echo "Using ad-hoc signing for local development"
    if [[ "$BUILD_TYPE" == "development" ]]; then
        # Development build with hardened runtime to avoid "damaged" warnings
        codesign --force --deep --options runtime --sign - "$APP_NAME"
    else
        codesign --force --deep --sign - "$APP_NAME"
    fi
fi

# Step 5: Remove quarantine attributes (development only)
if [[ "$BUILD_TYPE" == "development" ]]; then
    echo -e "\n${YELLOW}Removing quarantine attributes...${NC}"
    xattr -cr "$APP_NAME" 2>/dev/null || true
fi

# Step 6: Notarization (if requested)
if [[ "$NOTARIZE" == true ]]; then
    echo -e "\n${YELLOW}Notarizing app...${NC}"
    
    # Check for required environment variables
    if [[ -z "$APPLE_ID" ]] || [[ -z "$MACOS_API_ISSUER_ID" ]] || [[ -z "$APPLE_APP_SPECIFIC_PASSWORD" ]]; then
        echo -e "${RED}Error: Notarization requires APPLE_ID, MACOS_API_ISSUER_ID, and APPLE_APP_SPECIFIC_PASSWORD${NC}"
        exit 1
    fi
    
    # Create notarization profile
    xcrun notarytool store-credentials "notarytool-profile" \
        --apple-id "$APPLE_ID" \
        --team-id "$MACOS_API_ISSUER_ID" \
        --password "$APPLE_APP_SPECIFIC_PASSWORD"
    
    # Create ZIP for notarization
    ditto -c -k --keepParent "$APP_NAME" notarization.zip
    
    # Submit for notarization
    xcrun notarytool submit notarization.zip --keychain-profile "notarytool-profile" --wait
    
    # Staple the ticket
    xcrun stapler staple "$APP_NAME" || echo "Stapling failed, but continuing..."
    
    # Clean up
    rm -f notarization.zip
fi

# Step 7: Create ZIP archive (if requested)
if [[ "$CREATE_ZIP" == true ]]; then
    echo -e "\n${YELLOW}Creating ZIP archive...${NC}"
    ZIP_NAME="CentralTime-${VERSION}.zip"
    ditto -c -k --keepParent "$APP_NAME" "$OUTPUT_DIR/$ZIP_NAME"
    echo "Created: $OUTPUT_DIR/$ZIP_NAME"
fi

# Step 8: Install to Applications (if requested)
if [[ "$INSTALL_APP" == true ]]; then
    echo -e "\n${YELLOW}Installing to /Applications...${NC}"
    rm -rf "/Applications/$APP_NAME"
    cp -R "$APP_NAME" /Applications/
    echo "Installed to /Applications/$APP_NAME"
fi

# Final output
echo -e "\n${GREEN}Build complete!${NC}"
echo "App bundle: $APP_NAME"

if [[ "$BUILD_TYPE" == "development" ]]; then
    echo -e "\n${YELLOW}Development build notes:${NC}"
    echo "- The app should run without 'damaged' warnings"
    echo "- If you still get warnings, right-click and select 'Open'"
fi

# Move app to output directory if different from current
if [[ "$OUTPUT_DIR" != "." ]] && [[ "$CREATE_ZIP" == false ]]; then
    mv "$APP_NAME" "$OUTPUT_DIR/"
    echo "Moved app to: $OUTPUT_DIR/$APP_NAME"
fi