# Goia Spots – Flutter Camera Demo

A minimal Flutter experience that opens with a single "Start experience" button and transitions into a full-screen camera preview with live GPS coordinates (latitude, longitude, altitude) rendered as an overlay. It demonstrates the first Goia Spots flow: point your camera, read your current position, and treat that spot as the first AR anchor.

## ✨ Features

- Home screen with Goia Spots branding and a single CTA.
- Experience screen that:
  - Uses the official `camera` plugin for a full-screen preview.
  - Streams latitude, longitude, and altitude via `geolocator`.
  - Displays the readings in a semi-transparent bottom panel.
  - Surfaces friendly copy if location permission is denied or GPS is unavailable.
- Handles camera lifecycle (pause/resume) and cleans up streams/controllers.

## 🚀 Run It

```bash
cd "P:\Product Development\ar_location-1"
flutter pub get
flutter run   # Use a physical device for camera/GPS access
```

> Tip: The button is disabled when no compatible camera is detected (emulator/simulator).

## 📱 App Flow

1. **HomeScreen** – Title, subtitle, and the `Start experience` button.
2. **ExperienceScreen** – Full camera preview with a bottom overlay displaying:
   - `Lat: <value>`
   - `Lng: <value>`
   - `Alt: <value> m`
   - or a short message when permissions/services are missing.

## 🧱 Project Structure

```
lib/
├── main.dart                  # Loads cameras, bootstraps the app
└── screens/
    ├── home_screen.dart       # Start page
    └── experience_screen.dart # Camera + coordinates experience
test/
└── widget_test.dart           # Home screen smoke test
```

## 📦 Dependencies

- `camera` – full-screen camera preview
- `geolocator` – GPS stream (lat/lng/altitude)
- `cupertino_icons` – optional Material icons parity

## 🔐 Permissions & Platform Notes

Add/update the following strings when configuring platform builds:

### Android (`android/app/src/main/AndroidManifest.xml`)
- `<uses-permission android:name="android.permission.CAMERA"/>`
- `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>`
- `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>`

### iOS (`ios/Runner/Info.plist`)
- `NSCameraUsageDescription` – e.g., “Camera access is required to show the Goia Spots experience.”
- `NSLocationWhenInUseUsageDescription` – e.g., “Location access is required to display nearby Goia Spots.”

Only “when in use” permissions are requested for location.

## 🧪 Testing

```
flutter test
```

Current coverage: a widget test ensures the home screen renders the hero text and interactive CTA.

## 📝 Notes

- Altitude is provided directly by the device sensors through `geolocator`. Values can fluctuate indoors; this is acceptable for the demo.
- The overlay falls back to placeholders (`--`) until the first GPS fix arrives.
- When location permission is denied, the overlay shows an actionable message instead of numeric values.
