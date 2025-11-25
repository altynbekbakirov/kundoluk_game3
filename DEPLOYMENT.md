# Millionaire Quiz - APK Deployment Guide

This guide explains how to build and deploy the Millionaire Quiz APK for Android devices.

## Prerequisites

1. **Flutter SDK** - Ensure Flutter is installed and configured
2. **Android SDK** - Required for building Android APKs
3. **Gemini API Key** - Get from [Google AI Studio](https://makersuite.google.com/app/apikey)
4. **Keystore File** - For signing the release APK

## Setup Steps

### 1. Configure API Key

The API key is now passed securely at build time using `--dart-define` (more secure than bundling in assets).

**Option A: Using .env file** (Recommended for convenience)
```bash
echo "GEMINI_API_KEY=your_gemini_api_key_here" > .env
```

**Option B: Using environment variable**
```bash
export GEMINI_API_KEY=your_gemini_api_key_here
```

**Option C: Inline with deploy script**
```bash
GEMINI_API_KEY=your_key ./deploy_apk.sh
```

⚠️ **Security**: The `.env` file is only used by the build script to pass the key via `--dart-define`. The key is compiled into the binary, NOT bundled as an asset file.

### 2. Configure Signing (First Time Only)

If you haven't created a keystore yet:

```bash
keytool -genkey -v -keystore ~/millionaire-quiz-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias millionaire-quiz
```

Then create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=millionaire-quiz
storeFile=/home/YOUR_USERNAME/millionaire-quiz-release-key.jks
```

### 3. Build the APK

Run the deployment script:

```bash
./deploy_apk.sh
```

This script will:
- ✓ Verify `.env` file exists and contains API key
- ✓ Validate signing configuration
- ✓ Clean previous builds
- ✓ Install dependencies
- ✓ Build release APK
- ✓ Copy APK to project root

### 4. Install on Device

#### Option A: Manual Installation
1. Transfer `millionaire-quiz-release.apk` to your device
2. Enable "Install from Unknown Sources" in device settings
3. Open the APK and install

#### Option B: ADB Installation
```bash
adb install -r millionaire-quiz-release.apk
```

## Troubleshooting

### App Uses Fallback Questions

**Issue**: App works locally but uses default questions on device

**Causes & Solutions**:

1. **Missing Internet Permission** ✓ (Fixed in AndroidManifest.xml)
   - Added `INTERNET` and `ACCESS_NETWORK_STATE` permissions

2. **API Key Not Provided at Build Time**
   - The API key must be provided when building the APK
   - Use the `deploy_apk.sh` script which handles this automatically
   - Or manually: `flutter build apk --dart-define=GEMINI_API_KEY=your_key`

3. **API Key Not Compiled Into Binary**
   - Check app logs: `adb logcat | grep "API Key"`
   - Should see: "✅ API key length: 39"
   - If not configured: "⚠️ WARNING: API key not provided"

4. **Network Issues**
   - Ensure device has internet connection
   - Check if Gemini API is accessible from device network
   - Some corporate/school networks may block API access

### Build Errors

**Error**: `key.properties not found`
- Create the file following Step 2 above

**Error**: `Keystore file not found`
- Update `storeFile` path in `key.properties`
- Ensure keystore exists at specified location

**Error**: `.env file not found`
- Create `.env` file in project root
- Add `GEMINI_API_KEY=your_key`

## Verification Steps

After installation, verify the app is working correctly:

1. **Check Logs** (with device connected):
   ```bash
   adb logcat | grep -E "API Key|GEMINI"
   ```

2. **Expected Logs**:
   - ✅ `🔑 API Key configured: YES`
   - ✅ `✅ API key length: 39` (or similar)
   - ✅ `✅ API key loaded successfully` (from GeminiService)

3. **Test Questions**:
   - Start a new game
   - If working: Questions vary by level and subject
   - If fallback: Always shows "Какой город является столицей Кыргызстана?"

## Manual Build (Without Script)

If you want to build manually:

```bash
# Clean previous build
flutter clean
flutter pub get

# Build with API key
flutter build apk --release --dart-define=GEMINI_API_KEY=your_actual_api_key_here
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## File Structure

```
millionaire-quiz/
├── .env                          # API keys (DO NOT COMMIT)
├── deploy_apk.sh                 # Deployment script
├── android/
│   ├── key.properties           # Signing config (DO NOT COMMIT)
│   └── app/
│       ├── build.gradle.kts     # Android build config
│       └── src/main/
│           └── AndroidManifest.xml  # Permissions configured
├── lib/
│   ├── main.dart                # Entry point with .env loading
│   ├── constants/constants.dart # API key access
│   └── services/gemini_service.dart  # API integration
└── pubspec.yaml                 # Assets configuration
```

## Security Notes

⚠️ **Never commit these files**:
- `.env` - Contains API keys (if using this method)
- `android/key.properties` - Contains signing passwords
- `*.jks` - Keystore files

✓ **Safe to commit**:
- `deploy_apk.sh` - Deployment script (doesn't contain keys)
- `DEPLOYMENT.md` - This documentation
- All source code (API key passed at build time, not in code)

### Security Improvements

**Before** (Using .env bundled in assets):
- ❌ `.env` file bundled in APK assets folder
- ❌ Easy to extract: `unzip app.apk` → `assets/.env`
- ❌ API key visible in plain text

**After** (Using --dart-define):
- ✅ API key compiled into binary at build time
- ✅ Not stored in assets or resources
- ✅ Harder to extract (requires reverse engineering compiled code)
- ✅ Different keys for different builds without code changes

## Support

If issues persist:
1. Check Flutter version: `flutter --version`
2. Run Flutter doctor: `flutter doctor -v`
3. Clean and rebuild: `flutter clean && ./deploy_apk.sh`
4. Check device logs: `adb logcat`

## Version Info

- Flutter SDK: >=3.0.0
- Android minSdk: 21
- Android targetSdk: Latest
- App Version: 1.0.0+1

