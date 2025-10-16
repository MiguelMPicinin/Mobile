class WorkPoint {
  final String userId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool isWorking;

  WorkPoint({
    required this.userId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isWorking
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'Esta trabalhando': isWorking
    };
  }

  factory WorkPoint.fromMap(Map<String, dynamic> map) {
    return WorkPoint(
      userId: map['userId'],
      timestamp: DateTime.parse(map['timestamp']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      isWorking: map['isWorking']
    );
  }
}
