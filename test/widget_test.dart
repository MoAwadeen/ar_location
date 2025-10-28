// Basic unit test for the GEM AR Tour application

import 'package:flutter_test/flutter_test.dart';
import 'package:gem_ar_tour/models/artifact.dart';

void main() {
  group('Artifact Model Tests', () {
    test('Artifact can be created from JSON', () {
      final json = {
        'id': 'test_artifact',
        'name': 'Test Artifact',
        'description': 'A test description',
        'latitude': 29.9939,
        'longitude': 31.1206,
        'iconName': 'history',
      };

      final artifact = Artifact.fromJson(json);

      expect(artifact.id, 'test_artifact');
      expect(artifact.name, 'Test Artifact');
      expect(artifact.description, 'A test description');
      expect(artifact.latitude, 29.9939);
      expect(artifact.longitude, 31.1206);
      expect(artifact.iconName, 'history');
    });

    test('Artifact can be converted to JSON', () {
      final artifact = Artifact(
        id: 'test_artifact',
        name: 'Test Artifact',
        description: 'A test description',
        latitude: 29.9939,
        longitude: 31.1206,
        iconName: 'history',
      );

      final json = artifact.toJson();

      expect(json['id'], 'test_artifact');
      expect(json['name'], 'Test Artifact');
      expect(json['description'], 'A test description');
      expect(json['latitude'], 29.9939);
      expect(json['longitude'], 31.1206);
      expect(json['iconName'], 'history');
    });

    test('Artifact toString works correctly', () {
      final artifact = Artifact(
        id: 'test_artifact',
        name: 'Test Artifact',
        description: 'A test description',
        latitude: 29.9939,
        longitude: 31.1206,
        iconName: 'history',
      );

      final stringRepresentation = artifact.toString();

      expect(stringRepresentation, contains('test_artifact'));
      expect(stringRepresentation, contains('Test Artifact'));
      expect(stringRepresentation, contains('29.9939'));
      expect(stringRepresentation, contains('31.1206'));
    });
  });
}
