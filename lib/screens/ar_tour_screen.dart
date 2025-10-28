import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ar_location_view/ar_location_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../models/artifact.dart';

/// Concrete implementation of ArAnnotation for artifacts
class ArtifactAnnotation extends ArAnnotation {
  final Artifact artifact;

  ArtifactAnnotation({
    required this.artifact,
    required super.position,
  }) : super(
          uid: artifact.id,
        );
}

/// Main AR Tour Screen that displays AR annotations at artifact GPS coordinates
class ARTourScreen extends StatefulWidget {
  const ARTourScreen({super.key});

  @override
  State<ARTourScreen> createState() => _ARTourScreenState();
}

class _ARTourScreenState extends State<ARTourScreen> {
  List<Artifact> artifacts = [];
  List<ArAnnotation> annotations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAR();
  }

  /// Initialize AR by requesting permissions and loading artifacts
  Future<void> _initializeAR() async {
    try {
      // Request necessary permissions
      final permissionsGranted = await _requestPermissions();
      
      if (!permissionsGranted) {
        setState(() {
          errorMessage = 'Permissions denied. Please enable camera and location permissions.';
          isLoading = false;
        });
        return;
      }

      // Load artifacts from JSON
      await _loadArtifacts();

      // Create AR annotations
      _createAnnotations();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to initialize AR: $e';
        isLoading = false;
      });
    }
  }

  /// Request camera and location permissions
  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    return cameraStatus.isGranted && locationStatus.isGranted;
  }

  /// Load artifacts from JSON file
  Future<void> _loadArtifacts() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/artifacts.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        artifacts = jsonData.map((json) => Artifact.fromJson(json)).toList();
      });
    } catch (e) {
      throw Exception('Failed to load artifacts: $e');
    }
  }

  /// Create AR annotations from artifacts
  void _createAnnotations() {
    annotations = artifacts.map((artifact) {
      // Create a Position object from geolocator package
      return ArtifactAnnotation(
        artifact: artifact,
        position: Position(
          latitude: artifact.latitude,
          longitude: artifact.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      );
    }).toList();
  }

  /// Get artifact from annotation
  Artifact _getArtifactFromAnnotation(ArAnnotation annotation) {
    if (annotation is ArtifactAnnotation) {
      return annotation.artifact;
    }
    // Fallback: find by UID
    return artifacts.firstWhere((artifact) => artifact.id == annotation.uid);
  }

  /// Get Material icon based on icon name
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'history':
        return Icons.history_edu;
      case 'stairs':
        return Icons.stairs;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  /// Show artifact details in a bottom sheet
  void _showArtifactDetails(Artifact artifact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(artifact.iconName),
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    artifact.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              artifact.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coordinates: ${artifact.latitude.toStringAsFixed(4)}°N, ${artifact.longitude.toStringAsFixed(4)}°E',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'Initializing AR Tour...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('AR Tour'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[300],
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    _initializeAR();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // AR Camera view with location annotations
          ArLocationWidget(
            annotations: annotations,
            showDebugInfoSensor: false,
            onLocationChange: (position) {
              // Handle location changes if needed
              debugPrint('Location: ${position.latitude}, ${position.longitude}');
            },
            annotationViewBuilder: (context, annotation) {
              final artifact = _getArtifactFromAnnotation(annotation);
              return GestureDetector(
                onTap: () => _showArtifactDetails(artifact),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconData(artifact.iconName),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artifact.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Top header with info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Grand Egyptian Museum AR Tour',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Text(
                      '${artifacts.length} artifacts nearby',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Point your camera around to see AR markers at artifact locations. Tap a marker for details.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
