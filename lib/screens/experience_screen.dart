import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ExperienceScreen extends StatefulWidget {
  final CameraDescription camera;

  const ExperienceScreen({required this.camera, super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  String? _locationStatus;
  String? _cameraError;
  bool _initializingCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initializeLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_initializingCamera) return;
    _initializingCamera = true;

    await _cameraController?.dispose();
    final controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    setState(() {
      _cameraController = controller;
      _cameraError = null;
    });

    try {
      await controller.initialize();
    } on CameraException catch (error) {
      debugPrint('Camera initialization failed: $error');
      if (mounted) {
        setState(() {
          _cameraError = error.description ?? error.code;
        });
      }
    } finally {
      _initializingCamera = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _initializeLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _locationStatus = 'Enable location services to find Goia Spots.';
        });
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _locationStatus = 'Location permission denied.';
        });
      }
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen(
      (position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
          _locationStatus = null;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _locationStatus = 'Unable to read location data.';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildCameraPreview()),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: _buildOverlay(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController;

    if (_cameraError != null) {
      return Center(
        child: Text(
          _cameraError!,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return CameraPreview(controller);
  }

  Widget _buildOverlay() {
    final latitude = _currentPosition?.latitude;
    final longitude = _currentPosition?.longitude;
    final altitude = _currentPosition?.altitude;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Goia Spot',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_locationStatus != null)
            Text(
              _locationStatus!,
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w600,
              ),
            )
          else ...[
            _CoordinateRow(label: 'Lat', value: latitude),
            const SizedBox(height: 4),
            _CoordinateRow(label: 'Lng', value: longitude),
            const SizedBox(height: 4),
            _CoordinateRow(
              label: 'Alt',
              value: altitude,
              suffix: 'm',
              precision: 1,
            ),
          ],
          if (_locationStatus == null && _currentPosition == null) ...[
            const SizedBox(height: 8),
            const Text(
              'Waiting for GPS signal...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
}

class _CoordinateRow extends StatelessWidget {
  final String label;
  final double? value;
  final String suffix;
  final int precision;

  const _CoordinateRow({
    required this.label,
    required this.value,
    this.suffix = '',
    this.precision = 5,
  });

  @override
  Widget build(BuildContext context) {
    final formattedValue = value != null
        ? value!.toStringAsFixed(precision)
        : '--';

    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$formattedValue$suffix',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

