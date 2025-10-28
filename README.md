# GEM AR Museum Navigation

A production-ready Flutter AR (Augmented Reality) application for the Grand Egyptian Museum (GEM) that displays GPS-based AR annotations at artifact locations.

## 🎯 Overview

This application uses the `ar_location_view` package to create an immersive AR museum navigation experience. Users can point their device camera around to see blue AR markers floating at the real-world GPS coordinates of museum artifacts. Tapping a marker reveals detailed information about the artifact.

## ✨ Features

- **GPS-Based AR**: Real-time AR annotations at precise GPS coordinates
- **3 Historic Artifacts**: Pre-configured locations for Tutankhamun's Mask, Grand Staircase, and Ramses II Statue
- **Interactive Markers**: Blue containers with icons and artifact names
- **Detailed Information**: Tap any marker to view artifact descriptions and coordinates
- **Production-Ready**: Complete error handling, loading states, and permission management
- **Beautiful UI**: Modern, gradient-based interface with Material Design 3

## 📱 Screenshots

The app features:
- A welcoming home screen with museum branding
- AR camera view with floating markers
- Interactive bottom sheets with artifact details
- Smooth animations and transitions

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Android Studio / Xcode for mobile development
- Physical device (AR requires camera and GPS sensors)

### Installation

1. **Clone or navigate to the project:**
   ```bash
   cd "P:\Product Development\ar_location-1"
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

   **Note:** AR features require a physical device. The app will not work properly in an emulator/simulator.

## 📦 Dependencies

- `ar_location_view: ^2.0.16` - GPS-based AR annotations
- `permission_handler: ^11.0.1` - Runtime permission management  
- `geolocator: ^13.0.4` - GPS location services
- `cupertino_icons: ^1.0.8` - iOS-style icons

**Note:** This project uses `ar_location_view` (NOT `ar_location`) which is the correct package name on pub.dev.

## 🏛️ Artifact Locations

The following artifacts are pre-configured with their GPS coordinates:

| Artifact | Latitude | Longitude | Description |
|----------|----------|-----------|-------------|
| **Tutankhamun Mask** | 29.9939°N | 31.1206°E | The golden funerary mask of Pharaoh Tutankhamun |
| **Grand Staircase** | 29.9940°N | 31.1205°E | The magnificent central staircase of GEM |
| **Ramses II Statue** | 29.9938°N | 31.1207°E | A colossal statue of Pharaoh Ramses II |

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point and home screen
├── models/
│   └── artifact.dart           # Artifact data model
└── screens/
    └── ar_tour_screen.dart     # Main AR view with camera and annotations

assets/
└── artifacts.json              # Artifact data (coordinates, descriptions)

android/
└── app/src/main/
    └── AndroidManifest.xml     # Android permissions

ios/
└── Runner/
    └── Info.plist              # iOS permissions
```

## 🔧 Configuration

### Android Permissions

The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `CAMERA` - Access device camera for AR view
- `ACCESS_FINE_LOCATION` - Precise GPS coordinates
- `ACCESS_COARSE_LOCATION` - Approximate location
- `INTERNET` - Network access (if needed)

### iOS Permissions

The following permissions are configured in `ios/Runner/Info.plist`:
- `NSCameraUsageDescription` - Camera access for AR
- `NSLocationWhenInUseUsageDescription` - Location access

## 🎨 Customization

### Adding New Artifacts

Edit `assets/artifacts.json` to add more artifacts:

```json
{
  "id": "unique_artifact_id",
  "name": "Artifact Name",
  "description": "Detailed description of the artifact...",
  "latitude": 29.9939,
  "longitude": 31.1206,
  "iconName": "history"
}
```

Available icon names: `history`, `stairs`, `account_balance`, or any Material Icons name.

### Styling AR Markers

Modify `_buildAnnotationWidget()` in `lib/screens/ar_tour_screen.dart` to customize:
- Colors (change `Colors.blue` to your preferred color)
- Size (adjust `padding` and `size` values)
- Shape (modify `borderRadius` for different shapes)
- Content (add images, badges, or additional text)

## 🔒 Permissions

The app requests the following permissions at runtime:
- **Camera**: Required for AR camera view
- **Location**: Required to calculate distances and show AR markers

Users must grant both permissions for the app to function properly.

## 🐛 Troubleshooting

### AR Markers Not Appearing
- Ensure you're on a physical device (not an emulator)
- Check that location permissions are granted
- Verify GPS signal is available
- Stand close to the artifact locations (within ~100m)

### Camera Not Working
- Grant camera permission when prompted
- Check device camera functionality in other apps
- Restart the app after granting permissions

### Build Errors
- Run `flutter clean` then `flutter pub get`
- Ensure Flutter SDK is up to date: `flutter upgrade`
- Check that Android/iOS toolchains are properly configured

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ❌ Web (AR requires native camera/sensors)
- ❌ Desktop (AR requires mobile sensors)

## 🏗️ Architecture

The app follows a clean, maintainable architecture:

1. **Models**: Data classes for type-safe artifact information
2. **Screens**: UI components with state management
3. **Assets**: JSON-based data storage for easy updates
4. **Permissions**: Runtime permission handling with graceful fallbacks
5. **Error Handling**: Comprehensive error states and user feedback

## 🎯 Usage

1. **Launch the app** - You'll see the home screen with museum branding
2. **Tap "Start AR Tour"** - Grant camera and location permissions
3. **Point your camera** - Move your device to see AR markers in the environment
4. **Tap a marker** - View detailed information about the artifact
5. **Navigate** - Use the on-screen distance indicators to find artifacts

## 📄 License

This project is created as a demonstration of AR navigation capabilities using Flutter and the ar_location_view package.

## 🤝 Contributing

To contribute or report issues:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📚 Resources

- [ar_location_view Package](https://pub.dev/packages/ar_location_view)
- [Flutter Documentation](https://flutter.dev/docs)
- [Grand Egyptian Museum](https://www.gem.gov.eg/)

## 👨‍💻 Development

Built with:
- Flutter 3.9.2+
- Dart 3.0+
- AR Location View 2.0.16

## 📞 Support

For questions or issues, please refer to:
- Flutter documentation: https://flutter.dev/docs
- ar_location_view package: https://pub.dev/packages/ar_location_view
- Flutter community: https://flutter.dev/community

---

**Note**: This is a demonstration app. For production deployment at an actual museum, you would need to:
- Verify exact GPS coordinates on-site
- Test AR marker visibility at various distances
- Optimize for different lighting conditions
- Add offline support for indoor use
- Implement analytics and user tracking
- Add multiple language support
- Include accessibility features
