import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'experience_screen.dart';

class HomeScreen extends StatelessWidget {
  final CameraDescription? camera;

  const HomeScreen({required this.camera, super.key});

  @override
  Widget build(BuildContext context) {
    final bool cameraReady = camera != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Goia Spots',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Explore Goia Spots around you',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: cameraReady ? () => _startExperience(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Start experience'),
              ),
              const SizedBox(height: 16),
              Text(
                cameraReady
                    ? 'The next screen will request camera and location permissions.'
                    : 'No compatible camera was detected on this device.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white60,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _startExperience(BuildContext context) {
    if (camera == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExperienceScreen(camera: camera!),
      ),
    );
  }
}

