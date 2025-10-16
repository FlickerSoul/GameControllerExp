#!/bin/bash

# Build script for GameControllerExp macOS app
# This script builds the app in Release configuration and creates a distributable .app bundle

set -e  # Exit on error

# Configuration
PROJECT_NAME="GameControllerExp"
SCHEME_NAME="GameControllerExp"
CONFIGURATION="Release"
BUILD_DIR="build"
DIST_DIR="dist"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Building ${PROJECT_NAME}${NC}"
echo -e "${BLUE}========================================${NC}"

# Clean previous builds
echo -e "\n${BLUE}Cleaning previous builds...${NC}"
rm -rf "${BUILD_DIR}"
rm -rf "${DIST_DIR}"

# Build the app
echo -e "\n${BLUE}Building ${PROJECT_NAME} (${CONFIGURATION})...${NC}"
xcodebuild \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME_NAME}" \
  -configuration "${CONFIGURATION}" \
  -derivedDataPath "${BUILD_DIR}" \
  clean build

# Locate the built app
APP_PATH="${BUILD_DIR}/Build/Products/${CONFIGURATION}/${PROJECT_NAME}.app"

if [ ! -d "${APP_PATH}" ]; then
  echo -e "${RED}Error: Built app not found at ${APP_PATH}${NC}"
  exit 1
fi

# Create distribution directory and copy the app
echo -e "\n${BLUE}Creating distribution package...${NC}"
mkdir -p "${DIST_DIR}"
cp -R "${APP_PATH}" "${DIST_DIR}/"

# Get app info
APP_VERSION=$(defaults read "${APP_PATH}/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
APP_BUNDLE_VERSION=$(defaults read "${APP_PATH}/Contents/Info.plist" CFBundleVersion 2>/dev/null || echo "Unknown")

# Success message
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}App Name:${NC} ${PROJECT_NAME}"
echo -e "${GREEN}Version:${NC} ${APP_VERSION} (${APP_BUNDLE_VERSION})"
echo -e "${GREEN}Configuration:${NC} ${CONFIGURATION}"
echo -e "${GREEN}Output:${NC} ${DIST_DIR}/${PROJECT_NAME}.app"
echo -e "\n${BLUE}To run the app:${NC}"
echo -e "  open ${DIST_DIR}/${PROJECT_NAME}.app"
echo -e "\n${BLUE}To create a DMG:${NC}"
echo -e "  hdiutil create -volname \"${PROJECT_NAME}\" -srcfolder \"${DIST_DIR}\" -ov -format UDZO \"${DIST_DIR}/${PROJECT_NAME}.dmg\""
echo ""
