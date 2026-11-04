// lib/shared/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class LocationService {
  static const double _jobRadiusKm = 5.0;

  /// Request permission and get current position
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Get GeoPoint from current position
  Future<GeoPoint?> getCurrentGeoPoint() async {
    final position = await getCurrentPosition();
    if (position == null) return null;
    return GeoPoint(position.latitude, position.longitude);
  }

  /// Generate geohash string for a given lat/lng (for Firestore geo queries)
  String getGeohash(double lat, double lng) {
    final point = GeoFirePoint(GeoPoint(lat, lng));
    return point.geohash;
  }

  /// Calculate distance between two GeoPoints in km
  double distanceBetween(GeoPoint point1, GeoPoint point2) {
    return Geolocator.distanceBetween(
          point1.latitude,
          point1.longitude,
          point2.latitude,
          point2.longitude,
        ) /
        1000.0; // convert meters → km
  }

  /// Get nearby job requests within radius using GeoFlutterFire
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> getNearbyJobRequests({
    required GeoPoint center,
    double radiusKm = _jobRadiusKm,
    required String categoryId,
  }) {
    final collection = FirebaseFirestore.instance
        .collection('job_requests')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data()!,
          toFirestore: (data, _) => data,
        );
    final geoPoint = GeoFirePoint(center);

    return GeoCollectionReference<Map<String, dynamic>>(collection).subscribeWithin(
      center: geoPoint,
      radiusInKm: radiusKm,
      field: 'location',
      geopointFrom: (data) => data['location'] as GeoPoint,
      queryBuilder: (query) => query
          .where('status', isEqualTo: 'pending')
          .where('categoryId', isEqualTo: categoryId),
    );
  }

  /// Get all nearby pending requests regardless of category
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> getAllNearbyJobRequests({
    required GeoPoint center,
    double radiusKm = _jobRadiusKm,
  }) {
    final collection = FirebaseFirestore.instance
        .collection('job_requests')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data()!,
          toFirestore: (data, _) => data,
        );
    final geoPoint = GeoFirePoint(center);

    return GeoCollectionReference<Map<String, dynamic>>(collection).subscribeWithin(
      center: geoPoint,
      radiusInKm: radiusKm,
      field: 'location',
      geopointFrom: (data) => data['location'] as GeoPoint,
      queryBuilder: (query) => query.where('status', isEqualTo: 'pending'),
    );
  }

  /// Format distance for display
  String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
