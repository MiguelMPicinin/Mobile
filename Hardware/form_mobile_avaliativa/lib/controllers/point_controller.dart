// controllers/point_controller.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_point.dart';
import '../models/work_point.dart';

class PointController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveWorkLocation(LocationPoint location, String userId) async {
    await _firestore
        .collection('work_locations')
        .doc(userId)
        .set(location.toMap());
  }

  Future<LocationPoint?> fetchWorkLocation(String userId) async {
    try {
      var doc = await _firestore
          .collection('work_locations')
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        return LocationPoint.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool isWithinAllowedDistance(LocationPoint workLocation, LocationPoint userLocation) {
    double distance = calculateDistance(
      workLocation.latitude,
      workLocation.longitude,
      userLocation.latitude,
      userLocation.longitude,
    );
    return distance <= 100; // metros
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // metros
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> saveWorkPoint(WorkPoint point) async {
    await _firestore.collection('work_points').add(point.toMap());
  }

  Stream<List<WorkPoint>> getWorkPoints(String userId) {
    return _firestore
        .collection('work_points')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return WorkPoint.fromMap(data);
            }).toList());
  }
}