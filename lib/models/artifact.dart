/// Model class representing a museum artifact with GPS coordinates
class Artifact {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String iconName;

  Artifact({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.iconName,
  });

  /// Creates an Artifact instance from a JSON map
  factory Artifact.fromJson(Map<String, dynamic> json) {
    return Artifact(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      iconName: json['iconName'] as String,
    );
  }

  /// Converts the Artifact to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'iconName': iconName,
    };
  }

  @override
  String toString() {
    return 'Artifact(id: $id, name: $name, lat: $latitude, lon: $longitude)';
  }
}

