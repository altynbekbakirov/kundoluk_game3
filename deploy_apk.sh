#!/bin/bash

# Millionaire Quiz APK Deployment Script
# This script builds a signed release APK with proper configuration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
KEY_PROPERTIES="$PROJECT_ROOT/android/key.properties"
BUILD_OUTPUT="$PROJECT_ROOT/build/app/outputs/flutter-apk"

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Millionaire Quiz - APK Deployment Script   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check if .env file exists
echo -e "${YELLOW}[1/7]${NC} Checking API key configuration..."
API_KEY=""

# Try to load API key from .env file (backward compatibility)
if [ -f "$ENV_FILE" ]; then
    if grep -q "GEMINI_API_KEY=" "$ENV_FILE"; then
        API_KEY=$(grep "GEMINI_API_KEY=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '\r\n' | tr -d ' ')
        echo -e "${GREEN}✓ API key found in .env file${NC}"
    fi
fi

# Check if API key is provided via environment variable
if [ -n "$GEMINI_API_KEY" ]; then
    API_KEY="$GEMINI_API_KEY"
    echo -e "${GREEN}✓ API key found in environment variable${NC}"
fi

# Validate API key
echo -e "${YELLOW}[2/7]${NC} Validating GEMINI_API_KEY..."
if [ -z "$API_KEY" ]; then
    echo -e "${RED}✗ Error: GEMINI_API_KEY not found!${NC}"
    echo -e ""
    echo -e "Please provide your API key using one of these methods:"
    echo -e "  1. Create .env file: echo 'GEMINI_API_KEY=your_key' > .env"
    echo -e "  2. Set environment variable: export GEMINI_API_KEY=your_key"
    echo -e "  3. Pass inline: GEMINI_API_KEY=your_key ./deploy_apk.sh"
    exit 1
fi

if [ "$API_KEY" = "your_gemini_api_key_here" ]; then
    echo -e "${RED}✗ Error: Please replace placeholder API key with your actual key!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ GEMINI_API_KEY validated (length: ${#API_KEY})${NC}"

# Step 3: Check key.properties for signing
echo -e "${YELLOW}[3/7]${NC} Checking signing configuration..."
if [ ! -f "$KEY_PROPERTIES" ]; then
    echo -e "${RED}✗ Error: key.properties file not found in android/ directory${NC}"
    echo -e "Please create android/key.properties with your signing configuration"
    exit 1
fi

# Validate keystore file exists
KEYSTORE_FILE=$(grep "storeFile=" "$KEY_PROPERTIES" | cut -d '=' -f2 | tr -d '\r\n')
if [ ! -f "$KEYSTORE_FILE" ]; then
    echo -e "${RED}✗ Error: Keystore file not found: $KEYSTORE_FILE${NC}"
    echo -e "Please ensure the keystore file exists at the specified location"
    exit 1
fi
echo -e "${GREEN}✓ Signing configuration valid${NC}"

# Step 4: Check Flutter installation
echo -e "${YELLOW}[4/7]${NC} Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Error: Flutter is not installed or not in PATH${NC}"
    exit 1
fi
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo -e "${GREEN}✓ Flutter found: $FLUTTER_VERSION${NC}"

# Step 5: Clean previous builds
echo -e "${YELLOW}[5/7]${NC} Cleaning previous builds..."
flutter clean
echo -e "${GREEN}✓ Clean completed${NC}"

# Step 6: Get dependencies
echo -e "${YELLOW}[6/7]${NC} Getting Flutter dependencies..."
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Step 7: Build release APK
echo -e "${YELLOW}[7/7]${NC} Building release APK with secure API key..."
echo -e "${BLUE}This may take a few minutes...${NC}"
echo -e "${BLUE}Using --dart-define to compile API key into binary (more secure)${NC}"
flutter build apk --release --dart-define=GEMINI_API_KEY="$API_KEY"

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          ✓ BUILD SUCCESSFUL!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Find the APK file
    APK_FILE="$BUILD_OUTPUT/app-release.apk"
    if [ -f "$APK_FILE" ]; then
        APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
        echo -e "${BLUE}APK Location:${NC} $APK_FILE"
        echo -e "${BLUE}APK Size:${NC} $APK_SIZE"
        echo ""
        
        # Copy APK to project root for easy access
        RELEASE_APK="$PROJECT_ROOT/millionaire-quiz-release.apk"
        cp "$APK_FILE" "$RELEASE_APK"
        echo -e "${GREEN}✓ APK copied to:${NC} $RELEASE_APK"
        echo ""
        
        # Display installation instructions
        echo -e "${YELLOW}Installation Instructions:${NC}"
        echo -e "1. Transfer the APK to your Android device"
        echo -e "2. Enable 'Install from Unknown Sources' in device settings"
        echo -e "3. Open the APK file on your device and install"
        echo ""
        echo -e "${YELLOW}Or install via ADB:${NC}"
        echo -e "  adb install -r $RELEASE_APK"
        echo ""
    else
        echo -e "${RED}Warning: APK file not found at expected location${NC}"
        echo -e "Check build output directory: $BUILD_OUTPUT"
    fi
else
    echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║          ✗ BUILD FAILED!                       ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
    exit 1
fi

