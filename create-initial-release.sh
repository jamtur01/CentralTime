#!/bin/bash

# Script to create the initial v1.0.0 release
# This is a one-time script and should be run only once

set -e  # Exit on error

echo "Creating initial v1.0.0 release..."

# Commit any pending changes
git add VERSION CentralTime/Info.plist build-spm.sh README.md .github/workflows/release.yml release.sh Sources/Version.swift
git commit -m "Add versioning and release process"

# Create and push tag
git tag -a "v1.0.0" -m "Initial release v1.0.0"
git push origin "v1.0.0"

echo "Initial release v1.0.0 prepared and pushed!"
echo "The GitHub Actions workflow will now build and create the release."
echo "Check the progress at: https://github.com/$(git config --get remote.origin.url | sed -e 's/.*github.com[:\/]\(.*\)\.git/\1/')/actions"