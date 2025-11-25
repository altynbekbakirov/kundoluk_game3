# Security Upgrade: API Key Migration

## What Changed?

We've upgraded the API key handling from `.env` file bundled in assets to `--dart-define` compilation for better security.

## Security Comparison

### Before (Insecure) ❌
```bash
# .env file bundled in APK assets
flutter build apk --release
```
**Problem**: Anyone can extract the API key:
```bash
unzip app-release.apk
cat assets/.env  # API key in plain text!
```

### After (Secure) ✅
```bash
# API key compiled into binary
flutter build apk --release --dart-define=GEMINI_API_KEY=your_key
```
**Benefit**: API key is compiled into the binary code, requires reverse engineering to extract (much harder).

## Technical Details

### Before:
1. `.env` file stored in `assets/` folder
2. Bundled in APK as a plain text file
3. Loaded at runtime using `flutter_dotenv`
4. Easy to extract: `unzip` → `cat assets/.env`

### After:
1. API key passed at build time via `--dart-define`
2. Compiled into Dart constants
3. Accessed via `String.fromEnvironment()`
4. Not stored in assets, resources, or strings.xml
5. Part of compiled binary code

## How to Build

### Automatic (Recommended)
The deploy script handles everything:
```bash
./deploy_apk.sh
```

The script will:
1. Read API key from `.env` or environment variable
2. Pass it securely via `--dart-define`
3. Build the APK with key compiled in

### Manual Build
```bash
# Option 1: With environment variable
export GEMINI_API_KEY=your_actual_api_key
flutter build apk --release --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY

# Option 2: Direct inline
flutter build apk --release --dart-define=GEMINI_API_KEY=your_actual_api_key

# Option 3: Read from .env
API_KEY=$(grep GEMINI_API_KEY .env | cut -d'=' -f2)
flutter build apk --release --dart-define=GEMINI_API_KEY=$API_KEY
```

## Migration Steps

If you're updating from the old approach:

1. **Update dependencies**:
   ```bash
   flutter pub get
   ```
   (flutter_dotenv has been removed)

2. **Your .env file still works**:
   - The deploy script reads from `.env` if it exists
   - But the key is now passed via `--dart-define` instead of bundled

3. **Rebuild your APK**:
   ```bash
   ./deploy_apk.sh
   ```

## Verification

### Check if API Key is Compiled
```bash
# After building, check app logs
adb install -r millionaire-quiz-release.apk
adb logcat | grep "API Key"
```

Expected output:
```
🔑 API Key configured: YES
✅ API key length: 39
```

### Verify it's NOT in Assets (Good!)
```bash
unzip -l build/app/outputs/flutter-apk/app-release.apk | grep .env
# Should return nothing (no .env file in APK)
```

## Code Changes Summary

### `lib/constants/constants.dart`
```dart
// Before:
static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

// After:
static const String geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);
```

### `lib/main.dart`
```dart
// Before:
await dotenv.load(fileName: ".env");

// After:
final apiKey = GameConstants.geminiApiKey;
print('🔑 API Key configured: ${apiKey.isNotEmpty ? "YES" : "NO"}');
```

### `pubspec.yaml`
```yaml
# Before:
dependencies:
  flutter_dotenv: ^5.1.0
flutter:
  assets:
    - .env

# After:
# flutter_dotenv removed
# No assets needed
```

### `deploy_apk.sh`
```bash
# Before:
flutter build apk --release

# After:
flutter build apk --release --dart-define=GEMINI_API_KEY="$API_KEY"
```

## Additional Security Recommendations

### 1. Use Different Keys for Different Environments
```bash
# Development
flutter run --dart-define=GEMINI_API_KEY=$DEV_KEY

# Production
flutter build apk --release --dart-define=GEMINI_API_KEY=$PROD_KEY
```

### 2. Consider ProGuard/R8 Obfuscation
For even more security, enable code obfuscation in `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 3. Use Server-Side Proxy (Most Secure)
For maximum security:
- Don't include API key in app at all
- Create a backend server that holds the key
- App calls your server, server calls Gemini API
- Prevents any client-side key extraction

## FAQ

**Q: Can I still use the .env file?**
A: Yes! The deploy script reads from `.env` but passes the key via `--dart-define` instead of bundling it.

**Q: Is the key 100% secure now?**
A: No security is 100%, but this is much better. The key is compiled into binary code, requiring reverse engineering to extract. For maximum security, use a backend proxy.

**Q: Do I need to change my .env file?**
A: No, the `.env` file format stays the same. The deploy script handles the new approach automatically.

**Q: What if I don't want to use .env?**
A: You can use environment variables instead:
```bash
export GEMINI_API_KEY=your_key
./deploy_apk.sh
```

**Q: Can the key still be extracted?**
A: Theoretically yes, with reverse engineering tools like `jadx` or `apktool`, but it's MUCH harder than simply unzipping and reading a text file.

## Support

If you encounter issues:
1. Run `./verify_setup.sh` to check configuration
2. Check logs: `adb logcat | grep "API Key"`
3. See `DEPLOYMENT.md` for detailed troubleshooting

