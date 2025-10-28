# Quick Start Guide - GEM AR Museum Navigation

## 🚀 Quick Setup

### 1. Install Dependencies
```bash
cd "P:\Product Development\ar_location-1"
flutter pub get
```

### 2. Verify Setup
```bash
flutter doctor
flutter analyze
```

### 3. Run on Device
```bash
# For Android
flutter run

# For iOS
flutter run
```

**⚠️ IMPORTANT: AR features require a physical device. Emulators/Simulators will NOT work.**

## 📱 Testing

### Android Device
1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect device via USB
4. Run `flutter devices` to verify connection
5. Run `flutter run`

### iOS Device
1. Connect iPhone/iPad via USB
2. Trust the computer on device
3. In Xcode, configure signing team
4. Run `flutter run`

## ✅ Pre-Flight Checklist

Before running the app, ensure:

- [ ] Physical device is connected (not emulator)
- [ ] Device has a working camera
- [ ] Device has GPS/location services enabled
- [ ] Flutter SDK is installed (`flutter --version`)
- [ ] All dependencies are installed (`flutter pub get`)
- [ ] No analysis errors (`flutter analyze`)

## 🔧 Troubleshooting

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### Permission Issues
- Android: Check `android/app/src/main/AndroidManifest.xml` has all permissions
- iOS: Check `ios/Runner/Info.plist` has all usage descriptions

### Camera Not Working
1. Grant camera permission when prompted
2. Check camera works in device's default camera app
3. Restart the app

### AR Markers Not Visible
1. Ensure location permissions are granted
2. Check GPS signal is available
3. Move closer to the coordinates (Grand Egyptian Museum location)
4. Point camera around slowly to allow sensors to calibrate

## 📦 Package Information

This project uses:
- **ar_location_view** (v2.0.16) - Main AR/GPS package
- **permission_handler** (v11.4.0) - Runtime permissions
- **geolocator** (v13.0.4) - GPS location services

## 🎯 Testing Locations

The app is configured for the Grand Egyptian Museum with these coordinates:

| Artifact | Latitude | Longitude |
|----------|----------|-----------|
| Tutankhamun Mask | 29.9939°N | 31.1206°E |
| Grand Staircase | 29.9940°N | 31.1205°E |
| Ramses II Statue | 29.9938°N | 31.1207°E |

**Note:** For testing in other locations, edit `assets/artifacts.json` with your local coordinates.

## 🔍 Development Commands

```bash
# Run with hot reload
flutter run

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Check for updates
flutter pub outdated

# Update dependencies
flutter pub upgrade
```

## 📝 Notes

- First launch will request camera and location permissions
- AR markers appear when you're within ~1500m of coordinates
- Markers scale with distance (closer = larger)
- Indoor testing may have limited GPS accuracy
- Best tested outdoors with clear sky view

## 🆘 Getting Help

If you encounter issues:

1. Check Flutter version: `flutter --version` (should be >=3.9.2)
2. Check device compatibility: Physical device with camera + GPS
3. View detailed logs: `flutter run -v`
4. Check package issues: https://pub.dev/packages/ar_location_view

## 🎉 Success Indicators

You've successfully set up when you see:

✅ `flutter analyze` shows "No issues found!"  
✅ App launches on physical device  
✅ Camera view is visible  
✅ Permissions are granted  
✅ No errors in console  

Happy AR Navigation! 🚀

