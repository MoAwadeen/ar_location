import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gem_ar_tour/screens/home_screen.dart';

void main() {
  const testCamera = CameraDescription(
    name: 'TestCamera',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 90,
  );

  testWidgets('Home screen shows Goia Spots hero state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(camera: testCamera),
      ),
    );

    expect(find.text('Goia Spots'), findsOneWidget);
    expect(find.text('Start experience'), findsOneWidget);

    final ElevatedButton button =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });
}
