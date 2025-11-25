# Quick Start Guide

## Build APK in 3 Steps

### Step 1: Verify Setup
```bash
./verify_setup.sh
```
This checks if everything is configured correctly.

### Step 2: Fix Any Issues
If verification fails, check:
- API key is configured (via `.env` file or environment variable)
- `android/key.properties` configured with keystore path
- Keystore file exists at specified location

**Set API Key**:
```bash
# Option 1: Create .env file
echo "GEMINI_API_KEY=your_key" > .env

# Option 2: Export environment variable
export GEMINI_API_KEY=your_key
```

### Step 3: Build & Deploy
```bash
./deploy_apk.sh
```

The APK will be at: `millionaire-quiz-release.apk`

## Install on Device

### Option A: Transfer File
1. Copy `millionaire-quiz-release.apk` to phone
2. Enable "Unknown Sources" in Settings
3. Open APK and install

### Option B: ADB
```bash
adb install -r millionaire-quiz-release.apk
```

## Key Security Improvements

### 1. Fixed Internet Permission ✓
**Problem**: App couldn't access Gemini API on device
**Solution**: Added `INTERNET` permission to AndroidManifest.xml

### 2. Secure API Key Handling ✓
**Problem**: `.env` file bundled in APK assets (easy to extract)
**Solution**: API key passed via `--dart-define` at build time (compiled into binary)

### 3. Created Deploy Script ✓
**Problem**: Manual build process error-prone
**Solution**: Automated script with validation and secure key handling

### 4. Build-Time Key Injection ✓
**Before**: API key in assets folder → extractable with `unzip`
**After**: API key compiled into binary → requires reverse engineering

## Troubleshooting

### App Still Uses Default Questions?

1. **Check Device Logs**:
   ```bash
   adb logcat | grep -E "(API Key|GEMINI|millionaire)"
   ```

2. **Expected Output**:
   - `🔑 API Key configured: YES`
   - `✅ API key length: 39`
   - `✅ API key loaded successfully`

3. **If API Key Not Configured**:
   - Set via .env: `echo "GEMINI_API_KEY=your_key" > .env`
   - Or export: `export GEMINI_API_KEY=your_key`
   - Or inline: `GEMINI_API_KEY=your_key ./deploy_apk.sh`
   - Run `./verify_setup.sh` to check

4. **If Network Error**:
   - Ensure device has internet
   - Check network isn't blocking Google APIs
   - Try on mobile data instead of WiFi

### Build Fails?

Run clean build:
```bash
flutter clean
flutter pub get
./deploy_apk.sh
```

## Files Created

- ✓ `deploy_apk.sh` - Automated deployment script
- ✓ `verify_setup.sh` - Setup verification script  
- ✓ `DEPLOYMENT.md` - Detailed deployment guide
- ✓ `QUICK_START.md` - This file

## Need Help?

See `DEPLOYMENT.md` for detailed troubleshooting.

