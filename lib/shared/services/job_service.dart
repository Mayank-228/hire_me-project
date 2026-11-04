// lib/shared/services/job_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/job_request_model.dart';

class JobService {
  JobService._internal() {
    _initSampleJobs();
    _initFirestoreListener();
  }

  static final JobService instance = JobService._internal();
  factory JobService() => instance;

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }
  final Uuid _uuid = const Uuid();

  final List<JobRequestModel> _jobs = [];
  final StreamController<List<JobRequestModel>> _jobsController =
      StreamController<List<JobRequestModel>>.broadcast();

  Stream<List<JobRequestModel>> get allJobsStream => _jobsController.stream;

  List<JobRequestModel> get currentJobs => List.unmodifiable(_jobs);

  void _initSampleJobs() {
    _jobs.clear();
    _jobs.addAll([
      JobRequestModel(
        id: 'sample-job-1',
        customerId: 'cust-aarav',
        customerName: 'Aarav Sharma',
        customerPhone: '+91 98112 34567',
        categoryId: 'plumber',
        categoryName: 'Plumbing',
        title: 'Kitchen Sink Pipe Leak',
        description:
            'Heavy water dripping from P-trap beneath the modular kitchen marble sink. Needs immediate washer replacement & Teflon seal.',
        location: const GeoPoint(28.5700, 77.3200),
        address: 'Flat 402, Block B, Silver Palms, Sector 18',
        geohash: 'ttnfw0',
        status: JobStatus.pending,
        urgency: 'Urgent',
        estimatedBudget: 450.0,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      JobRequestModel(
        id: 'sample-job-2',
        customerId: 'cust-priya',
        customerName: 'Priya Mehra',
        customerPhone: '+91 98223 45678',
        categoryId: 'plumber',
        categoryName: 'Plumbing',
        title: 'Bathroom Tap Replacement',
        description:
            'Quarter turn brass wall mixer knob is stripped and leaking continuously. Replacement tap is ready on-site.',
        location: const GeoPoint(28.5900, 77.3400),
        address: 'Villa 14, Green Meadows, Sector 22',
        geohash: 'ttnfw8',
        status: JobStatus.pending,
        urgency: 'Scheduled',
        estimatedBudget: 350.0,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      JobRequestModel(
        id: 'sample-job-3',
        customerId: 'cust-vikram',
        customerName: 'Vikram Sethi',
        customerPhone: '+91 98334 56789',
        categoryId: 'plumber',
        categoryName: 'Plumbing',
        title: 'Overhead Tank Float Valve Fix',
        description:
            '500L rooftop syntax tank overflowing whenever the booster motor turns on. Brass float valve needs adjustment or replacement.',
        location: const GeoPoint(28.6300, 77.3700),
        address: 'House 88, Nyay Khand 2, Indirapuram',
        geohash: 'ttnfxd',
        status: JobStatus.pending,
        urgency: 'High',
        estimatedBudget: 550.0,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      // ── Jobs Done Before (Completed History) ──────────────────────────────
      JobRequestModel(
        id: 'sample-completed-1',
        customerId: 'cust-sanjay',
        customerName: 'Sanjay Verma',
        customerPhone: '+91 98450 12345',
        categoryId: 'plumber',
        categoryName: 'Plumbing',
        title: 'RO Water Purifier Inlet Valve & Line Fitting',
        description:
            'Dedicated chrome angle valve installation with leak-free copper piping diversion for kitchen reverse osmosis purifier unit.',
        location: const GeoPoint(28.5800, 77.3300),
        address: 'Flat 504, Tower 3, Gaur City 1, Greater Noida West',
        geohash: 'ttnfw5',
        status: JobStatus.completed,
        urgency: 'Scheduled',
        estimatedBudget: 650.0,
        finalAmount: 650.0,
        customerRating: 5.0,
        workerId: 'worker-1',
        workerName: 'Rajesh Kumar',
        createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
      ),
      JobRequestModel(
        id: 'sample-completed-2',
        customerId: 'cust-meenakshi',
        customerName: 'Meenakshi Iyer',
        customerPhone: '+91 98711 54321',
        categoryId: 'plumber',
        categoryName: 'Plumbing',
        title: 'Concealed Bathroom Mixer Spindle Overhaul',
        description:
            'Dismantled ceramic disc cartridge inside wall-embedded mixer valve, descaled calcium build-up, and restored high-pressure flow.',
        location: const GeoPoint(28.5600, 77.3500),
        address: 'B-12, Sector 50, Noida',
        geohash: 'ttnfw2',
        status: JobStatus.completed,
        urgency: 'Urgent',
        estimatedBudget: 450.0,
        finalAmount: 450.0,
        customerRating: 4.9,
        workerId: 'worker-1',
        workerName: 'Rajesh Kumar',
        createdAt: DateTime.now().subtract(const Duration(hours: 6, minutes: 40)),
      ),
      JobRequestModel(
        id: 'sample-completed-3',
        customerId: 'cust-rohan',
        customerName: 'Rohan Gupta',
        customerPhone: '+91 99100 87654',
        categoryId: 'plumber',
        categoryName: 'Plumbing',
        title: 'Motorized Water Booster Pump Alignment',
        description:
            'Replaced worn rubber coupling, resealed inlet non-return valve, and silenced cavitation vibration for 1HP booster pump.',
        location: const GeoPoint(28.6200, 77.3800),
        address: 'Plot 45, Ahinsa Khand 2, Indirapuram',
        geohash: 'ttnfxc',
        status: JobStatus.completed,
        urgency: 'Scheduled',
        estimatedBudget: 750.0,
        finalAmount: 750.0,
        customerRating: 5.0,
        workerId: 'worker-1',
        workerName: 'Rajesh Kumar',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
    ]);

    // Initial emit
    _emitJobs();
  }

  void _emitJobs() {
    if (!_jobsController.isClosed) {
      _jobsController.add(List.from(_jobs));
    }
  }

  void _initFirestoreListener() {
    try {
      final fs = _firestore;
      if (fs == null) return;
      fs
          .collection(AppConstants.jobRequestsCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            for (final doc in snapshot.docs) {
              try {
                final firestoreJob = JobRequestModel.fromFirestore(doc);
                final index = _jobs.indexWhere((j) => j.id == firestoreJob.id);
                if (index != -1) {
                  _jobs[index] = firestoreJob;
                } else {
                  _jobs.insert(0, firestoreJob);
                }
              } catch (_) {
                // Ignore parsing anomalies
              }
            }
            _emitJobs();
          }
        },
        onError: (err) {
          // Firestore offline or permissions not set - gracefully fallback to in-memory state
        },
      );
    } catch (_) {
      // Offline fallback
    }
  }

  /// Create and post a new job request (from Customer side)
  Future<JobRequestModel> postJobRequest({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String categoryId,
    required String categoryName,
    required String title,
    required String description,
    required String address,
    required double estimatedBudget,
    String urgency = 'Urgent',
    GeoPoint location = const GeoPoint(28.6692, 77.4538),
  }) async {
    final String jobId = 'job-${_uuid.v4().substring(0, 8)}';
    final newJob = JobRequestModel(
      id: jobId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      description: description,
      address: address,
      geohash: 'ttnfw0',
      status: JobStatus.pending,
      urgency: urgency,
      location: location,
      estimatedBudget: estimatedBudget,
      createdAt: DateTime.now(),
    );

    // 1. Immediately update local stream so workers see it in real-time
    _jobs.insert(0, newJob);
    _emitJobs();

    // 2. Persist to Firestore asynchronously
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs
            .collection(AppConstants.jobRequestsCollection)
            .doc(jobId)
            .set(newJob.toFirestore());
      }
    } catch (_) {
      // Safe fallback if firestore fails
    }

    return newJob;
  }

  /// Accept a job request (from Worker side)
  Future<void> acceptJob(
    String jobId, {
    required String workerId,
    required String workerName,
  }) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final updated = _jobs[index].copyWith(
        status: JobStatus.inProgress,
        workerId: workerId,
        workerName: workerName,
      );
      _jobs[index] = updated;
      _emitJobs();

      try {
        final fs = _firestore;
        if (fs != null) {
          await fs
              .collection(AppConstants.jobRequestsCollection)
              .doc(jobId)
              .update({
            'status': JobStatus.inProgress,
            'workerId': workerId,
            'workerName': workerName,
          });
        }
      } catch (_) {}
    }
  }

  /// Complete a job request and register collected payment
  Future<void> completeJob(String jobId, {double? finalAmount}) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final updated = _jobs[index].copyWith(
        status: JobStatus.completed,
        finalAmount: finalAmount ?? _jobs[index].estimatedBudget,
      );
      _jobs[index] = updated;
      _emitJobs();

      try {
        final fs = _firestore;
        if (fs != null) {
          await fs
              .collection(AppConstants.jobRequestsCollection)
              .doc(jobId)
              .update({
            'status': JobStatus.completed,
            if (finalAmount != null) 'finalAmount': finalAmount,
          });
        }
      } catch (_) {}
    }
  }

  /// Reject a job request (from Worker side)
  Future<void> rejectJob(String jobId, {String? workerId, String? reason}) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final updated = _jobs[index].copyWith(
        status: JobStatus.rejected,
        cancellationReason: reason ?? 'Declined by worker',
      );
      _jobs[index] = updated;
      _emitJobs();

      try {
        final fs = _firestore;
        if (fs != null) {
          await fs
              .collection(AppConstants.jobRequestsCollection)
              .doc(jobId)
              .update({
            'status': JobStatus.rejected,
            'cancellationReason': reason ?? 'Declined by worker',
          });
        }
      } catch (_) {}
    }
  }

  /// Cancel a job request
  Future<void> cancelJob(String jobId, {String? reason}) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final updated = _jobs[index].copyWith(
        status: JobStatus.cancelled,
        cancellationReason: reason ?? 'Cancelled by user',
      );
      _jobs[index] = updated;
      _emitJobs();

      try {
        final fs = _firestore;
        if (fs != null) {
          await fs
              .collection(AppConstants.jobRequestsCollection)
              .doc(jobId)
              .update({
            'status': JobStatus.cancelled,
            'cancellationReason': reason ?? 'Cancelled by user',
          });
        }
      } catch (_) {}
    }
  }

  /// Permanently delete a job request from list and Firestore
  Future<void> deleteJob(String jobId) async {
    _jobs.removeWhere((j) => j.id == jobId);
    _emitJobs();

    try {
      final fs = _firestore;
      if (fs != null) {
        await fs
            .collection(AppConstants.jobRequestsCollection)
            .doc(jobId)
            .delete();
      }
    } catch (_) {}
  }

  /// Watch available pending jobs nearby for workers
  Stream<List<JobRequestModel>> watchAvailableJobs() {
    return _jobsController.stream.map(
      (list) => list.where((j) => j.status == JobStatus.pending).toList(),
    );
  }

  /// Watch active / in-progress jobs for workers
  Stream<List<JobRequestModel>> watchActiveJobs() {
    return _jobsController.stream.map(
      (list) => list
          .where((j) =>
              j.status == JobStatus.accepted ||
              j.status == JobStatus.inProgress)
          .toList(),
    );
  }

  /// Watch jobs posted by a specific customer
  Stream<List<JobRequestModel>> watchCustomerJobs(String customerId) {
    return _jobsController.stream.map(
      (list) => list
          .where((j) =>
              j.customerId == customerId ||
              j.customerId.startsWith('cust-'))
          .toList(),
    );
  }

  /// Reset demo jobs back to initial clean state
  void resetSampleJobs() {
    _initSampleJobs();
  }
}
