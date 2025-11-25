#!/bin/bash

# Verification script to check if deployment is properly configured

# Don't exit on error - we want to show all checks
set +e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Millionaire Quiz - Setup Verification       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKS_PASSED=0
CHECKS_FAILED=0

# Check 1: Flutter installation
echo -e "${YELLOW}[1/8]${NC} Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✓ Flutter found: $FLUTTER_VERSION${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗ Flutter not found in PATH${NC}"
    ((CHECKS_FAILED++))
fi

# Check 2: API Key configuration
echo -e "${YELLOW}[2/8]${NC} Checking API key configuration..."
API_KEY=""

# Check .env file
if [ -f "$PROJECT_ROOT/.env" ]; then
    if grep -q "GEMINI_API_KEY=" "$PROJECT_ROOT/.env"; then
        API_KEY=$(grep "GEMINI_API_KEY=" "$PROJECT_ROOT/.env" | cut -d '=' -f2 | tr -d '\r\n' | tr -d ' ')
    fi
fi

# Check environment variable
if [ -n "$GEMINI_API_KEY" ]; then
    API_KEY="$GEMINI_API_KEY"
fi

# Validate
if [ -n "$API_KEY" ] && [ "$API_KEY" != "your_gemini_api_key_here" ]; then
    echo -e "${GREEN}✓ GEMINI_API_KEY is configured (length: ${#API_KEY})${NC}"
    echo -e "${GREEN}  API key will be compiled into binary via --dart-define${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗ GEMINI_API_KEY not configured${NC}"
    echo -e "  Set via: echo 'GEMINI_API_KEY=your_key' > .env"
    echo -e "  Or: export GEMINI_API_KEY=your_key"
    ((CHECKS_FAILED++))
fi

# Check 3: pubspec.yaml dependencies
echo -e "${YELLOW}[3/8]${NC} Checking pubspec.yaml dependencies..."
if grep -q "google_generative_ai" "$PROJECT_ROOT/pubspec.yaml"; then
    echo -e "${GREEN}✓ google_generative_ai dependency found${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗ google_generative_ai dependency missing${NC}"
    ((CHECKS_FAILED++))
fi

# Check 4: AndroidManifest.xml permissions
echo -e "${YELLOW}[4/8]${NC} Checking AndroidManifest.xml permissions..."
MANIFEST="$PROJECT_ROOT/android/app/src/main/AndroidManifest.xml"
if grep -q "android.permission.INTERNET" "$MANIFEST"; then
    echo -e "${GREEN}✓ INTERNET permission is set${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗ INTERNET permission missing in AndroidManifest.xml${NC}"
    ((CHECKS_FAILED++))
fi

# Check 5: key.properties
echo -e "${YELLOW}[5/8]${NC} Checking signing configuration..."
if [ -f "$PROJECT_ROOT/android/key.properties" ]; then
    echo -e "${GREEN}✓ key.properties file exists${NC}"
    ((CHECKS_PASSED++))
    
    # Check if keystore file exists
    KEYSTORE=$(grep "storeFile=" "$PROJECT_ROOT/android/key.properties" | cut -d '=' -f2 | tr -d '\r\n')
    if [ -f "$KEYSTORE" ]; then
        echo -e "${GREEN}  ✓ Keystore file found: $KEYSTORE${NC}"
    else
        echo -e "${RED}  ✗ Keystore file not found: $KEYSTORE${NC}"
        ((CHECKS_FAILED++))
        ((CHECKS_PASSED--))
    fi
else
    echo -e "${RED}✗ key.properties not found${NC}"
    ((CHECKS_FAILED++))
fi

# Check 6: build.gradle.kts signing config
echo -e "${YELLOW}[6/8]${NC} Checking build.gradle.kts signing config..."
BUILD_GRADLE="$PROJECT_ROOT/android/app/build.gradle.kts"
if grep -q "signingConfigs" "$BUILD_GRADLE"; then
    echo -e "${GREEN}✓ Signing config found in build.gradle.kts${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗ Signing config missing in build.gradle.kts${NC}"
    ((CHECKS_FAILED++))
fi

# Check 7: Deploy script
echo -e "${YELLOW}[7/8]${NC} Checking deploy script..."
if [ -f "$PROJECT_ROOT/deploy_apk.sh" ] && [ -x "$PROJECT_ROOT/deploy_apk.sh" ]; then
    echo -e "${GREEN}✓ deploy_apk.sh exists and is executable${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗ deploy_apk.sh not found or not executable${NC}"
    if [ -f "$PROJECT_ROOT/deploy_apk.sh" ]; then
        echo -e "  Run: chmod +x deploy_apk.sh"
    fi
    ((CHECKS_FAILED++))
fi

# Check 8: Dependencies
echo -e "${YELLOW}[8/8]${NC} Checking Flutter dependencies..."
if [ -f "$PROJECT_ROOT/pubspec.lock" ]; then
    echo -e "${GREEN}✓ pubspec.lock exists (dependencies installed)${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${YELLOW}⚠ pubspec.lock not found${NC}"
    echo -e "  Run: flutter pub get"
    ((CHECKS_FAILED++))
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Verification Summary              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo -e "${GREEN}Passed: $CHECKS_PASSED${NC}"
echo -e "${RED}Failed: $CHECKS_FAILED${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! You're ready to build.${NC}"
    echo -e "Run: ${BLUE}./deploy_apk.sh${NC}"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please fix the issues above.${NC}"
    echo -e "See DEPLOYMENT.md for detailed instructions."
    exit 1
fi

