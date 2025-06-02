#!/bin/bash

# Script to create a new release
# Usage: ./release.sh <version>
# Example: ./release.sh 1.0.0

set -e  # Exit on error

if [ $# -ne 1 ]; then
    echo "Usage: ./release.sh <version>"
    echo "Example: ./release.sh 1.0.0"
    exit 1
fi

VERSION=$1

# Validate version format (should be like 1.0.0)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version should be in the format X.Y.Z (e.g., 1.0.0)"
    exit 1
fi

echo "Preparing release v$VERSION..."

# Update VERSION file
echo "$VERSION" > VERSION
echo "Updated VERSION file"

# Update Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" CentralTime/Info.plist
echo "Updated CentralTime/Info.plist"

# Update build-spm.sh
sed -i '' "s/<string>[0-9]\+\.[0-9]\+\(\.[0-9]\+\)\?<\/string>/<string>$VERSION<\/string>/" build-spm.sh
echo "Updated build-spm.sh"

# Commit changes
git add VERSION CentralTime/Info.plist build-spm.sh
git commit -m "Bump version to v$VERSION"
echo "Committed version changes"

# Create and push tag
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin "v$VERSION"
echo "Created and pushed tag v$VERSION"

echo "Release v$VERSION prepared and pushed!"
echo "The GitHub Actions workflow will now build and create the release."
echo "Check the progress at: https://github.com/$(git config --get remote.origin.url | sed -e 's/.*github.com[:\/]\(.*\)\.git/\1/')/actions"