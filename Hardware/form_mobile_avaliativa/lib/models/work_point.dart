// models/work_point.dart
class WorkPoint {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool isWorking;

  WorkPoint({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isWorking,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'isWorking': isWorking,
    };
  }

  factory WorkPoint.fromMap(Map<String, dynamic> map) {
    return WorkPoint(
      id: map['id'],
      userId: map['userId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      isWorking: map['isWorking'] as bool,
    );
  }
}