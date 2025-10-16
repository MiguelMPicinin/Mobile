class LocationPoint {
  final double latitude;
  final double longitude;

  LocationPoint({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}