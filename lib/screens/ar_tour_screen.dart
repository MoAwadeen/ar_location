import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ar_location_view/ar_location_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/artifact.dart';
import '../utils/gps_kalman_filter.dart';
import '../utils/smart_update_strategy.dart';

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

/// Production-quality AR Tour Screen with advanced optimizations
/// 
/// Features:
/// - GPS Kalman filtering for smooth position tracking
/// - Smart update strategy to prevent jitter
/// - High-accuracy GPS with continuous updates
/// - Compass calibration UI
/// - Radar and distance scaling
/// - Stable, fixed-size pin widgets
class ARTourScreen extends StatefulWidget {
  const ARTourScreen({super.key});

  @override
  State<ARTourScreen> createState() => _ARTourScreenState();
}

class _ARTourScreenState extends State<ARTourScreen> {
  // Data management
  List<Artifact> artifacts = [];
  List<ArAnnotation> annotations = [];
  
  // State flags
  bool isLoading = true;
  String? errorMessage;
  bool showCalibrationHint = true;
  
  // Position tracking
  Position? currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // Optimization utilities
  final GPSKalmanFilter _kalmanFilter = GPSKalmanFilter();
  final SmartUpdateStrategy _updateStrategy = SmartUpdateStrategy();
  
  // Sensor monitoring for calibration detection
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAR();
    _startAccelerometerMonitoring();
  }

  /// Initialize AR with all optimizations
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

      // Start high-accuracy GPS stream
      await _startLocationStream();

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

  /// Start high-accuracy GPS location stream
  /// 
  /// Configuration:
  /// - bestForNavigation: Highest accuracy mode
  /// - distanceFilter: 0 = Get all updates
  /// - Continuous stream for smooth tracking
  Future<void> _startLocationStream() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0, // Get all position updates
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      _handleNewPosition,
      onError: (error) {
        debugPrint('Location stream error: $error');
      },
    );
  }

  /// Handle new GPS position with filtering and smart updates
  /// 
  /// Flow:
  /// 1. Apply Kalman filter to smooth position
  /// 2. Check if update should be applied (Smart Update Strategy)
  /// 3. Update annotations if needed
  /// 4. Update UI state
  void _handleNewPosition(Position rawPosition) {
    // Step 1: Apply Kalman filter to reduce GPS jitter
    final filteredPosition = _kalmanFilter.filter(rawPosition);

    // Step 2: Check if we should update (prevents drift when standing still)
    if (!_updateStrategy.shouldUpdate(filteredPosition)) {
      // Skip this update - not enough movement
      debugPrint('Update skipped - efficiency: ${_updateStrategy.efficiencyRatio.toStringAsFixed(2)}');
      return;
    }

    // Step 3: Update annotations with new filtered position
    setState(() {
      currentPosition = filteredPosition;
      _createAnnotations(filteredPosition);
    });

    debugPrint('Position updated: ${filteredPosition.latitude.toStringAsFixed(6)}, ${filteredPosition.longitude.toStringAsFixed(6)} (accuracy: ${filteredPosition.accuracy}m)');
  }

  /// Create AR annotations from artifacts with altitude
  void _createAnnotations(Position userPosition) {
    annotations = artifacts.map((artifact) {
      return ArtifactAnnotation(
        artifact: artifact,
        position: Position(
          latitude: artifact.latitude,
          longitude: artifact.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: artifact.altitude, // Use artifact's altitude
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      );
    }).toList();
  }

  /// Monitor accelerometer to detect calibration movements
  /// 
  /// Detects figure-8 pattern movements and hides calibration hint
  void _startAccelerometerMonitoring() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        // Detect significant movement (figure-8 pattern)
        final magnitude = event.x.abs() + event.y.abs() + event.z.abs();
        
        if (magnitude > 15.0) {
          // Hide calibration hint after detecting movement
          if (showCalibrationHint) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  showCalibrationHint = false;
                });
              }
            });
          }
        }
      },
    );
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

  /// Calculate distance to artifact
  String _getDistanceText(Artifact artifact) {
    if (currentPosition == null) return '';
    
    final distance = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      artifact.latitude,
      artifact.longitude,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artifact.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (currentPosition != null)
                        Text(
                          _getDistanceText(artifact),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
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
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'GPS: ${artifact.latitude.toStringAsFixed(6)}°N, ${artifact.longitude.toStringAsFixed(6)}°E',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (artifact.altitude > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.height, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Altitude: ${artifact.altitude}m above ground',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
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
              const SizedBox(height: 8),
              Text(
                'Optimizing GPS tracking',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
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
          // AR Camera view with optimized location annotations
          ArLocationWidget(
            annotations: annotations,
            annotationWidth: 80,  // Fixed width for stability
            annotationHeight: 100, // Fixed height for stability
            showDebugInfoSensor: false,
            scaleWithDistance: true, // Scale pins based on distance
            showRadar: true, // Show radar overlay
            radarWidth: 120,
            radarPosition: RadarPosition.bottomRight,
            maxVisibleDistance: 1500, // 1.5km max visibility
            onLocationChange: (position) {
              // Location changes are handled by the stream
              // This callback is for ArLocationWidget internal use
            },
            annotationViewBuilder: (context, annotation) {
              final artifact = _getArtifactFromAnnotation(annotation);
              final distance = _getDistanceText(artifact);
              
              return GestureDetector(
                onTap: () => _showArtifactDetails(artifact),
                child: Container(
                  width: 80,  // Fixed size - no dynamic sizing
                  height: 100, // Fixed size - prevents layout shifts
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconData(artifact.iconName),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        artifact.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (distance.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          distance,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Compass calibration hint banner
          if (showCalibrationHint)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Calibrate Compass',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Move device in figure-8 pattern',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        setState(() {
                          showCalibrationHint = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          // Top header with info (below calibration hint if shown)
          Positioned(
            top: showCalibrationHint ? 90 : 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: showCalibrationHint ? 8 : MediaQuery.of(context).padding.top + 16,
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
                          'AR Museum Tour',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // GPS accuracy indicator
                      if (currentPosition != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getAccuracyColor(currentPosition!.accuracy),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.gps_fixed, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '±${currentPosition!.accuracy.toStringAsFixed(0)}m',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Text(
                      '${artifacts.length} artifacts • Kalman filtered • Stable tracking',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
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
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pan around to see AR markers. Tap for details. Check radar (↘) for directions.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 13,
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

  /// Get accuracy color indicator
  Color _getAccuracyColor(double accuracy) {
    if (accuracy <= 5) return Colors.green;
    if (accuracy <= 10) return Colors.lightGreen;
    if (accuracy <= 20) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }
}
