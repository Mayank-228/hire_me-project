// lib/core/models/job_request_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class JobRequestModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? customerPhotoUrl;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final GeoPoint location;
  final String address;
  final String geohash;
  final String status; // pending, accepted, in_progress, completed, cancelled
  final String urgency; // Urgent, Scheduled, Flexible
  final String? workerId;
  final String? workerName;
  final List<String> photoUrls;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final double? estimatedBudget;
  final double? finalAmount;
  final double? customerRating;
  final double? workerRating;
  final String? cancellationReason;

  const JobRequestModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerPhone = '+91 98112 34567',
    this.customerPhotoUrl,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.location,
    required this.address,
    required this.geohash,
    required this.status,
    this.urgency = 'Urgent',
    this.workerId,
    this.workerName,
    this.photoUrls = const [],
    this.scheduledAt,
    required this.createdAt,
    this.estimatedBudget,
    this.finalAmount,
    this.customerRating,
    this.workerRating,
    this.cancellationReason,
  });

  factory JobRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final loc = data['location'];
    final geoPoint = (loc is GeoPoint) ? loc : const GeoPoint(28.6692, 77.4538);

    return JobRequestModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? 'Customer',
      customerPhone: data['customerPhone'] ?? '+91 98112 34567',
      customerPhotoUrl: data['customerPhotoUrl'],
      categoryId: data['categoryId'] ?? 'plumber',
      categoryName: data['categoryName'] ?? 'Plumbing',
      title: data['title'] ?? 'Service Request',
      description: data['description'] ?? '',
      location: geoPoint,
      address: data['address'] ?? 'Ghaziabad, Sector 12',
      geohash: data['geohash'] ?? '',
      status: data['status'] ?? 'pending',
      urgency: data['urgency'] ?? 'Urgent',
      workerId: data['workerId'],
      workerName: data['workerName'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedBudget: (data['estimatedBudget'] as num?)?.toDouble() ?? 400.0,
      finalAmount: (data['finalAmount'] as num?)?.toDouble(),
      customerRating: (data['customerRating'] as num?)?.toDouble(),
      workerRating: (data['workerRating'] as num?)?.toDouble(),
      cancellationReason: data['cancellationReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerPhotoUrl': customerPhotoUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'title': title,
      'description': description,
      'location': location,
      'address': address,
      'geohash': geohash,
      'status': status,
      'urgency': urgency,
      'workerId': workerId,
      'workerName': workerName,
      'photoUrls': photoUrls,
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'estimatedBudget': estimatedBudget,
      'finalAmount': finalAmount,
      'customerRating': customerRating,
      'workerRating': workerRating,
      'cancellationReason': cancellationReason,
    };
  }

  JobRequestModel copyWith({
    String? status,
    String? urgency,
    String? workerId,
    String? workerName,
    double? finalAmount,
    double? customerRating,
    double? workerRating,
    String? cancellationReason,
  }) {
    return JobRequestModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerPhotoUrl: customerPhotoUrl,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      description: description,
      location: location,
      address: address,
      geohash: geohash,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      photoUrls: photoUrls,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      estimatedBudget: estimatedBudget,
      finalAmount: finalAmount ?? this.finalAmount,
      customerRating: customerRating ?? this.customerRating,
      workerRating: workerRating ?? this.workerRating,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
