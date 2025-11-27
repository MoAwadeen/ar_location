
## Flutter camera + location prompt

```markdown
# Goia Spots – Flutter Camera Demo

You are an expert Flutter engineer.  
Create a **minimal Flutter app** that demonstrates a first **Goia Spots** experience:

- Start page with a single button.
- When the user taps **Start experience**, open a **full-screen camera preview**.
- While the camera is open, continuously read the device **latitude, longitude, and altitude** and display them as an overlay.

Use the official `camera` plugin for the camera preview and a simple geolocation package like `geolocator` (or `location`) for coordinates.[web:45][web:55][web:59]

## App flow

1. **Start page (HomeScreen)**
   - Simple screen with:
     - App title: “Goia Spots”
     - Short subtitle: “Explore Goia Spots around you”
     - One primary button: “Start experience”
   - When tapped, navigate to the **ExperienceScreen**.

2. **Experience screen (full camera)**
   - Show **full-screen camera preview** using the device back camera.
   - On top of the camera preview (bottom area), show a **semi-transparent panel** with:
     - Current latitude
     - Current longitude
     - Current altitude (in meters)
   - Continuously update these values as the position updates from the geolocation plugin.
   - If location permissions are denied, show a short message in the overlay panel.

3. **Goia Spots concept (for this demo)**
   - Treat the user’s current position as a “Goia Spot” with:
     - `latitude`
     - `longitude`
     - `altitude`
   - No need for map or navigation in this first demo.
   - Only requirement: show live camera + live coordinates to simulate the beginning of the Goia Spots AR experience.

## Technical requirements

- Use **Flutter** with null safety.
- Use:
  - `camera` package for camera preview.
  - `geolocator` (or `location`) for GPS coordinates including altitude.[web:45][web:50][web:59]
- Handle permissions:
  - Camera permission.
  - Location permission (while in use is enough).
- Target both **Android and iOS** (no platform-specific UI, only permission setup in comments or README if needed).

## Implementation details

- Structure:
  - `main.dart`
    - Initializes Flutter bindings and available cameras before `runApp`.
    - Passes the selected camera to the experience screen.
  - `home_screen.dart`
    - Stateless or simple Stateful widget with title and “Start experience” button.
  - `experience_screen.dart`
    - Stateful widget that:
      - Holds a `CameraController`.
      - Initializes the camera in `initState`.
      - Subscribes to location updates (e.g., `Geolocator.getPositionStream`).
      - Shows a `CameraPreview` with a positioned overlay at bottom.

- UI:
  - Use `Scaffold` with black background on camera screen.
  - Inside body:
    - `Stack`:
      - Full-screen `CameraPreview`.
      - `Align` bottom-center with a `Container`:
        - Slightly transparent black (e.g., `Colors.black54`).
        - Rounded corners and padding.
        - Text lines like:
          - `Lat: <value>`
          - `Lng: <value>`
          - `Alt: <value> m`

- Error and loading states:
  - If camera is not yet initialized, show a centered `CircularProgressIndicator`.
  - If camera fails to initialize, show a simple error message.
  - If no location yet, show placeholders like `Lat: --`, etc.

## Permissions notes (in comments / README)

- Add comments or a small README section describing:
  - Android:
    - `CAMERA`
    - `ACCESS_FINE_LOCATION` (and optionally `ACCESS_COARSE_LOCATION`) in `AndroidManifest.xml`.
  - iOS:
    - `NSCameraUsageDescription`
    - `NSLocationWhenInUseUsageDescription` in `Info.plist`.

No need to implement advanced error handling, maps, or real Goia Spots storage yet.  
Focus on a **clean, single start page → camera + coordinates screen** that can serve as the first Goia Spots demo.
```

[1](https://docs.flutter.dev/cookbook/plugins/picture-using-camera)
[2](https://blog.logrocket.com/geolocation-geocoding-flutter/)
[3](https://www.scaler.com/topics/geolocator-flutter/)
[4](https://isprs-archives.copernicus.org/articles/XL-3-W3/321/2015/)
[5](https://openaccess.cms-conferences.org/publications/book/978-1-964867-73-1/article/978-1-964867-73-1_18)
[6](https://www.mdpi.com/2073-431X/14/11/492)
[7](http://biorxiv.org/lookup/doi/10.1101/2024.02.27.582401)
[8](https://academic.oup.com/europace/article/doi/10.1093/europace/euad122.229/7176977)
[9](https://ieeexplore.ieee.org/document/10122956/)
[10](http://link.springer.com/10.1007/s11042-014-1928-z)
[11](https://www.semanticscholar.org/paper/b3626491d9acc0e8fe68bfdff29b02f83606f60c)
[12](https://arxiv.org/abs/2306.04736)
[13](https://www.semanticscholar.org/paper/b279d5d4bbf803386d73bc0b9bcf9c782e82fdd7)
[14](https://arxiv.org/html/2410.12074v1)
[15](https://arxiv.org/html/2501.06006v1)
[16](https://arxiv.org/pdf/2404.02101.pdf)
[17](https://www.ej-eng.org/index.php/ejeng/article/download/2740/1221)
[18](https://www.eneuro.org/content/eneuro/early/2022/09/02/ENEURO.0224-22.2022.full.pdf)
[19](https://arxiv.org/pdf/2305.14392.pdf)
[20](http://arxiv.org/pdf/2406.10126.pdf)
[21](http://arxiv.org/pdf/2502.11708.pdf)
[22](https://pub.dev/packages/camera)
[23](https://www.youtube.com/watch?v=TrmoRtn5MZA)
[24](https://dev.to/bishopeze/building-a-camera-app-with-flutter-and-the-camera-package-4i15)
[25](https://blog.logrocket.com/flutter-camera-plugin-deep-dive-with-examples/)
[26](https://www.facebook.com/groups/280569894066055/posts/953903860065985/)
[27](https://vibe-studio.ai/insights/developing-flutter-plugins-for-ios-and-android-cameras)
[28](https://www.dbestech.com/tutorials/flutter-google-map-geocoding-and-geolocator)
[29](https://www.youtube.com/watch?v=amPwtDRF0Js)
[30](https://pub.dev/packages/camera/example)
[31](https://stackoverflow.com/questions/76996645/getting-elevation-altitude-using-flutter-plugin-geolocator)
[32](https://stackoverflow.com/questions/60511806/how-to-display-button-on-camera-view-in-flutter)
[33](https://www.dynamsoft.com/codepool/flutter-camera-sdk-1d-2d-barcode-scanner.html)
[34](https://www.facebook.com/groups/fluttercommunity/posts/937931033433741/)
[35](https://www.youtube.com/watch?v=d1sRCa5k2Sg)
[36](https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin)
[37](https://www.youtube.com/watch?v=GsWQsw1R8NU)
[38](https://www.youtube.com/watch?v=oWcGUVgHRlo)