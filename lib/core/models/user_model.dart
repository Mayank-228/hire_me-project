// lib/core/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role; // 'customer' or 'worker'
  final String? profilePhotoUrl;
  final String? address;
  final GeoPoint? location;
  final bool isVerified;
  final double rating;
  final int totalJobs;
  final DateTime createdAt;

  // Worker-specific fields
  final String? skillCategory;
  final int? experienceYears;
  final String? idProofUrl;
  final bool? isAvailable;
  final String? geohash; // for geo queries

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.profilePhotoUrl,
    this.address,
    this.location,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalJobs = 0,
    required this.createdAt,
    this.skillCategory,
    this.experienceYears,
    this.idProofUrl,
    this.isAvailable,
    this.geohash,
  });

  bool get isWorker => role == 'worker';
  bool get isCustomer => role == 'customer';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      profilePhotoUrl: data['profilePhotoUrl'],
      address: data['address'],
      location: data['location'] as GeoPoint?,
      isVerified: data['isVerified'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalJobs: data['totalJobs'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      skillCategory: data['skillCategory'],
      experienceYears: data['experienceYears'],
      idProofUrl: data['idProofUrl'],
      isAvailable: data['isAvailable'],
      geohash: data['geohash'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      // Omit null optional fields so Firestore doesn't store nulls
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
      if (address != null) 'address': address,
      if (location != null) 'location': location,
      // 🔴 FIX #3: isVerified, rating, totalJobs are server-managed — NEVER write from client.
      // Firestore security rules explicitly deny these on create/update.
      'createdAt': FieldValue.serverTimestamp(), // FIX #5: use server timestamp to avoid clock drift
      if (isWorker) ...{
        if (skillCategory != null) 'skillCategory': skillCategory,
        if (experienceYears != null) 'experienceYears': experienceYears,
        if (idProofUrl != null) 'idProofUrl': idProofUrl,
        'isAvailable': isAvailable ?? true,
        if (geohash != null) 'geohash': geohash,
      },
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? profilePhotoUrl,
    String? address,
    GeoPoint? location,
    bool? isVerified,
    double? rating,
    int? totalJobs,
    String? skillCategory,
    int? experienceYears,
    String? idProofUrl,
    bool? isAvailable,
    String? geohash,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      address: address ?? this.address,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      createdAt: createdAt,
      skillCategory: skillCategory ?? this.skillCategory,
      experienceYears: experienceYears ?? this.experienceYears,
      idProofUrl: idProofUrl ?? this.idProofUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      geohash: geohash ?? this.geohash,
    );
  }
}
