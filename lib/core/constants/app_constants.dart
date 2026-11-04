// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = 'HireMe';
  static const String appTagline = 'Find help. Earn more.';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String jobRequestsCollection = 'job_requests';
  static const String categoriesCollection = 'categories';
  static const String ratingsCollection = 'ratings';
  static const String notificationsCollection = 'notifications';

  // Shared Preferences Keys
  static const String prefUserRole = 'user_role';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefFcmToken = 'fcm_token';

  // Job Matching
  static const double jobRadiusKm = 5.0;
  static const double minJobRadiusKm = 3.0;

  // Timeouts
  static const int otpTimeoutSeconds = 60;
  static const int locationTimeoutSeconds = 10;

  // Image limits
  static const int maxJobPhotos = 3;
  static const int maxFileSizeMb = 5;
}

class UserRole {
  static const String customer = 'customer';
  static const String worker = 'worker';
}

class JobStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String rejected = 'rejected';
}
